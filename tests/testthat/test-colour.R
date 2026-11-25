test_that("apply_colour_palette handles numeric data", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    my_value = c(1, 2, 3),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#CCCCCC"
  )

  expect_true(result$is_numeric)
  expect_identical(result$fill, "new_col")
  expect_identical(result$data_min, 1)
  expect_identical(result$data_max, 3)
  expect_true(all(grepl("^#", result$data$colour)))
})

test_that("apply_colour_palette handles categorical data", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    colour = c("#FF0000", "#00FF00", "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#CCCCCC")

  expect_false(result$is_numeric)
  expect_identical(result$fill, "colour")
})

test_that("apply_colour_palette handles NA values", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    colour = c("#FF0000", NA, "#0000FF"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#AABBCC")

  expect_identical(result$data$colour[2], "#AABBCC")
})

test_that("apply_colour_palette converts named colors to hex", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    colour = c("red", "blue"),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(atlas_data, "colour", NULL, "#CCCCCC")

  expect_identical(result$data$colour[1], "#FF0000")
  expect_identical(result$data$colour[2], "#0000FF")
})

test_that("apply_colour_palette handles single constant value", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    my_value = c(5, 5),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#CCCCCC"
  )

  expect_true(result$is_numeric)
  expect_identical(result$data_min, result$data_max)
})

test_that("a single matched value leaves unmatched regions NA", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    my_value = c(5, NA),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#AABBCC"
  )

  expect_identical(result$data$new_col, c("blue", NA))
  expect_identical(result$data$colour, c("#0000FF", "#AABBCC"))
})

test_that("apply_colour_palette fades only regions without data", {
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    my_value = c(1, 3, NA),
    stringsAsFactors = FALSE
  )

  result <- apply_colour_palette(
    atlas_data,
    "my_value",
    c("blue", "red"),
    "#CCCCCC",
    na_alpha = 0.25
  )

  expect_identical(result$data$alpha, c(1, 1, 0.25))
})

test_that("apply_colour_palette rejects an out-of-range na_alpha", {
  atlas_data <- data.frame(
    label = "a",
    my_value = 1,
    stringsAsFactors = FALSE
  )

  expect_error(
    apply_colour_palette(atlas_data, "my_value", NULL, "#CCCCCC", 2),
    "between 0 and 1"
  )
  expect_error(
    apply_colour_palette(atlas_data, "my_value", NULL, "#CCCCCC", NA),
    "between 0 and 1"
  )
})

test_that("legitimately missing values do not read as outside the palette", {
  # The normal case: a few regions carry data and the rest of the atlas is NA.
  # Counting those NAs as out-of-range warned on every ordinary plot.
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    value = c(0.5, 2, NA),
    stringsAsFactors = FALSE
  )

  expect_no_warning(
    apply_colour_palette(atlas_data, "value", NULL, "darkgrey")
  )
})


test_that("a named palette narrower than the data warns", {
  # Two out-of-range values, so the plural inflection is exercised too.
  atlas_data <- data.frame(
    label = c("a", "b", "c"),
    value = c(0.5, 9, 12),
    stringsAsFactors = FALSE
  )

  expect_warning(
    result <- apply_colour_palette(
      atlas_data,
      "value",
      c("#ff0000" = 0, "#0000ff" = 1),
      "darkgrey"
    ),
    "values fall outside the palette range"
  )

  # The out-of-range value is drawn in na_colour, which is why it has to be
  # said: nothing else distinguishes it from a region with no data.
  expect_identical(result$data$colour[2], col2hex("darkgrey"))
})
