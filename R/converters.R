# R/converters.R - Fully Vectorized Functions

#' Convert Bikram Sambat (BS) date to Anno Domini (AD) date
#'
#' This function is fully vectorized for high performance on large datasets.
#'
#' @param bs_date A character vector representing BS dates in "YYYY-MM-DD" or "YYYY/MM/DD" format.
#'
#' @return A character vector of the equivalent AD dates in "YYYY-MM-DD" format.
#' @export
#'
#' @examples
#' bs_to_ad("2080-05-15")
#' bs_to_ad(c("2080-05-15", "2080-06-20", NA))
#'
#' @seealso \code{\link{ad_to_bs}} for converting AD to BS dates
bs_to_ad <- function(bs_date) {
  # --- Pre-computation and Initialization ---
  # One-time setup of cumulative data for quick lookups
  bs_years_char <- as.character(1970:2099)
  
  # Total days in each BS year
  total_days_in_bs_years <- sapply(bs_years_char, function(y) nepalidate::calendar_data[[y]][13])
  
  # Cumulative sum of days from the start (1970) - this replaces the slow nested loops
  cumulative_bs_days <- cumsum(total_days_in_bs_years)
  
  # One-time calculation of cumulative days for each month within each year
  cumulative_days_in_year <- lapply(nepalidate::calendar_data, function(year_data) {
    # The first 12 elements are month lengths
    cumsum(c(0, year_data[1:11]))
  })

  # --- Input Handling & Validation ---
  if (all(is.na(bs_date))) {
    return(as.character(bs_date))
  }

  original_class <- class(bs_date)
  output_dates <- rep(NA_character_, length(bs_date))
  non_na_indices <- !is.na(bs_date)

  # Work only on non-NA dates
  valid_dates <- bs_date[non_na_indices]

  # Standardize date format
  valid_dates <- gsub("/", "-", valid_dates)

  # Vectorized split of date parts
  date_parts <- do.call(rbind, strsplit(valid_dates, "-"))
  if (ncol(date_parts) != 3) {
    stop("Invalid date format. All dates must use YYYY-MM-DD or YYYY/MM/DD.")
  }

  years <- as.numeric(date_parts[, 1])
  months <- as.numeric(date_parts[, 2])
  days <- as.numeric(date_parts[, 3])

  # --- Vectorized Validation ---
  if (any(years < 1970 | years > 2099, na.rm = TRUE)) {
    stop("Year must be between 1970 and 2099.")
  }
  if (any(months < 1 | months > 12, na.rm = TRUE)) {
    stop("Month must be between 1 and 12.")
  }

  # Get max days for each date's year and month
  year_strs <- as.character(years)
  max_days <- vapply(seq_along(year_strs), function(i) {
    nepalidate::calendar_data[[year_strs[i]]][months[i]]
  }, numeric(1))

  if (any(days < 1 | days > max_days, na.rm = TRUE)) {
    stop("Invalid day for the given month and year.")
  }

  # --- Vectorized Calculation ---
  # Reference: BS 1970-01-01 is AD 1913-04-13
  ref_ad_date <- as.Date("1913-04-13")

  # Calculate total days passed since the start of the BS calendar data (1970-01-01)
  # 1. Days from full years passed since 1970 (using pre-computed cumulative data)
  year_indices <- years - 1970
  total_days_from_years <- ifelse(year_indices == 0, 0, cumulative_bs_days[year_indices])

  # 2. Days from full months passed in the current year
  total_days_from_months <- vapply(seq_along(year_strs), function(i) {
    cumulative_days_in_year[[year_strs[i]]][months[i]]
  }, numeric(1))

  # 3. Total days is sum of year days, month days, and current day of month (minus 1 for offset)
  total_days_offset <- total_days_from_years + total_days_from_months + days - 1

  # Calculate final AD dates
  final_ad_dates <- ref_ad_date + total_days_offset

  # --- Format Output ---
  output_dates[non_na_indices] <- format(final_ad_dates, "%Y-%m-%d")

  return(output_dates)
}


#' Convert Anno Domini (AD) date to Bikram Sambat (BS) date
#'
#' This function is fully vectorized for high performance on large datasets.
#'
#' @param ad_date A character vector or Date vector representing AD dates.
#'
#' @return A character vector of the equivalent BS dates in "YYYY-MM-DD" format.
#' @export
#'
#' @examples
#' ad_to_bs("2023-09-01")
#' ad_to_bs(as.Date("2023-09-01"))
#' ad_to_bs(c("2023-09-01", "2023-10-15", NA))
#'
#' @seealso \code{\link{bs_to_ad}} for converting BS to AD dates
ad_to_bs <- function(ad_date) {
  # --- Pre-computation and Initialization ---
  # One-time setup of cumulative data for quick lookups
  bs_years_char <- as.character(1970:2099)

  # Total days in each BS year
  total_days_in_bs_years <- sapply(bs_years_char, function(y) nepalidate::calendar_data[[y]][13])

  # Cumulative sum of days from the start (1970)
  cumulative_bs_days <- cumsum(total_days_in_bs_years)

  # Cumulative days for each month within each year
  cumulative_days_in_year <- lapply(nepalidate::calendar_data, function(year_data) {
    cumsum(c(0, year_data[1:11]))
  })

  # --- Input Handling & Validation ---
  if (all(is.na(ad_date))) {
    return(as.character(ad_date))
  }

  output_dates <- rep(NA_character_, length(ad_date))
  non_na_indices <- !is.na(ad_date)

  valid_dates <- ad_date[non_na_indices]

  if (!inherits(valid_dates, "Date")) {
    valid_dates <- as.Date(gsub("/", "-", valid_dates))
  }

  # --- Vectorized Validation ---
  min_date <- as.Date("1913-04-13") # BS 1970-01-01
  max_date <- as.Date("2043-04-13") # BS 2099-12-30

  if (any(valid_dates < min_date | valid_dates > max_date, na.rm = TRUE)) {
    stop("Date must be between 1913-04-13 and 2043-04-13.")
  }

  # --- Vectorized Calculation ---
  # Calculate day difference from the reference AD date
  day_diff <- as.numeric(valid_dates - min_date)

  # Find the correct BS year for each date using findInterval
  # This finds which year's cumulative day count the 'day_diff' falls into
  year_indices <- findInterval(day_diff, cumulative_bs_days, left.open = FALSE)
  bs_years <- 1970 + year_indices

  # Calculate the number of days passed into that BS year
  # Subtract the cumulative days of all prior years
  prior_years_cumulative_days <- c(0, cumulative_bs_days)[year_indices + 1]
  remaining_days <- day_diff - prior_years_cumulative_days + 1

  # Find the correct month and day for each date
  # We look up the data for each date's *specific* BS year
  year_strs <- as.character(bs_years)

  # Find month index for each date using its specific remaining_days and year data
  month_indices <- vapply(seq_along(year_strs), function(i) {
    findInterval(remaining_days[i] - 1, cumulative_days_in_year[[year_strs[i]]])
  }, numeric(1))

  bs_months <- month_indices

  # Calculate the day of the month
  bs_days <- vapply(seq_along(year_strs), function(i) {
    remaining_days[i] - cumulative_days_in_year[[year_strs[i]]][month_indices[i]]
  }, numeric(1))

  # --- Format Output ---
  final_bs_dates <- sprintf("%04d-%02d-%02d", bs_years, bs_months, bs_days)
  output_dates[non_na_indices] <- final_bs_dates

  return(output_dates)
}
