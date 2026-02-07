test_that("set_background works", {
  p <- ggseg3d() |> set_background("black")
  expect_equal(p$x$options$backgroundColor, "#000000")

  p <- ggseg3d() |> set_background("#FF5733")
  expect_equal(p$x$options$backgroundColor, "#FF5733")

  p <- ggseg3d() |> set_background("white")
  expect_equal(p$x$options$backgroundColor, "#FFFFFF")
})

test_that("set_legend works", {
  p <- ggseg3d() |> set_legend(TRUE)
  expect_true(p$x$options$showLegend)

  p <- ggseg3d() |> set_legend(FALSE)
  expect_false(p$x$options$showLegend)
})

test_that("set_dimensions works", {
  p <- ggseg3d() |> set_dimensions(width = 800, height = 600)
  expect_equal(p$width, 800)
  expect_equal(p$height, 600)

  p <- ggseg3d() |> set_dimensions(width = 1200)
  expect_equal(p$width, 1200)
  expect_null(p$height)

  p <- ggseg3d() |> set_dimensions(height = 400)
  expect_null(p$width)
  expect_equal(p$height, 400)
})

test_that("set_edges works", {
  p <- ggseg3d() |> set_edges("red")
  expect_equal(p$x$meshes[[1]]$edgeColor, "#FF0000")
  expect_equal(p$x$meshes[[1]]$edgeWidth, 1)

  p <- ggseg3d() |> set_edges("#00FF00", width = 2)
  expect_equal(p$x$meshes[[1]]$edgeColor, "#00FF00")
  expect_equal(p$x$meshes[[1]]$edgeWidth, 2)

  p <- ggseg3d() |>
    set_edges("black") |>
    set_edges(NULL)
  expect_null(p$x$meshes[[1]]$edgeColor)
  expect_null(p$x$meshes[[1]]$edgeWidth)
})

test_that("set_flat_shading works", {
  p <- ggseg3d() |> set_flat_shading(TRUE)
  expect_true(p$x$options$flatShading)

  p <- ggseg3d() |> set_flat_shading(FALSE)
  expect_false(p$x$options$flatShading)

  p <- ggseg3d() |> set_flat_shading()
  expect_true(p$x$options$flatShading)
})

test_that("set_orthographic works", {
  p <- ggseg3d() |> set_orthographic(TRUE)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$frustumSize, 220)

  p <- ggseg3d() |> set_orthographic(FALSE)
  expect_false(p$x$options$orthographic)

  p <- ggseg3d() |> set_orthographic(TRUE, frustum_size = 300)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$frustumSize, 300)
})

test_that("additions reject non-ggseg3d objects", {
  fake_widget <- list(x = list())
  class(fake_widget) <- "htmlwidget"

  expect_error(set_background(fake_widget, "black"), "ggseg3d")
  expect_error(set_legend(fake_widget, TRUE), "ggseg3d")
  expect_error(set_dimensions(fake_widget, 800, 600), "ggseg3d")
  expect_error(set_edges(fake_widget, "black"), "ggseg3d")
  expect_error(set_flat_shading(fake_widget), "ggseg3d")
  expect_error(set_orthographic(fake_widget), "ggseg3d")
  expect_error(pan_camera(fake_widget, "left lateral"), "ggseg3d")
})

test_that("pan_camera validates input", {
  expect_error(
    ggseg3d() |> pan_camera(123),
    "character string or list"
  )
})

test_that("additions can be chained", {
  p <- ggseg3d() |>
    set_background("black") |>
    set_legend(FALSE) |>
    set_flat_shading(TRUE) |>
    set_orthographic(TRUE) |>
    pan_camera("left lateral")

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_equal(p$x$options$backgroundColor, "#000000")
  expect_false(p$x$options$showLegend)
  expect_true(p$x$options$flatShading)
  expect_true(p$x$options$orthographic)
  expect_equal(p$x$options$camera, "left lateral")
})
