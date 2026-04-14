test_that("bs_date constructor works", {
  d <- bs_date("2080-05-15")
  expect_s3_class(d, "bs_date")

  # Idempotent
  expect_identical(bs_date(d), d)

  # Rejects non-character
  expect_error(bs_date(123))
})

test_that("is.bs_date works", {
  expect_true(is.bs_date(bs_date("2080-05-15")))
  expect_false(is.bs_date("2080-05-15"))
})

test_that("format.bs_date works", {
  d <- bs_date("2080-05-15")

  expect_equal(format(d), "2080-05-15")
  expect_equal(format(d, "%d %B %Y"), "15 Bhadra 2080")
  expect_equal(format(d, "%b %Y"), "Bha 2080")

  # NA handling
  d2 <- bs_date(c("2080-05-15", NA))
  result <- format(d2)
  expect_equal(result[1], "2080-05-15")
  expect_true(is.na(result[2]))
})

test_that("as.Date.bs_date works", {
  d <- bs_date("2080-05-15")
  result <- as.Date(d)
  expect_s3_class(result, "Date")
  expect_equal(result, as.Date("2023-09-01"))
})

test_that("bs_date arithmetic works", {
  d <- bs_date("2080-05-15")

  # Add days
  d2 <- d + 30
  expect_s3_class(d2, "bs_date")
  ad_original <- as.Date(d)
  ad_plus30 <- as.Date(d2)
  expect_equal(
    as.numeric(ad_plus30 - ad_original), 30
  )

  # Subtract days
  d3 <- d - 10
  ad_minus10 <- as.Date(d3)
  expect_equal(
    as.numeric(ad_original - ad_minus10), 10
  )

  # Numeric + bs_date
  d4 <- 5 + d
  expect_s3_class(d4, "bs_date")

  # Difference between two bs_dates
  diff <- bs_date("2080-06-15") - bs_date("2080-05-15")
  expect_true(is.numeric(diff))
  expect_true(diff > 0)
})

test_that("bs_date comparison works", {
  d1 <- bs_date("2080-05-15")
  d2 <- bs_date("2080-06-15")

  expect_true(d2 > d1)
  expect_true(d1 < d2)
  expect_true(d1 == d1)
  expect_true(d1 != d2)
  expect_true(d1 <= d1)
  expect_true(d2 >= d1)
})

test_that("bs_date subsetting works", {
  dates <- bs_date(c("2080-01-01", "2080-06-15", "2081-12-30"))

  expect_s3_class(dates[1], "bs_date")
  expect_equal(unclass(dates[1]), "2080-01-01")
  expect_equal(length(dates[1:2]), 2L)
})

test_that("c.bs_date works", {
  d1 <- bs_date("2080-01-01")
  d2 <- bs_date("2080-06-15")
  combined <- c(d1, d2)

  expect_s3_class(combined, "bs_date")
  expect_equal(length(combined), 2L)
})

test_that("is.na.bs_date works", {
  d <- bs_date(c("2080-01-01", NA, "2080-06-15"))
  expect_equal(is.na(d), c(FALSE, TRUE, FALSE))
})
