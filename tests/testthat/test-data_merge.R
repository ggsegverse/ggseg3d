test_that("data_merge works with unified atlas", {
  atlas_data <- ggseg.formats::atlas_sf(dk())

  some_data <- data.frame(
    region = c(
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal"
    ),
    p = sample(seq(0, .5, .001), 4),
    stringsAsFactors = FALSE
  )

  merged <- dplyr::left_join(atlas_data, some_data, by = "region")

  expect_true("p" %in% names(merged))
  expect_true("region" %in% names(merged))
  expect_true("hemi" %in% names(merged))
})
