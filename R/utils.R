#' Get Nepali month name
#'
#' Returns the name of a Nepali (Bikram Sambat) month in English or Nepali.
#' Fully vectorized.
#'
#' @param month_number An integer vector of month numbers (1-12).
#' @param lang Language for month names: \code{"en"} for English (default),
#'   \code{"ne"} for Nepali (Devanagari).
#'
#' @return A character vector of month names.
#' @export
#'
#' @examples
#' get_nepali_month_name(1)
#' get_nepali_month_name(1, "ne")
#' get_nepali_month_name(c(1, 4, 12))
get_nepali_month_name <- function(month_number, lang = "en") {
  months_en <- c(
    "Baishakh", "Jestha", "Ashadh", "Shrawan",
    "Bhadra", "Ashwin", "Kartik", "Mangsir",
    "Poush", "Magh", "Falgun", "Chaitra"
  )

  months_ne <- c(
    "\u092c\u0948\u0936\u093e\u0916",
    "\u091c\u0947\u0920",
    "\u0905\u0938\u093e\u0930",
    "\u0938\u093e\u0913\u0928",
    "\u092d\u0926\u094c",
    "\u0905\u0938\u094b\u091c",
    "\u0915\u093e\u0930\u094d\u0924\u093f\u0915",
    "\u092e\u0902\u0938\u093f\u0930",
    "\u092a\u0941\u0937",
    "\u092e\u093e\u0918",
    "\u092b\u093e\u0917\u0941\u0928",
    "\u091a\u0948\u0924"
  )

  bad <- which(month_number < 1L | month_number > 12L)
  if (length(bad) > 0L) {
    stop(sprintf(
      "Month number must be between 1 and 12. Invalid at position(s): %s (value: %s)",
      paste(bad[seq_len(min(5L, length(bad)))], collapse = ", "),
      paste(month_number[bad[seq_len(min(5L, length(bad)))]], collapse = ", ")
    ))
  }

  if (lang == "ne") {
    return(months_ne[month_number])
  }
  months_en[month_number]
}
