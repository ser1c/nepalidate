# Package-level cached data for fast lookups
# Computed once at load time, used by all conversion functions

.pkg_cache <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {
  bs_years_char <- as.character(1970:2099)

  # Total days in each BS year
  total_days <- vapply(bs_years_char, function(y) calendar_data[[y]][13], numeric(1))

  # Cumulative days from BS 1970-01-01

  .pkg_cache$cumulative_bs_days <- cumsum(total_days)

  # Cumulative days within each year (for month lookup)
  .pkg_cache$cumulative_days_in_year <- lapply(calendar_data, function(yd) {
    cumsum(c(0, yd[1:11]))
  })
}
