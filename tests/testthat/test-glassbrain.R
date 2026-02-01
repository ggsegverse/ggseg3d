test_that("Check glassbrain", {
  p <- ggseg3d(atlas = aseg_3d) |>
    add_glassbrain()

  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  n_meshes_base <- length(ggseg3d(atlas = aseg_3d)$x$meshes)
  expect_true(length(p$x$meshes) > n_meshes_base)

  p <- ggseg3d(atlas = aseg_3d) |>
    add_glassbrain(hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  p <- ggseg3d(atlas = aseg_3d) |>
    add_glassbrain(hemisphere = "left", colour = "red")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  glassbrain_meshes <- p$x$meshes[sapply(p$x$meshes, function(m) {
    m$name == "cerebral cortex"
  })]
  expect_true(length(glassbrain_meshes) > 0)
  expect_equal(glassbrain_meshes[[1]]$colors[[1]], "#FF0000")
})
