# nepalidate

<!-- badges: start -->
[![R-CMD-check](https://github.com/ser1c/nepalidate/workflows/R-CMD-check/badge.svg)](https://github.com/ser1c/nepalidate/actions)
[![R-CMD-check](https://github.com/ser1c/nepalidate/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/ser1c/nepalidate/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

An R package for converting dates between the Nepali Bikram Sambat (BS) calendar and the Gregorian (AD) calendar.

## Installation

You can install the development version of nepalidate from GitHub:

```r
# install.packages("devtools")
devtools::install_github("ser1c/nepalidate")
```

# Usage
Convert BS to AD
```r
rlibrary(nepalidate)
```
# Convert BS date to AD
```r
bs_to_ad("2080-05-15")
#> [1] "2023-09-01"
```
# Also works with slash format
```r
bs_to_ad("2080/05/15")
#> [1] "2023-09-01"
```
# Convert AD to BS
```r
# Convert AD date to BS
ad_to_bs("2023-09-01")
#> [1] "2080-05-15"
```
# Works with Date objects too
```r
ad_to_bs(Sys.Date())
#> [1] "2081-09-06"  # (example output)
```
#Get Nepali Month Names
```r
get_nepali_month_name(1)
#> [1] "Baishakh"
```
# Get month name in Nepali
```r
get_nepali_month_name(1, "ne")
#> [1] "बैशाख"
```
# Date Range Support

BS dates: 1970-01-01 to 2099-12-30
AD dates: 1913-04-13 to 2043-04-13

Contributing
Contributions are welcome! Please feel free to submit a Pull Request.
