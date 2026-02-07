test_that("Check that ggseg3d is working", {
  p <- ggseg3d()
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true("meshes" %in% names(p$x))
  expect_true("options" %in% names(p$x))
  expect_true(length(p$x$meshes) > 0)
  rm(p)

  p <- ggseg3d(atlas = "aseg")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)

  expect_error(ggseg3d(atlas = hhj), "object 'hhj")

  expect_warning(
    ggseg3d(
      .data = data.frame(
        region = c("transverse tempral", "insula",
                   "precentral", "superior parietal"),
        p = sample(seq(0, .5, .001), 4),
        stringsAsFactors = FALSE
      ),
      colour = "p"
    )
  )

  someData <- data.frame(
    region = c("transverse temporal", "insula",
               "precentral", "superior parietal"),
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
    colour = "p", text = "p", palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(!is.null(p$x$colorbar))
  expect_true(p$x$options$showLegend)

  p_hidden <- p |> set_legend(FALSE)
  expect_false(p_hidden$x$options$showLegend)

  p_sized <- ggseg3d() |> set_dimensions(width = 800, height = 600)
  expect_equal(p_sized$width, 800)
  expect_equal(p_sized$height, 600)
})

test_that("ggseg3d works with aseg subcortical atlas", {
  p <- ggseg3d(atlas = aseg)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})

test_that("ggseg3d with left hemisphere only", {
  p <- ggseg3d(hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})

test_that("ggseg3d with inflated surface", {
  p <- ggseg3d(hemisphere = "left", surface = "inflated")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d handles edge_by parameter", {
  someData <- data.frame(
    region = c("transverse temporal", "insula",
               "precentral", "superior parietal"),
    lobe = c("temporal", "insular", "frontal", "parietal"),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = someData,
    hemisphere = "left",
    edge_by = "lobe"
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d default colorbar is present", {
  p <- ggseg3d()
  expect_true(!is.null(p$x$colorbar) || p$x$colorbar$type == "discrete")
})

test_that("ggseg3d with custom palette", {
  someData <- data.frame(
    region = c("transverse temporal", "insula"),
    p = c(0.1, 0.9),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = someData,
    hemisphere = "left",
    colour = "p",
    palette = c("blue" = 0, "white" = 0.5, "red" = 1)
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_equal(p$x$colorbar$type, "continuous")
})

test_that("ggseg3d with na_colour and na_alpha", {
  p <- ggseg3d(hemisphere = "left", na_colour = "red", na_alpha = 0.5)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with label parameter", {
  p <- ggseg3d(hemisphere = "left", label = "label")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with both hemispheres", {
  p <- ggseg3d(hemisphere = c("left", "right"))
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) >= 2)
})

test_that("ggseg3d with atlas object instead of string", {
  p <- ggseg3d(atlas = dk, hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d unified atlas without user data", {
  p <- ggseg3d(atlas = dk, hemisphere = "left", .data = NULL)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with aseg mesh atlas", {
  p <- ggseg3d(atlas = aseg, hemisphere = "subcort")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})
