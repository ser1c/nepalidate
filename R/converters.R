#' Convert Bikram Sambat (BS) date to Anno Domini (AD) date
#'
#' @param bs_date A character string representing a BS date in "YYYY-MM-DD" or "YYYY/MM/DD" format
#'
#' @return A character string representing the equivalent AD date in "YYYY-MM-DD" format
#' @export
#'
#' @examples
#' bs_to_ad("2080-05-15")
#' bs_to_ad("2080/05/15")
#'
#' @seealso \code{\link{ad_to_bs}} for converting AD to BS dates
bs_to_ad <- function(bs_date) {
  # Handle different date formats
  bs_date <- gsub("/", "-", bs_date)
  date_parts <- as.numeric(strsplit(bs_date, "-")[[1]])

  # Validate input
  if (length(date_parts) < 3) {
    stop("Invalid date format. Use YYYY-MM-DD or YYYY/MM/DD")
  }

  year <- date_parts[1]
  month <- date_parts[2]
  day <- date_parts[3]

  # Validate date range
  if (year < 1970 || year > 2099) {
    stop("Year must be between 1970 and 2099")
  }

  if (month < 1 || month > 12) {
    stop("Month must be between 1 and 12")
  }

  year_str <- as.character(year)
  if (!year_str %in% names(nepalidate::calendar_data)) {
    stop("Calendar data not available for year ", year)
  }

  if (day < 1 || day > nepalidate::calendar_data[[year_str]][month]) {
    stop("Invalid day for the given month")
  }

  # Calculate day difference from reference date (BS 2026-09-18)
  day_diff <- 0
  passed_days <- find_passed_days_in_year(year, month, day)

  if (year > 2026) {
    # Add days for years after 2026
    for (i in 2027:(year - 1)) {
      i_str <- as.character(i)
      day_diff <- day_diff + nepalidate::calendar_data[[i_str]][13]
    }
    day_diff <- day_diff + passed_days + 102
  } else if (year < 2026) {
    # Subtract days for years before 2026
    for (i in (year + 1):2025) {
      i_str <- as.character(i)
      day_diff <- day_diff - nepalidate::calendar_data[[i_str]][13]
    }
    year_str <- as.character(year)
    day_diff <- day_diff - (nepalidate::calendar_data[[year_str]][13] - passed_days) - 264
  } else {
    # Year is 2026
    day_diff <- passed_days - 264
  }

  # Convert to AD date
  # Reference: BS 2026-09-18 = AD 1970-01-01
  ad_date <- as.Date("1970-01-01") + day_diff

  return(format(ad_date, "%Y-%m-%d"))
}

#' Convert Anno Domini (AD) date to Bikram Sambat (BS) date
#'
#' @param ad_date A character string representing an AD date in "YYYY-MM-DD" or "YYYY/MM/DD" format,
#'   or a Date object
#'
#' @return A character string representing the equivalent BS date in "YYYY-MM-DD" format
#' @export
#'
#' @examples
#' ad_to_bs("2023-09-01")
#' ad_to_bs("2023/09/01")
#' ad_to_bs(Sys.Date())
#'
#' @seealso \code{\link{bs_to_ad}} for converting BS to AD dates
ad_to_bs <- function(ad_date) {
  # Handle Date objects
  if (inherits(ad_date, "Date")) {
    ad_date <- format(ad_date, "%Y-%m-%d")
  }

  # Handle different date formats
  ad_date <- gsub("/", "-", ad_date)

  # Parse and validate date
  ad_date_obj <- as.Date(ad_date)

  # Check date range (1913-04-13 to 2043-04-13)
  min_date <- as.Date("1913-04-13")
  max_date <- as.Date("2043-04-13")

  if (ad_date_obj < min_date || ad_date_obj > max_date) {
    stop("Date must be between 1913-04-13 and 2043-04-13")
  }

  # Calculate days from reference date
  ref_date <- as.Date("1970-01-01")
  day_diff <- as.numeric(ad_date_obj - ref_date)

  year <- 2026
  bs_date <- NULL

  if (day_diff > 102) {
    # After BS 2026-12-15
    day_diff <- day_diff - 102

    while (day_diff > 0) {
      next_year_str <- as.character(year + 1)
      year_days <- nepalidate::calendar_data[[next_year_str]][13]

      if (day_diff <= year_days) {
        bs_date <- find_bs_date_from_days(year + 1, day_diff)
        break
      } else {
        day_diff <- day_diff - year_days
        year <- year + 1
      }
    }
  } else if (day_diff < -264) {
    # Before BS 2026-01-01
    day_diff <- -day_diff - 264

    while (day_diff > 0) {
      prev_year_str <- as.character(year - 1)
      year_days <- nepalidate::calendar_data[[prev_year_str]][13]

      if (day_diff <= year_days) {
        if (day_diff == 0) {
          prev_prev_year_str <- as.character(year - 2)
          bs_date <- find_bs_date_from_days(year - 2, nepalidate::calendar_data[[prev_prev_year_str]][13])
        } else {
          bs_date <- find_bs_date_from_days(year - 1, year_days - day_diff + 1)
        }
        break
      } else {
        day_diff <- day_diff - year_days
        year <- year - 1
      }
    }
  } else {
    # Within BS year 2026
    bs_date <- find_bs_date_from_days(2026, 264 + day_diff)
  }

  # Format output
  return(sprintf("%04d-%02d-%02d",
                 bs_date$bs_year,
                 bs_date$bs_month,
                 bs_date$bs_day))
}
