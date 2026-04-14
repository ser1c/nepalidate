# nepalidate 1.1.0

## New features
* **`bs_date` S3 class**: `ad_to_bs()` now returns a `bs_date` object with `print()`, `format()`, `as.Date()`, arithmetic (`+`, `-`), comparison (`<`, `==`, etc.), and subsetting methods.
* **`bs_to_ad()` returns `Date`**: Now returns a proper `Date` vector instead of character, enabling direct date arithmetic.
* **`POSIXct` support**: `ad_to_bs()` now accepts `POSIXct` input in addition to `Date` and character.
* **Vectorized `get_nepali_month_name()`**: Now accepts integer vectors, not just scalars.
* **`format.bs_date()`**: Format BS dates with tokens like `%Y`, `%m`, `%d`, `%B` (month name), `%b` (abbreviated).

## Improvements
* **Cached pre-computation**: Calendar lookup tables are computed once at package load, not on every function call. Significant speedup for repeated conversions.
* **Informative error messages**: Validation errors now report which position(s) and value(s) are invalid.
* **Removed dead code**: Internal helper functions `find_passed_days_in_year()` and `find_bs_date_from_days()` removed (unused since v1.0.0).

## Documentation
* Added introductory vignette (`vignette("introduction")`)
* Improved `@source` documentation for `calendar_data`

---

# nepalidate 1.0.0

This release marks a major leap in performance and efficiency.

## Major Improvements
* **Complete Performance Overhaul**: The core conversion functions (`ad_to_bs` and `bs_to_ad`) have been completely refactored to be fully vectorized.
* **Blazing Fast Speed**: Operations on large datasets (e.g., millions of rows in a `data.table`) are now dramatically faster, moving from minutes to seconds.
* **Removed Redundancy**: The internal `_single` helper functions have been removed, resulting in a cleaner and more efficient codebase.

---

# nepalidate 0.2.0

## Major improvements
* Added vectorized support for `bs_to_ad()` and `ad_to_bs()` functions
* Functions now work seamlessly with data frame columns and vectors
* Added proper NA handling in vectorized operations

## Bug fixes
* Fixed error when using functions with data frame columns: "Error in ad_date_obj < min_date || ad_date_obj > max_date : 'length = X' in coercion to 'logical(1)'"

## New features
* Internal functions `bs_to_ad_single()` and `ad_to_bs_single()` for handling individual date conversions

## Documentation
* Updated examples to show vectorized usage
* Added data frame examples in documentation
* Updated README with comprehensive examples

# nepalidate 0.1.0

* Initial release
* Added `bs_to_ad()` function to convert BS dates to AD dates
* Added `ad_to_bs()` function to convert AD dates to BS dates
* Added `get_nepali_month_name()` function to get Nepali month names in English or Nepali
* Support for BS years 1970-2099
* Support for AD dates from 1913-04-13 to 2043-04-13
* Comprehensive test suite
* Full documentation with examples
