# nepalidate

<!-- badges: start -->
[![R-CMD-check](https://github.com/ser1c/nepalidate/workflows/R-CMD-check/badge.svg)](https://github.com/ser1c/nepalidate/actions)
<!-- badges: end -->

An R package for converting dates between the Nepali Bikram Sambat (BS) calendar and the Gregorian (AD) calendar. Functions are vectorized for use with data frames and vectors. Includes a lightweight `bs_date` S3 class with formatting, arithmetic, and comparison support.

## Installation

You can install the development version of nepalidate from GitHub:

```r
# install.packages("devtools")
devtools::install_github("ser1c/nepalidate")
```

## Usage

### Basic Conversion

```r
library(nepalidate)

# Convert BS to AD (returns a Date object)
bs_to_ad("2080-05-15")
#> [1] "2023-09-01"

# Convert AD to BS (returns a bs_date object)
ad_to_bs("2023-09-01")
#> [1] 2080-05-15

# Works with Date objects and POSIXct
ad_to_bs(Sys.Date())
ad_to_bs(Sys.time())
```

### The bs_date Class

`ad_to_bs()` returns a `bs_date` object with useful methods:

```r
d <- bs_date("2080-05-15")

# Format with month names
format(d, "%d %B %Y")
#> [1] "15 Bhadra 2080"

# Arithmetic (add/subtract days)
d + 30
d - 10

# Difference between dates (in days)
bs_date("2080-06-15") - bs_date("2080-05-15")

# Comparison
bs_date("2080-06-01") > bs_date("2080-05-15")
#> [1] TRUE

# Convert to AD Date
as.Date(d)
#> [1] "2023-09-01"
```

### Working with Vectors and Data Frames

```r
# Convert multiple dates at once
dates <- c("2023-01-01", "2023-06-15", "2023-12-31")
ad_to_bs(dates)
#> [1] 2079-09-16 2080-03-01 2080-09-15

# Work with data frames
df <- data.frame(
  id = 1:3,
  reg_date = as.Date(c("2023-01-15", "2023-06-20", "2023-11-10"))
)
df$bs_date <- ad_to_bs(df$reg_date)
```

### Get Nepali Month Names

```r
# Vectorized
get_nepali_month_name(c(1, 5, 12))
#> [1] "Baishakh" "Bhadra"   "Chaitra"

# Nepali script
get_nepali_month_name(1, "ne")
#> [1] "बैशाख"
```

### Handling NA Values

```r
dates_with_na <- c("2023-01-01", NA, "2023-12-31")
ad_to_bs(dates_with_na)
#> [1] 2079-09-16 NA         2080-09-15
```

## Date Range Support

- **BS dates**: 1970-01-01 to 2099-12-30
- **AD dates**: 1913-04-13 to 2043-04-13

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Calendar data based on official Nepali calendar information
- Conversion algorithm adapted from JavaScript implementations
