#' Find passed days in a BS year
#'
#' @param year Numeric BS year
#' @param month Numeric month (1-12)
#' @param day Numeric day
#'
#' @return Total number of days passed in the year
#' @keywords internal
find_passed_days_in_year <- function(year, month, day) {
  total_days <- 0
  year_str <- as.character(year)

  # Add days for completed months
  if (month > 1) {
    for (i in 1:(month - 1)) {
      total_days <- total_days + nepalidate::calendar_data[[year_str]][i]
    }
  }

  # Add days for current month (capped at month length)
  if (day <= nepalidate::calendar_data[[year_str]][month]) {
    total_days <- total_days + day
  } else {
    total_days <- total_days + nepalidate::calendar_data[[year_str]][month]
  }

  return(total_days)
}

#' Find BS date from total days
#'
#' @param year Numeric BS year
#' @param days Total number of days
#'
#' @return List with bs_year, bs_month, and bs_day
#' @keywords internal
find_bs_date_from_days <- function(year, days) {
  month <- 0
  year_str <- as.character(year)

  for (i in 1:12) {
    if (days <= nepalidate::calendar_data[[year_str]][i]) {
      month <- i
      break
    } else {
      days <- days - nepalidate::calendar_data[[year_str]][i]
    }
  }

  return(list(bs_year = year, bs_month = month, bs_day = days))
}

#' Get Nepali month name
#'
#' @param month_number Numeric month (1-12)
#' @param lang Language for month name ("en" for English, "ne" for Nepali)
#'
#' @return Character string with month name
#' @export
#'
#' @examples
#' get_nepali_month_name(1)  # "Baishakh"
#' get_nepali_month_name(1, "ne")  # "बैशाख"
get_nepali_month_name <- function(month_number, lang = "en") {
  if (month_number < 1 || month_number > 12) {
    stop("Month number must be between 1 and 12")
  }

  months_en <- c("Baishakh", "Jestha", "Ashadh", "Shrawan",
                 "Bhadra", "Ashwin", "Kartik", "Mangsir",
                 "Poush", "Magh", "Falgun", "Chaitra")

  months_ne <- c("बैशाख", "जेठ", "असार", "साउन",
                 "भदौ", "असोज", "कार्तिक", "मंसिर",
                 "पुष", "माघ", "फागुन", "चैत")

  if (lang == "ne") {
    return(months_ne[month_number])
  } else {
    return(months_en[month_number])
  }
}
