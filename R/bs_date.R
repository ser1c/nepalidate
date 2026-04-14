# R/bs_date.R - Lightweight S3 class for Bikram Sambat dates

#' Create a Bikram Sambat date object
#'
#' Constructs a \code{bs_date} object from a character vector of BS dates.
#' The object stores dates internally as character strings but provides
#' convenient methods for printing, formatting, arithmetic, and conversion.
#'
#' @param x A character vector of BS dates in "YYYY-MM-DD" format,
#'   or a \code{bs_date} object (returned as-is).
#'
#' @return A \code{bs_date} object.
#' @export
#'
#' @examples
#' d <- bs_date("2080-05-15")
#' print(d)
#'
#' # Vectorized
#' dates <- bs_date(c("2080-01-01", "2080-06-15", "2081-12-30"))
#' dates
#'
#' # Convert to AD
#' as.Date(dates)
#'
#' # Arithmetic
#' d + 30
#' d - 10
bs_date <- function(x) {
  if (inherits(x, "bs_date")) return(x)
  if (!is.character(x)) {
    stop("bs_date() expects a character vector in 'YYYY-MM-DD' format.")
  }
  structure(x, class = "bs_date")
}

#' Test if an object is a bs_date
#'
#' @param x An R object.
#' @return Logical.
#' @export
#'
#' @examples
#' is.bs_date(bs_date("2080-05-15"))
#' is.bs_date("2080-05-15")
is.bs_date <- function(x) {
  inherits(x, "bs_date")
}

#' @export
print.bs_date <- function(x, ...) {
  cat(format(x, ...), sep = "\n")
  invisible(x)
}

#' Format a bs_date object
#'
#' @param x A \code{bs_date} object.
#' @param format A format string. Supported tokens:
#'   \code{\%Y} (4-digit year), \code{\%m} (2-digit month),
#'   \code{\%d} (2-digit day), \code{\%B} (English month name),
#'   \code{\%b} (abbreviated English month name, first 3 letters).
#'   Default: \code{"\%Y-\%m-\%d"}.
#' @param ... Ignored.
#'
#' @return A character vector.
#' @export
#'
#' @examples
#' d <- bs_date("2080-05-15")
#' format(d)
#' format(d, "%d %B %Y")
format.bs_date <- function(x, format = "%Y-%m-%d", ...) {
  raw <- unclass(x)
  out <- rep(NA_character_, length(raw))
  non_na <- !is.na(raw)

  if (!any(non_na)) return(out)

  parts <- do.call(rbind, strsplit(raw[non_na], "-"))
  years <- parts[, 1]
  months_num <- as.integer(parts[, 2])
  days <- parts[, 3]

  month_names_full <- c(
    "Baishakh", "Jestha", "Ashadh", "Shrawan",
    "Bhadra", "Ashwin", "Kartik", "Mangsir",
    "Poush", "Magh", "Falgun", "Chaitra"
  )

  result <- format
  result <- gsub("%Y", years, result)
  result <- gsub("%m", parts[, 2], result)
  result <- gsub("%d", days, result)
  result <- gsub("%B", month_names_full[months_num], result)
  result <- gsub("%b", substr(month_names_full[months_num], 1, 3), result)

  out[non_na] <- result
  out
}

#' Convert bs_date to AD Date
#'
#' @param x A \code{bs_date} object.
#' @param ... Ignored.
#'
#' @return A \code{Date} vector.
#' @export
#'
#' @examples
#' d <- bs_date("2080-05-15")
#' as.Date(d)
as.Date.bs_date <- function(x, ...) {
  bs_to_ad(unclass(x))
}

#' Arithmetic for bs_date objects
#'
#' Add or subtract days from a \code{bs_date}, or compute the difference
#' in days between two \code{bs_date} objects.
#'
#' @param e1 A \code{bs_date} or numeric.
#' @param e2 A \code{bs_date} or numeric.
#'
#' @return For \code{+} and \code{-} with a numeric: a \code{bs_date}.
#'   For \code{-} between two \code{bs_date} objects: a numeric (days).
#' @export
#'
#' @examples
#' d <- bs_date("2080-05-15")
#' d + 30
#' d - 10
#' bs_date("2080-06-15") - bs_date("2080-05-15")
Ops.bs_date <- function(e1, e2) {
  op <- .Generic

  if (op == "+") {
    if (is.bs_date(e1) && is.numeric(e2)) {
      ad <- bs_to_ad(unclass(e1))
      return(ad_to_bs(ad + e2))
    }
    if (is.numeric(e1) && is.bs_date(e2)) {
      ad <- bs_to_ad(unclass(e2))
      return(ad_to_bs(ad + e1))
    }
    stop("Can only add a numeric (days) to a bs_date.")
  }

  if (op == "-") {
    if (is.bs_date(e1) && is.numeric(e2)) {
      ad <- bs_to_ad(unclass(e1))
      return(ad_to_bs(ad - e2))
    }
    if (is.bs_date(e1) && is.bs_date(e2)) {
      ad1 <- bs_to_ad(unclass(e1))
      ad2 <- bs_to_ad(unclass(e2))
      return(as.numeric(ad1 - ad2))
    }
    stop("Can only subtract a numeric (days) or another bs_date from a bs_date.")
  }

  if (op %in% c("==", "!=", "<", ">", "<=", ">=")) {
    ad1 <- bs_to_ad(unclass(e1))
    ad2 <- bs_to_ad(unclass(e2))
    return(get(op)(ad1, ad2))
  }

  stop(sprintf("Operator '%s' is not defined for bs_date.", op))
}

#' @export
c.bs_date <- function(...) {
  pieces <- lapply(list(...), unclass)
  bs_date(do.call(c, pieces))
}

#' @export
`[.bs_date` <- function(x, i) {
  bs_date(unclass(x)[i])
}

#' @export
`[<-.bs_date` <- function(x, i, value) {
  raw <- unclass(x)
  raw[i] <- unclass(value)
  bs_date(raw)
}

#' @export
length.bs_date <- function(x) {
  length(unclass(x))
}

#' @export
is.na.bs_date <- function(x) {
  is.na(unclass(x))
}

#' @export
rep.bs_date <- function(x, ...) {
  bs_date(rep(unclass(x), ...))
}
