test_that("bs_to_ad works correctly", {
  # Test known conversions
  expect_equal(bs_to_ad("2080-05-15"), "2023-09-01")
  expect_equal(bs_to_ad("2080-01-01"), "2023-04-14")

  # Test with slash format
  expect_equal(bs_to_ad("2080/05/15"), "2023-09-01")

  # Test error cases
  expect_error(bs_to_ad("2080-13-01"), "Month must be between 1 and 12")
  expect_error(bs_to_ad("1969-01-01"), "Year must be between 1970 and 2099")
  expect_error(bs_to_ad("2080-01-40"), "Invalid day for the given month")
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

test_that("round-trip conversions work", {
  # BS to AD and back
  bs_date <- "2080-05-15"
  ad_date <- bs_to_ad(bs_date)
  expect_equal(ad_to_bs(ad_date), bs_date)

  # AD to BS and back
  ad_date2 <- "2023-09-01"
  bs_date2 <- ad_to_bs(ad_date2)
  expect_equal(bs_to_ad(bs_date2), ad_date2)
})

test_that("get_nepali_month_name works correctly", {
  expect_equal(get_nepali_month_name(1), "Baishakh")
  expect_equal(get_nepali_month_name(12), "Chaitra")
  expect_equal(get_nepali_month_name(1, "ne"), "बैशाख")

  expect_error(get_nepali_month_name(0), "Month number must be between 1 and 12")
  expect_error(get_nepali_month_name(13), "Month number must be between 1 and 12")
})
