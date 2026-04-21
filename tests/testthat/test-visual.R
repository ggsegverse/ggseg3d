# Data-level visual regression tests.
#
# These snapshot a textual summary of every mesh produced by ggseg3d so we
# catch regressions in coordinates (hemisphere overlap, axis mix-ups),
# mesh counts, and colour mapping without relying on WebGL rendering.
# See helper-visual.R for the summary helper.

test_that("dk cortical atlas produces stable mesh layout", {
  p <- ggseg3d(hemisphere = c("left", "right"))
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("dk single hemisphere has medial edge at midline", {
  lh <- ggseg3d(hemisphere = "left")
  rh <- ggseg3d(hemisphere = "right")
  expect_snapshot(print(widget_summary(lh), row.names = FALSE))
  expect_snapshot(print(widget_summary(rh), row.names = FALSE))
})

test_that("dk pial surface produces stable mesh layout", {
  skip_if_not_installed("ggseg.meshes")
  p <- ggseg3d(hemisphere = c("left", "right"), surface = "pial")
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("aseg subcortical atlas produces stable mesh layout", {
  p <- ggseg3d(atlas = aseg())
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("cerebellar atlas produces stable mesh layout", {
  p <- ggseg3d(atlas = make_test_cerebellar_atlas())
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("cortical + glassbrain composes as expected", {
  p <- ggseg3d(hemisphere = c("left", "right")) |>
    add_glassbrain(hemisphere = c("left", "right"), opacity = 0.2)
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("aseg + glassbrain composes as expected", {
  p <- ggseg3d(atlas = aseg()) |>
    add_glassbrain(hemisphere = c("left", "right"), opacity = 0.15)
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})

test_that("cerebellar + glassbrain composes as expected", {
  p <- ggseg3d(atlas = make_test_cerebellar_atlas()) |>
    add_glassbrain(hemisphere = c("left", "right"), opacity = 0.15)
  expect_snapshot(print(widget_summary(p), row.names = FALSE))
})
