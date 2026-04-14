test_that("bs_to_ad returns Date objects", {
  result <- bs_to_ad("2080-05-15")
  expect_s3_class(result, "Date")
  expect_equal(result, as.Date("2023-09-01"))
})

test_that("bs_to_ad works correctly", {
  expect_equal(bs_to_ad("2080-05-15"), as.Date("2023-09-01"))
  expect_equal(bs_to_ad("2080-01-01"), as.Date("2023-04-14"))

  # Slash format
  expect_equal(bs_to_ad("2080/05/15"), as.Date("2023-09-01"))
})

test_that("bs_to_ad error messages show positions", {
  expect_error(
    bs_to_ad("2080-13-01"),
    "position"
  )
  expect_error(
    bs_to_ad("1969-01-01"),
    "position"
  )
  expect_error(
    bs_to_ad("2080-01-40"),
    "position"
  )
})

test_that("bs_to_ad handles boundary dates", {
  # First supported date

  expect_equal(
    bs_to_ad("1970-01-01"),
    as.Date("1913-04-13")
  )
})

test_that("bs_to_ad handles empty and all-NA input", {
  # Empty vector
  result <- bs_to_ad(character(0))
  expect_s3_class(result, "Date")
  expect_equal(length(result), 0L)

  # All NA
  result <- bs_to_ad(c(NA, NA))
  expect_equal(length(result), 2L)
  expect_true(all(is.na(result)))
})

test_that("ad_to_bs returns bs_date objects", {
  result <- ad_to_bs("2023-09-01")
  expect_s3_class(result, "bs_date")
  expect_equal(unclass(result), "2080-05-15")
})

test_that("ad_to_bs works correctly", {
  expect_equal(
    unclass(ad_to_bs("2023-09-01")),
    "2080-05-15"
  )
  expect_equal(
    unclass(ad_to_bs("2023-04-14")),
    "2080-01-01"
  )

  # Date object input
  expect_equal(
    unclass(ad_to_bs(as.Date("2023-09-01"))),
    "2080-05-15"
  )

  # POSIXct input (use UTC to avoid timezone-related day shift)
  expect_equal(
    unclass(ad_to_bs(as.POSIXct("2023-09-01", tz = "UTC"))),
    "2080-05-15"
  )
})

test_that("ad_to_bs error messages show positions", {
  expect_error(
    ad_to_bs("1900-01-01"),
    "position"
  )
  expect_error(
    ad_to_bs("2050-01-01"),
    "position"
  )
})

test_that("ad_to_bs handles empty and all-NA input", {
  result <- ad_to_bs(character(0))
  expect_s3_class(result, "bs_date")
  expect_equal(length(result), 0L)

  result <- ad_to_bs(c(NA, NA))
  expect_equal(length(result), 2L)
  expect_true(all(is.na(result)))
})

test_that("vectorized operations work correctly", {
  # bs_to_ad with vectors
  bs_dates <- c("2080-05-15", "2080-01-01", "2079-12-30")
  expected <- as.Date(c("2023-09-01", "2023-04-14", "2023-04-13"))
  expect_equal(bs_to_ad(bs_dates), expected)

  # ad_to_bs with vectors
  ad_dates <- c("2023-09-01", "2023-04-14", "2023-04-13")
  expected_bs <- c("2080-05-15", "2080-01-01", "2079-12-30")
  expect_equal(unclass(ad_to_bs(ad_dates)), expected_bs)

  # Date vectors
  date_vec <- as.Date(c("2023-09-01", "2023-04-14"))
  result <- ad_to_bs(date_vec)
  expect_equal(
    unclass(result),
    c("2080-05-15", "2080-01-01")
  )

  # NA handling
  dates_with_na <- c("2023-09-01", NA, "2023-04-14")
  result <- ad_to_bs(dates_with_na)
  expect_equal(unclass(result)[1], "2080-05-15")
  expect_true(is.na(result[2]))
  expect_equal(unclass(result)[3], "2080-01-01")
})

test_that("functions work with data frames", {
  df <- data.frame(
    ad_date = as.Date(c(
      "2023-01-01", "2023-06-15", "2023-12-31"
    )),
    stringsAsFactors = FALSE
  )

  df$bs_date <- ad_to_bs(df$ad_date)
  expect_equal(length(df$bs_date), 3)
  expect_true(all(!is.na(df$bs_date)))

  # Round-trip through data frame
  df$ad_back <- bs_to_ad(unclass(df$bs_date))
  expect_equal(df$ad_date, df$ad_back)
})

test_that("round-trip conversions work", {
  # BS -> AD -> BS
  bs <- "2080-05-15"
  ad <- bs_to_ad(bs)
  expect_equal(unclass(ad_to_bs(ad)), bs)

  # AD -> BS -> AD
  ad2 <- as.Date("2023-09-01")
  bs2 <- ad_to_bs(ad2)
  expect_equal(bs_to_ad(unclass(bs2)), ad2)

  # Round trip with vectors
  bs_dates <- c("2080-05-15", "2080-01-01", "2079-12-30")
  ad_dates <- bs_to_ad(bs_dates)
  bs_back <- ad_to_bs(ad_dates)
  expect_equal(unclass(bs_back), bs_dates)
})

test_that("get_nepali_month_name works correctly", {
  expect_equal(get_nepali_month_name(1), "Baishakh")
  expect_equal(get_nepali_month_name(12), "Chaitra")
  expect_equal(
    get_nepali_month_name(1, "ne"),
    "\u092c\u0948\u0936\u093e\u0916"
  )

  expect_error(
    get_nepali_month_name(0),
    "between 1 and 12"
  )
  expect_error(
    get_nepali_month_name(13),
    "between 1 and 12"
  )
})

test_that("get_nepali_month_name is vectorized", {
  result <- get_nepali_month_name(c(1, 4, 12))
  expect_equal(result, c("Baishakh", "Shrawan", "Chaitra"))

  result_ne <- get_nepali_month_name(c(1, 12), "ne")
  expect_equal(length(result_ne), 2)
})
