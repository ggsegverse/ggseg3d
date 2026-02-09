options(rgl.useNULL = TRUE)

test_that("camera_preset_to_position returns correct vectors", {
  expect_equal(camera_preset_to_position("left lateral"), c(-350, 0, 0))
  expect_equal(camera_preset_to_position("right lateral"), c(350, 0, 0))
  expect_equal(camera_preset_to_position("left medial"), c(350, 0, 0))
  expect_equal(camera_preset_to_position("right medial"), c(-350, 0, 0))
  expect_equal(camera_preset_to_position("left superior"), c(-120, 0, 330))
  expect_equal(camera_preset_to_position("right inferior"), c(120, 0, -330))
  expect_equal(camera_preset_to_position("left anterior"), c(-120, 330, 0))
  expect_equal(camera_preset_to_position("right posterior"), c(120, -330, 0))
})

test_that("camera_preset_to_position accepts underscore variants", {
  expect_equal(
    camera_preset_to_position("left_lateral"),
    camera_preset_to_position("left lateral")
  )
  expect_equal(
    camera_preset_to_position("right_superior"),
    camera_preset_to_position("right superior")
  )
})

test_that("camera_preset_to_position errors on unknown preset", {
  expect_error(
    camera_preset_to_position("top down"),
    "Unknown camera preset"
  )
})

test_that("look_at_origin produces orthonormal rotation matrix", {
  m <- look_at_origin(c(-350, 0, 0))
  expect_equal(dim(m), c(4, 4))
  expect_equal(m[4, ], c(0, 0, 0, 1))
  expect_equal(m[1:3, 4], c(0, 0, 0))

  rows <- m[1:3, 1:3]
  expect_equal(rows %*% t(rows), diag(3), tolerance = 1e-10)
})

test_that("look_at_origin handles vertical eye positions", {
  m <- look_at_origin(c(0, 0, 330))
  expect_equal(dim(m), c(4, 4))

  rows <- m[1:3, 1:3]
  expect_equal(rows %*% t(rows), diag(3), tolerance = 1e-10)
})

test_that("mesh_entry_to_mesh3d converts vertex-colored mesh", {
  skip_if_not_installed("rgl")

  entry <- make_mesh_entry(
    name = "test",
    vertices = data.frame(
      x = c(0, 1, 0, 1),
      y = c(0, 0, 1, 1),
      z = c(0, 0, 0, 1)
    ),
    faces = data.frame(i = c(1L, 2L), j = c(2L, 3L), k = c(3L, 4L)),
    colors = c("#FF0000", "#00FF00", "#0000FF", "#FFFFFF"),
    color_mode = "vertexcolor",
    opacity = 0.8
  )

  mesh3d <- mesh_entry_to_mesh3d(entry)

  expect_s3_class(mesh3d, "mesh3d")
  expect_equal(ncol(mesh3d$vb), 4)
  expect_equal(ncol(mesh3d$it), 2)
  expect_equal(mesh3d$material$alpha, 0.8)
  expect_equal(length(mesh3d$material$color), 4)
  expect_equal(mesh3d$meshColor, "vertices")
})

test_that("mesh_entry_to_mesh3d handles 0-indexed faces from make_mesh_entry", {
  skip_if_not_installed("rgl")

  entry <- make_mesh_entry(
    name = "test",
    vertices = data.frame(
      x = c(0, 1, 0),
      y = c(0, 0, 1),
      z = c(0, 0, 0)
    ),
    faces = data.frame(i = 1L, j = 2L, k = 3L),
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    color_mode = "vertexcolor"
  )

  expect_equal(entry$faces$i, 0L)
  expect_equal(entry$faces$j, 1L)
  expect_equal(entry$faces$k, 2L)

  mesh3d <- mesh_entry_to_mesh3d(entry)
  expect_equal(mesh3d$it[1, 1], 1L)
  expect_equal(mesh3d$it[2, 1], 2L)
  expect_equal(mesh3d$it[3, 1], 3L)
})

