# nepalidate

<!-- badges: start -->
[![R-CMD-check](https://github.com/ser1c/nepalidate/workflows/R-CMD-check/badge.svg)](https://github.com/ser1c/nepalidate/actions)
<!-- badges: end -->

An R package for converting dates between the Nepali Bikram Sambat (BS) calendar and the Gregorian (AD) calendar. The package supports vectorized operations, making it easy to work with data frames and date columns.

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

# Convert BS to AD
bs_to_ad("2080-05-15")
#> [1] "2023-09-01"

# Convert AD to BS
ad_to_bs("2023-09-01")
#> [1] "2080-05-15"

# Works with Date objects
ad_to_bs(Sys.Date())
#> [1] "2081-10-12"  # (example output)
```

### Working with Vectors and Data Frames

The package is designed to work seamlessly with vectors and data frame columns:

```r
# Convert multiple dates at once
dates <- c("2023-01-01", "2023-06-15", "2023-12-31")
ad_to_bs(dates)
#> [1] "2079-09-16" "2080-03-01" "2080-09-15"

# Work with data frames
df <- data.frame(
  id = 1:3,
  reg_date = as.Date(c("2023-01-15", "2023-06-20", "2023-11-10"))
)

# Add BS date column
df$bs_date <- ad_to_bs(df$reg_date)
print(df)
#>   id   reg_date    bs_date
#> 1  1 2023-01-15 2079-10-01
#> 2  2 2023-06-20 2080-03-06
#> 3  3 2023-11-10 2080-07-24
```

### Get Nepali Month Names

```r
# Get month name in English
get_nepali_month_name(1)
#> [1] "Baishakh"

# Get month name in Nepali
get_nepali_month_name(1, "ne")
#> [1] "बैशाख"
```

### Handling NA Values

The functions properly handle NA values in vectors:

```r
dates_with_na <- c("2023-01-01", NA, "2023-12-31")
ad_to_bs(dates_with_na)
#> [1] "2079-09-16" NA           "2080-09-15"
```

## Date Range Support

- **BS dates**: 1970-01-01 to 2099-12-30
- **AD dates**: 1913-04-13 to 2043-04-13

## Examples

### Creating a Calendar Mapping

```r
# Generate a month of calendar mappings
dates <- seq(as.Date("2023-04-01"), as.Date("2023-04-30"), by = "day")
calendar <- data.frame(
  ad_date = dates,
  bs_date = ad_to_bs(dates),
  day = weekdays(dates)
)
head(calendar)
```

### Working with dplyr

```r
library(dplyr)

df %>%
  mutate(
    bs_date = ad_to_bs(reg_date),
    bs_year = substr(bs_date, 1, 4),
    bs_month = as.numeric(substr(bs_date, 6, 7)),
    bs_month_name = sapply(bs_month, get_nepali_month_name)
  )
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Calendar data based on official Nepali calendar information
- Conversion algorithm adapted from JavaScript implementations