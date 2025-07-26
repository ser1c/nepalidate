# Updated tests/testthat/test-converters.R

test_that("bs_to_ad works correctly", {
  # Test known conversions
  expect_equal(bs_to_ad("2080-05-15"), "2023-09-01")
  expect_equal(bs_to_ad("2080-01-01"), "2023-04-14")

  # Test with slash format
  expect_equal(bs_to_ad("2080/05/15"), "2023-09-01")

  # Test error cases
  expect_error(bs_to_ad("2080-13-01"), "Month must be between 1 and 12")
  expect_error(bs_to_ad("1969-01-01"), "Year must be between 1970 and 2099")
  expect_error(bs_to_ad("2080-01-40"), regexp = "Invalid day")
})

test_that("ad_to_bs works correctly", {
  # Test known conversions
  expect_equal(ad_to_bs("2023-09-01"), "2080-05-15")
  expect_equal(ad_to_bs("2023-04-14"), "2080-01-01")

  # Test with Date object
  test_date <- as.Date("2023-09-01")
  expect_equal(ad_to_bs(test_date), "2080-05-15")

  # Test error cases
  expect_error(ad_to_bs("1900-01-01"), "Date must be between 1913-04-13 and 2043-04-13")
  expect_error(ad_to_bs("2050-01-01"), "Date must be between 1913-04-13 and 2043-04-13")
})

test_that("vectorized operations work correctly", {
  # Test bs_to_ad with vectors
  bs_dates <- c("2080-05-15", "2080-01-01", "2079-12-30")
  expected_ad <- c("2023-09-01", "2023-04-14", "2023-04-13")
  expect_equal(bs_to_ad(bs_dates), expected_ad)
  
  # Test ad_to_bs with vectors  
  ad_dates <- c("2023-09-01", "2023-04-14", "2023-04-13")
  expected_bs <- c("2080-05-15", "2080-01-01", "2079-12-30")
  expect_equal(ad_to_bs(ad_dates), expected_bs)
  
  # Test with Date vectors
  date_vec <- as.Date(c("2023-09-01", "2023-04-14"))
  expect_equal(ad_to_bs(date_vec), c("2080-05-15", "2080-01-01"))
  
  # Test with NA values
  dates_with_na <- c("2023-09-01", NA, "2023-04-14")
  result <- ad_to_bs(dates_with_na)
  expect_equal(result[1], "2080-05-15")
  expect_true(is.na(result[2]))
  expect_equal(result[3], "2080-01-01")
})

test_that("functions work with data frames", {
  # Create test data frame
  df <- data.frame(
    ad_date = as.Date(c("2023-01-01", "2023-06-15", "2023-12-31")),
    stringsAsFactors = FALSE
  )
  
  # Test ad_to_bs with data frame column
  df$bs_date <- ad_to_bs(df$ad_date)
  expect_equal(length(df$bs_date), 3)
  expect_true(all(!is.na(df$bs_date)))
  
  # Test bs_to_ad with data frame column
  df$ad_converted <- bs_to_ad(df$bs_date)
  expect_equal(format(df$ad_date, "%Y-%m-%d"), df$ad_converted)
  
  # Test with character dates in data frame
  df2 <- data.frame(
    date_str = c("2023-01-01", "2023-06-15", "2023-12-31"),
    stringsAsFactors = FALSE
  )
  df2$bs_date <- ad_to_bs(df2$date_str)
  expect_equal(length(df2$bs_date), 3)
})

test_that("round-trip conversions work", {
  # BS to AD and back
  bs_date <- "2080-05-15"
  ad_date <- bs_to_ad(bs_date)
  expect_equal(ad_to_bs(ad_date), bs_date)

  # AD to BS and back
  ad_date2 <- "2023-09-01"
  bs_date2 <- ad_to_bs(ad_date2)
  expect_equal(bs_to_ad(bs_date2), ad_date2)
  
  # Round trip with vectors
  bs_dates <- c("2080-05-15", "2080-01-01", "2079-12-30")
  ad_dates <- bs_to_ad(bs_dates)
  bs_dates_back <- ad_to_bs(ad_dates)
  expect_equal(bs_dates, bs_dates_back)
})

test_that("get_nepali_month_name works correctly", {
  expect_equal(get_nepali_month_name(1), "Baishakh")
  expect_equal(get_nepali_month_name(12), "Chaitra")
  expect_equal(get_nepali_month_name(1, "ne"), "बैशाख")

  expect_error(get_nepali_month_name(0), "Month number must be between 1 and 12")
  expect_error(get_nepali_month_name(13), "Month number must be between 1 and 12")
})