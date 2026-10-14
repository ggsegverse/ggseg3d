test_that("Check glassbrain", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain()

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  n_meshes_base <- length(ggseg3d(atlas = aseg())$x$meshes)
  expect_gt(length(p$x$meshes), n_meshes_base)

  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left", colour = "red")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  glassbrain_meshes <- p$x$meshes[vapply(
    p$x$meshes,
    function(m) {
      grepl("glass brain", m$name, fixed = TRUE)
    },
    logical(1)
  )]
  expect_gt(length(glassbrain_meshes), 0)
  expect_identical(glassbrain_meshes[[1]]$colors[[1]], "#FF0000")
})

test_that("add_glassbrain with hex color", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left", colour = "#AABBCC")

  glassbrain_meshes <- p$x$meshes[vapply(
    p$x$meshes,
    function(m) {
      grepl("glass brain", m$name, fixed = TRUE)
    },
    logical(1)
  )]

  expect_identical(glassbrain_meshes[[1]]$colors[[1]], "#AABBCC")
})

test_that("add_glassbrain with custom opacity", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left", opacity = 0.5)

  glassbrain_meshes <- p$x$meshes[vapply(
    p$x$meshes,
    function(m) {
      grepl("glass brain", m$name, fixed = TRUE)
    },
    logical(1)
  )]

  expect_equal(glassbrain_meshes[[1]]$opacity, 0.5)
})

test_that("add_glassbrain errors on non-ggseg3d object", {
  expect_error(
    add_glassbrain(list()),
    "ggseg3d"
  )
})

test_that("add_glassbrain with both hemispheres", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = c("left", "right"))

  glassbrain_meshes <- p$x$meshes[vapply(
    p$x$meshes,
    function(m) {
      grepl("glass brain", m$name, fixed = TRUE)
    },
    logical(1)
  )]

  expect_length(glassbrain_meshes, 2)
})

test_that("add_glassbrain with inflated surface", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left", surface = "inflated")

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("add_glassbrain works with white surface", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = "left", surface = "white")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("add_glassbrain accepts the lh/rh hemisphere spellings", {
  p <- ggseg3d(hemisphere = "left")
  n_before <- length(p$x$meshes)

  expect_length(add_glassbrain(p, hemisphere = "lh")$x$meshes, n_before + 1L)
  expect_length(
    add_glassbrain(p, hemisphere = c("lh", "rh"))$x$meshes,
    n_before + 2L
  )
})

test_that("add_glassbrain rejects an unknown hemisphere name", {
  p <- ggseg3d(hemisphere = "left")

  expect_error(add_glassbrain(p, hemisphere = "lefty"), "lefty")
})
