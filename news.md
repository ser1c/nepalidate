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
