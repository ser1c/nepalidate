# R/converters.R - Fully Vectorized Conversion Functions

#' Convert Bikram Sambat (BS) date to Anno Domini (AD) date
#'
#' Converts one or more BS dates to their Gregorian (AD) equivalents.
#' This function is fully vectorized for high performance on large datasets.
#'
#' @param bs_date A character vector representing BS dates in "YYYY-MM-DD" or
#'   "YYYY/MM/DD" format. \code{NA} values are preserved.
#'
#' @return A \code{Date} vector of the equivalent AD dates.
#' @export
#'
#' @examples
#' bs_to_ad("2080-05-15")
#' bs_to_ad(c("2080-05-15", "2080-06-20", NA))
#'
#' @seealso \code{\link{ad_to_bs}} for converting AD to BS dates
bs_to_ad <- function(bs_date) {
  # Handle all-NA or empty input
  if (length(bs_date) == 0L) return(as.Date(character(0)))
  if (all(is.na(bs_date))) return(as.Date(rep(NA, length(bs_date))))

  output_dates <- rep(as.Date(NA), length(bs_date))
  non_na <- !is.na(bs_date)

  valid_dates <- gsub("/", "-", bs_date[non_na])

  # Vectorized split of date parts
  date_parts <- do.call(rbind, strsplit(valid_dates, "-"))
  if (ncol(date_parts) != 3L) {
    stop("Invalid date format. All dates must use YYYY-MM-DD or YYYY/MM/DD.")
  }

  years  <- as.integer(date_parts[, 1])
  months <- as.integer(date_parts[, 2])
  days   <- as.integer(date_parts[, 3])

  # --- Validation with informative errors ---
  bad_year <- which(years < 1970L | years > 2099L)
  if (length(bad_year) > 0L) {
    pos <- bad_year[seq_len(min(5L, length(bad_year)))]
    stop(sprintf(
      "Year must be between 1970 and 2099. Invalid at position(s): %s (value: %s)",
      paste(pos, collapse = ", "),
      paste(valid_dates[pos], collapse = ", ")
    ))
  }

  bad_month <- which(months < 1L | months > 12L)
  if (length(bad_month) > 0L) {
    pos <- bad_month[seq_len(min(5L, length(bad_month)))]
    stop(sprintf(
      "Month must be between 1 and 12. Invalid at position(s): %s (value: %s)",
      paste(pos, collapse = ", "),
      paste(valid_dates[pos], collapse = ", ")
    ))
  }

  year_strs <- as.character(years)
  max_days <- vapply(seq_along(year_strs), function(i) {
    calendar_data[[year_strs[i]]][months[i]]
  }, numeric(1))

  bad_day <- which(days < 1L | days > max_days)
  if (length(bad_day) > 0L) {
    pos <- bad_day[seq_len(min(5L, length(bad_day)))]
    stop(sprintf(
      "Invalid day for the given month and year at position(s): %s (value: %s)",
      paste(pos, collapse = ", "),
      paste(valid_dates[pos], collapse = ", ")
    ))
  }

  # --- Vectorized Calculation ---
  # Reference: BS 1970-01-01 = AD 1913-04-13
  ref_ad_date <- as.Date("1913-04-13")
  cumulative_bs_days <- .pkg_cache$cumulative_bs_days
  cumulative_days_in_year <- .pkg_cache$cumulative_days_in_year

  # Days from full years since 1970
  year_indices <- years - 1970L
  total_days_from_years <- ifelse(year_indices == 0L, 0, cumulative_bs_days[year_indices])

  # Days from full months in current year
  total_days_from_months <- vapply(seq_along(year_strs), function(i) {
    cumulative_days_in_year[[year_strs[i]]][months[i]]
  }, numeric(1))

  # Total offset (day - 1 because BS 1970-01-01 is day 0 of the offset)
  total_offset <- total_days_from_years + total_days_from_months + days - 1L

  output_dates[non_na] <- ref_ad_date + total_offset
  output_dates
}


#' Convert Anno Domini (AD) date to Bikram Sambat (BS) date
#'
#' Converts one or more Gregorian (AD) dates to their BS equivalents.
#' This function is fully vectorized for high performance on large datasets.
#'
#' @param ad_date A character vector, \code{Date} vector, or \code{POSIXct}
#'   vector representing AD dates. \code{NA} values are preserved.
#'
#' @return A \code{\link{bs_date}} object of the equivalent BS dates.
#' @export
#'
#' @examples
#' ad_to_bs("2023-09-01")
#' ad_to_bs(as.Date("2023-09-01"))
#' ad_to_bs(c("2023-09-01", "2023-10-15", NA))
#'
#' @seealso \code{\link{bs_to_ad}} for converting BS to AD dates
ad_to_bs <- function(ad_date) {
  # Handle empty input
  if (length(ad_date) == 0L) return(bs_date(character(0)))
  if (all(is.na(ad_date))) return(bs_date(rep(NA_character_, length(ad_date))))

  output_dates <- rep(NA_character_, length(ad_date))
  non_na <- !is.na(ad_date)

  valid_dates <- ad_date[non_na]

  # Accept Date, POSIXct, or character
  if (inherits(valid_dates, "POSIXct")) {
    valid_dates <- as.Date(valid_dates)
  } else if (!inherits(valid_dates, "Date")) {
    valid_dates <- as.Date(gsub("/", "-", valid_dates))
  }

  # --- Validation ---
  min_date <- as.Date("1913-04-13")  # BS 1970-01-01
  max_date <- as.Date("2043-04-13")  # BS 2099-12-30

  bad <- which(valid_dates < min_date | valid_dates > max_date)
  if (length(bad) > 0L) {
    pos <- bad[seq_len(min(5L, length(bad)))]
    stop(sprintf(
      "Date must be between 1913-04-13 and 2043-04-13. Invalid at position(s): %s (value: %s)",
      paste(pos, collapse = ", "),
      paste(valid_dates[pos], collapse = ", ")
    ))
  }

  # --- Vectorized Calculation ---
  cumulative_bs_days <- .pkg_cache$cumulative_bs_days
  cumulative_days_in_year <- .pkg_cache$cumulative_days_in_year

  day_diff <- as.numeric(valid_dates - min_date)

  # Find BS year
  year_indices <- findInterval(day_diff, cumulative_bs_days, left.open = FALSE)
  bs_years <- 1970L + year_indices

  # Remaining days within the year
  prior_cumulative <- c(0, cumulative_bs_days)[year_indices + 1L]
  remaining_days <- day_diff - prior_cumulative + 1L

  year_strs <- as.character(bs_years)

  # Find month
  month_indices <- vapply(seq_along(year_strs), function(i) {
    findInterval(remaining_days[i] - 1L, cumulative_days_in_year[[year_strs[i]]])
  }, numeric(1))

  # Day within month
  bs_days <- vapply(seq_along(year_strs), function(i) {
    remaining_days[i] - cumulative_days_in_year[[year_strs[i]]][month_indices[i]]
  }, numeric(1))

  output_dates[non_na] <- sprintf("%04d-%02d-%02d", bs_years, month_indices, bs_days)
  bs_date(output_dates)
}