test_that("mesh_entry_to_mesh3d converts face-colored mesh", {
  skip_if_not_installed("rgl")

  entry <- make_mesh_entry(
    name = "test",
    vertices = data.frame(
      x = c(0, 1, 0, 1),
      y = c(0, 0, 1, 1),
      z = c(0, 0, 0, 1)
    ),
    faces = data.frame(i = c(1L, 2L), j = c(2L, 3L), k = c(3L, 4L)),
    colors = c("#FF0000", "#00FF00"),
    color_mode = "facecolor"
  )

  mesh3d <- mesh_entry_to_mesh3d(entry)
  expect_equal(mesh3d$meshColor, "faces")
  expect_equal(length(mesh3d$material$color), 2)
})

test_that("prepare_brain_meshes returns meshes and legend_data", {
  prepared <- prepare_brain_meshes(
    atlas = dk,
    hemisphere = "left",
    surface = "inflated"
  )

  expect_type(prepared, "list")
  expect_true("meshes" %in% names(prepared))
  expect_true("legend_data" %in% names(prepared))
  expect_true(length(prepared$meshes) > 0)
})

test_that("ggsegray errors on invalid atlas", {
  skip_if_not_installed("rgl")

  expect_error(
    ggsegray(atlas = list(), hemisphere = "left"),
    "ggseg_atlas"
  )
})

test_that("ggsegray errors when rgl not installed", {
  skip_if(rlang::is_installed("rgl"))

  expect_error(
    ggsegray(hemisphere = "left"),
    "rgl"
  )
})

test_that("ggsegray creates rgl scene", {
  skip_if_not_installed("rgl")

  p <- ggsegray(hemisphere = "left", atlas = dk)

  expect_s3_class(p, "ggsegray")
  expect_true(is.integer(p$device))
  rgl::close3d()
})

test_that("ggsegray works with aseg atlas", {
  skip_if_not_installed("rgl")

  p <- ggsegray(atlas = aseg)

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("pan_camera works with ggsegray", {
  skip_if_not_installed("rgl")

  p <- ggsegray(hemisphere = "left", atlas = dk) |>
    pan_camera("left lateral")

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("pan_camera with numeric vector works for ggsegray", {
  skip_if_not_installed("rgl")

  p <- ggsegray(hemisphere = "left", atlas = dk) |>
    pan_camera(c(-400, 0, 0))

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("set_background works with ggsegray", {
  skip_if_not_installed("rgl")

  p <- ggsegray(hemisphere = "left", atlas = dk) |>
    set_background("black")

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("add_glassbrain works with ggsegray", {
  skip_if_not_installed("rgl")

  p <- ggsegray(hemisphere = "left", atlas = dk) |>
    add_glassbrain(hemisphere = "left")

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("ggsegray piping chain works", {
  skip_if_not_installed("rgl")

  p <- ggsegray(atlas = aseg) |>
    add_glassbrain(opacity = 0.15) |>
    pan_camera("right lateral") |>
    set_background("black")

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("render_edges_rgl draws boundary edges", {
  skip_if_not_installed("rgl")

  entry <- make_mesh_entry(
    name = "test",
    vertices = data.frame(
      x = c(0, 1, 0, 1),
      y = c(0, 0, 1, 1),
      z = c(0, 0, 0, 0)
    ),
    faces = data.frame(i = c(1L, 2L), j = c(2L, 3L), k = c(3L, 4L)),
    colors = c("#FF0000", "#00FF00", "#0000FF", "#FF0000"),
    color_mode = "vertexcolor",
    boundary_edges = list(c(0L, 1L), c(1L, 2L)),
    edge_color = "#000000"
  )

  rgl::open3d()
  expect_silent(render_edges_rgl(entry))
  rgl::close3d()
})

test_that("render_edges_rgl skips when no edges", {
  entry <- make_mesh_entry(
    name = "test",
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 1L, j = 2L, k = 3L),
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    color_mode = "vertexcolor"
  )

  expect_silent(render_edges_rgl(entry))
})

test_that("ggsegray renders edges when edge_by is set", {
  skip_if_not_installed("rgl")

  p <- ggsegray(
    atlas = dk,
    hemisphere = "left",
    edge_by = "region"
  )

  expect_s3_class(p, "ggsegray")
  rgl::close3d()
})

test_that("check_ggsegray rejects non-ggsegray objects", {
  expect_error(check_ggsegray(list()), "ggsegray")
  expect_error(check_ggsegray("not a scene"), "ggsegray")
})
