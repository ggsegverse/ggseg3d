test_that("Check that ggseg3d is working", {
  p <- ggseg3d()
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true("meshes" %in% names(p$x))
  expect_true("options" %in% names(p$x))
  expect_true(length(p$x$meshes) > 0)
  rm(p)

  p <- ggseg3d(atlas = "aseg_3d")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)

  dk <- data.frame(
    .long = double(),
    .lat = double(),
    .id = character(),
    region = as.character(),
    hemi = character(),
    side = character()
  )
  expect_error(ggseg3d(atlas = dk), "This is not a 3d atlas")
  expect_error(ggseg3d(atlas = hhj), "object 'hhj")
  expect_error(ggseg3d(atlas = dk_3d, hemisphere = "hi"), "hemisphere")


  expect_warning(
    ggseg3d(
      .data = data.frame(
        region = c("transverse tempral", "insula", "precentral", "superior parietal"),
        p = sample(seq(0, .5, .001), 4),
        stringsAsFactors = FALSE
      ),
      colour = "p"
    )
  )

  someData <- data.frame(
    region = c("transverse temporal", "insula", "precentral", "superior parietal"),
    p = sample(seq(0, .5, .001), 4),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = someData,
    colour = "p", text = "p", palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  p <- ggseg3d(
    .data = someData,
    colour = "p", text = "p", palette = c("black", "white"),
    show.legend = TRUE
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(!is.null(p$x$colorbar))

  expect_error(ggseg3d(atlas = aseg_3d, surface = "white"), "no surface")
})
