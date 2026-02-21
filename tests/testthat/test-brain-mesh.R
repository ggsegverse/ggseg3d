test_that("resolve_brain_mesh returns mesh for inflated surface", {
  mesh <- resolve_brain_mesh(hemisphere = "lh", surface = "inflated")

  expect_true(!is.null(mesh))
  expect_true("vertices" %in% names(mesh))
  expect_true("faces" %in% names(mesh))
  expect_true(nrow(mesh$vertices) > 0)
  expect_true(nrow(mesh$faces) > 0)
  expect_equal(ncol(mesh$vertices), 3)
  expect_equal(ncol(mesh$faces), 3)
})

test_that("resolve_brain_mesh returns both hemispheres", {
  lh <- resolve_brain_mesh(hemisphere = "lh", surface = "inflated")
  rh <- resolve_brain_mesh(hemisphere = "rh", surface = "inflated")

  expect_true(!is.null(lh))
  expect_true(!is.null(rh))
  expect_equal(nrow(lh$vertices), nrow(rh$vertices))
})

test_that("resolve_brain_mesh validates arguments", {
  expect_error(resolve_brain_mesh(hemisphere = "invalid"))
  expect_error(resolve_brain_mesh(surface = "invalid"))
})

test_that("is_unified_atlas identifies unified atlases correctly", {
  expect_true(is_unified_atlas(dk()))
  expect_true(is_unified_atlas(aseg()))

  expect_false(is_unified_atlas(list()))
  expect_false(is_unified_atlas(data.frame()))
  expect_false(is_unified_atlas(NULL))
  expect_false(is_unified_atlas("dk"))
})

test_that("class-based atlas checks work correctly", {
  expect_true(is_cortical_atlas(dk()))
  expect_false(is_subcortical_atlas(dk()))
  expect_false(is_tract_atlas(dk()))

  expect_true(is_subcortical_atlas(aseg()))
  expect_false(is_cortical_atlas(aseg()))
  expect_false(is_tract_atlas(aseg()))
})


test_that("vertices_to_colors creates correct color vector", {
  atlas_data <- data.frame(
    region = c("a", "b"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2), c(3, 4))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 6,
    na_colour = "#CCCCCC"
  )

  expect_length(colors, 6)
  expect_equal(colors[1:3], rep("#FF0000", 3))
  expect_equal(colors[4:5], rep("#00FF00", 2))
  expect_equal(colors[6], "#CCCCCC")
})

test_that("vertices_to_colors handles NA colours", {
  atlas_data <- data.frame(
    region = c("a", "b"),
    colour = c("#FF0000", NA),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1), c(2, 3))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 5,
    na_colour = "#AAAAAA"
  )

  expect_equal(colors[1:2], rep("#FF0000", 2))
  expect_equal(colors[3:4], rep("#AAAAAA", 2))
  expect_equal(colors[5], "#AAAAAA")
})

test_that("vertices_to_groups creates correct group vector", {
  atlas_data <- data.frame(
    region = c("precentral", "postcentral"),
    lobe = c("frontal", "parietal"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2), c(3, 4))

  groups <- vertices_to_groups(atlas_data, n_vertices = 6, group_col = "lobe")

  expect_length(groups, 6)
  expect_equal(groups[1:3], rep("frontal", 3))
  expect_equal(groups[4:5], rep("parietal", 2))
  expect_true(is.na(groups[6]))
})

test_that("vertices_to_groups errors on missing column", {
  atlas_data <- data.frame(region = "a")
  atlas_data$vertices <- list(c(0, 1))

  expect_error(
    vertices_to_groups(atlas_data, n_vertices = 3, group_col = "missing"),
    "not found"
  )
})

test_that("resolve_brain_mesh returns inflated surfaces", {
  lh <- resolve_brain_mesh(hemisphere = "lh", surface = "inflated")
  rh <- resolve_brain_mesh(hemisphere = "rh", surface = "inflated")

  expect_true(!is.null(lh))
  expect_true(!is.null(rh))
})

test_that("resolve_brain_mesh returns white surface", {
  mesh <- resolve_brain_mesh(hemisphere = "lh", surface = "white")
  expect_true(!is.null(mesh))
  expect_true("vertices" %in% names(mesh))
  expect_true("faces" %in% names(mesh))
})

test_that("vertices_to_colors handles empty vertices", {
  atlas_data <- data.frame(
    region = c("a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(integer(0))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 5,
    na_colour = "#CCCCCC"
  )

  expect_equal(colors, rep("#CCCCCC", 5))
})

test_that("vertices_to_colors handles out-of-bounds indices", {
  atlas_data <- data.frame(
    region = c("a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(-1, 0, 100))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 5,
    na_colour = "#CCCCCC"
  )

  expect_equal(colors[1], "#FF0000")
  expect_equal(colors[5], "#CCCCCC")
})

test_that("vertices_to_groups handles NA group values", {
  atlas_data <- data.frame(
    region = c("a", "b"),
    lobe = c("frontal", NA),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1), c(2, 3))

  groups <- vertices_to_groups(atlas_data, n_vertices = 5, group_col = "lobe")

  expect_equal(groups[1:2], rep("frontal", 2))
  expect_true(is.na(groups[3]))
  expect_true(is.na(groups[4]))
})

test_that("is_unified_atlas detects atlas with data component", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "left"),
      data = structure(
        list(vertices = data.frame(label = "a")),
        class = "ggseg_atlas_data"
      )
    ),
    class = "ggseg_atlas"
  )
  atlas$data$vertices$vertices <- list(1:10)

  expect_true(is_unified_atlas(atlas))
})

test_that("is_unified_atlas returns FALSE for atlas without 3d data", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "left"),
      data = structure(
        list(geometry = data.frame()),
        class = "ggseg_atlas_data"
      )
    ),
    class = "ggseg_atlas"
  )

  expect_false(is_unified_atlas(atlas))
})

test_that("is_subcortical_atlas detects subcortical atlases", {
  expect_true(is_subcortical_atlas(aseg()))
  expect_false(is_subcortical_atlas(dk()))
})

test_that("is_unified_atlas detects direct vertices", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "left"),
      vertices = data.frame(label = "a")
    ),
    class = "ggseg_atlas"
  )
  atlas$vertices$vertices <- list(1:10)

  expect_true(is_unified_atlas(atlas))
})

test_that("is_unified_atlas detects direct meshes", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "subcort"),
      meshes = data.frame(label = "a")
    ),
    class = "ggseg_atlas"
  )

  expect_true(is_unified_atlas(atlas))
})

test_that("cross_product computes correct cross products", {
  expect_equal(cross_product(c(1, 0, 0), c(0, 1, 0)), c(0, 0, 1))
  expect_equal(cross_product(c(0, 1, 0), c(0, 0, 1)), c(1, 0, 0))
  expect_equal(cross_product(c(1, 0, 0), c(1, 0, 0)), c(0, 0, 0))
})

test_that("rotate_vector rotates correctly", {
  rotated <- rotate_vector(c(1, 0, 0), c(0, 0, 1), pi / 2)
  expect_equal(rotated[1], 0, tolerance = 1e-10)
  expect_equal(rotated[2], 1, tolerance = 1e-10)
  expect_equal(rotated[3], 0, tolerance = 1e-10)

  no_rotation <- rotate_vector(c(1, 0, 0), c(0, 0, 1), 0)
  expect_equal(no_rotation, c(1, 0, 0), tolerance = 1e-10)
})

test_that("generate_tube_mesh creates correct mesh structure", {
  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0, 3, 0, 0),
    nrow = 4,
    byrow = TRUE
  )

  result <- generate_tube_mesh(centerline, radius = 0.5, segments = 6)

  expect_true("vertices" %in% names(result))
  expect_true("faces" %in% names(result))
  expect_true("metadata" %in% names(result))
  expect_equal(nrow(result$vertices), 4 * 6)
  expect_equal(nrow(result$faces), (4 - 1) * 6 * 2)
  expect_equal(result$metadata$n_centerline_points, 4)
})

test_that("generate_tube_mesh accepts per-point radius", {
  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3,
    byrow = TRUE
  )

  result <- generate_tube_mesh(
    centerline,
    radius = c(0.5, 1.0, 0.5),
    segments = 4
  )

  expect_equal(nrow(result$vertices), 3 * 4)
})

test_that("generate_tube_mesh errors on bad input", {
  expect_error(generate_tube_mesh(matrix(1:3, nrow = 1)), "at least 2 rows")
  expect_error(generate_tube_mesh(c(1, 2, 3)), "matrix")
})

test_that("compute_parallel_transp_fr returns correct structure", {
  curve <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 1, 0, 3, 1, 1),
    nrow = 4,
    byrow = TRUE
  )

  frames <- compute_parallel_transp_fr(curve)

  expect_true("tangents" %in% names(frames))
  expect_true("normals" %in% names(frames))
  expect_true("binormals" %in% names(frames))
  expect_equal(nrow(frames$tangents), 4)
  expect_equal(nrow(frames$normals), 4)
  expect_equal(nrow(frames$binormals), 4)

  for (i in 1:4) {
    expect_equal(sqrt(sum(frames$tangents[i, ]^2)), 1, tolerance = 1e-10)
    expect_equal(sqrt(sum(frames$normals[i, ]^2)), 1, tolerance = 1e-10)
    expect_equal(sqrt(sum(frames$binormals[i, ]^2)), 1, tolerance = 1e-10)
  }
})

test_that("build_tract_meshes with centerlines creates tube meshes", {
  atlas_data <- data.frame(
    label = c("tract_a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )

  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3,
    byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 1, 0, 0, 1, 0, 0),
    nrow = 3,
    byrow = TRUE
  )

  atlas_centerlines <- list(
    centerlines = data.frame(label = "tract_a", stringsAsFactors = FALSE),
    tube_radius = 0.5,
    tube_segments = 4
  )
  atlas_centerlines$centerlines$points <- list(centerline)
  atlas_centerlines$centerlines$tangents <- list(tangents)

  meshes <- build_tract_meshes(
    atlas_data,
    "#CCCCCC",
    color_by = "colour",
    atlas_centerlines = atlas_centerlines
  )

  expect_length(meshes, 1)
  expect_equal(meshes[[1]]$name, "tract_a")
  expect_equal(meshes[[1]]$colorMode, "vertexcolor")
  expect_equal(length(meshes[[1]]$colors), 3 * 4)
})

test_that("build_tract_meshes warns with no data", {
  atlas_data <- data.frame(
    label = c("tract_a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )

  expect_warning(
    meshes <- build_tract_meshes(atlas_data, "#CCCCCC"),
    "No centerlines or meshes"
  )
  expect_length(meshes, 0)
})

test_that("build_tract_meshes with centerlines and orientation coloring", {
  atlas_data <- data.frame(
    label = c("tract_a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )

  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3,
    byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 0, 1, 0, 0, 0, 1),
    nrow = 3,
    byrow = TRUE
  )

  atlas_centerlines <- list(
    centerlines = data.frame(label = "tract_a", stringsAsFactors = FALSE),
    tube_radius = 0.5,
    tube_segments = 4
  )
  atlas_centerlines$centerlines$points <- list(centerline)
  atlas_centerlines$centerlines$tangents <- list(tangents)

  meshes <- build_tract_meshes(
    atlas_data,
    "#CCCCCC",
    color_by = "orientation",
    atlas_centerlines = atlas_centerlines
  )

  expect_length(meshes, 1)
  expect_true(all(grepl("^#", meshes[[1]]$colors)))
})

test_that("resolve_brain_mesh returns NULL for empty brain_meshes", {
  result <- resolve_brain_mesh(
    hemisphere = "lh", surface = "pial", brain_meshes = list()
  )
  expect_null(result)
})

test_that("position_hemisphere shifts left hemisphere left", {
  verts <- data.frame(x = c(0, 10), y = c(0, 0), z = c(0, 0))
  result <- position_hemisphere(verts, "left")
  expect_true(mean(result$x) < mean(verts$x))
})

test_that("position_hemisphere shifts right hemisphere right", {
  verts <- data.frame(x = c(0, 10), y = c(0, 0), z = c(0, 0))
  result <- position_hemisphere(verts, "right")
  expect_true(mean(result$x) > mean(verts$x))
})

test_that("position_hemisphere passes through unknown hemisphere", {
  verts <- data.frame(x = c(0, 10), y = c(0, 0), z = c(0, 0))
  result <- position_hemisphere(verts, "subcort")
  expect_equal(result, verts)
})

test_that("to_native_coords handles NULL input", {
  expect_null(to_native_coords(NULL))
})

test_that("to_native_coords skips NULL meshes in list", {
  df <- data.frame(label = c("a", "b"), stringsAsFactors = FALSE)
  mesh_a <- list(
    vertices = data.frame(x = 1, y = 2, z = 3),
    faces = data.frame(i = 0, j = 0, k = 0)
  )
  df$mesh <- list(mesh_a, NULL)

  result <- to_native_coords(df)
  expect_null(result$mesh[[2]])
  expect_false(identical(result$mesh[[1]]$vertices$y, 2))
})

test_that("build_tract_meshes with mesh data (no centerlines)", {
  atlas_data <- data.frame(
    label = c("tract_a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  mesh <- list(
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 0, j = 1, k = 2)
  )
  atlas_data$mesh <- list(mesh)

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", color_by = "colour")

  expect_length(meshes, 1)
  expect_equal(meshes[[1]]$name, "tract_a")
  expect_equal(meshes[[1]]$colors, rep("#FF0000", 3))
})

test_that("build_tract_meshes skips NULL mesh entries", {
  atlas_data <- data.frame(
    label = c("tract_a", "tract_b"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  mesh <- list(
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 0, j = 1, k = 2)
  )
  atlas_data$mesh <- list(mesh, NULL)

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", color_by = "colour")

  expect_length(meshes, 1)
  expect_equal(meshes[[1]]$name, "tract_a")
})

test_that("build_cortical_meshes warns when brain mesh not found", {
  atlas_data <- data.frame(
    region = "precentral",
    hemi = "left",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2))

  expect_warning(
    build_cortical_meshes(
      atlas_data,
      hemisphere = "left",
      surface = "pial",
      na_colour = "#CCCCCC",
      edge_by = NULL,
      brain_meshes = list()
    ),
    "Brain mesh not found"
  )
})

test_that("build_tract_meshes skips labels not in centerlines", {
  atlas_data <- data.frame(
    label = c("tract_a", "tract_missing"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )

  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3, byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 1, 0, 0, 1, 0, 0),
    nrow = 3, byrow = TRUE
  )

  atlas_centerlines <- list(
    centerlines = data.frame(label = "tract_a", stringsAsFactors = FALSE),
    tube_radius = 0.5,
    tube_segments = 4
  )
  atlas_centerlines$centerlines$points <- list(centerline)
  atlas_centerlines$centerlines$tangents <- list(tangents)

  meshes <- build_tract_meshes(
    atlas_data, "#CCCCCC",
    color_by = "colour",
    atlas_centerlines = atlas_centerlines
  )

  expect_length(meshes, 1)
  expect_equal(meshes[[1]]$name, "tract_a")
})

test_that("build_tract_meshes applies na_colour for NA colour", {
  atlas_data <- data.frame(
    label = c("tract_a"),
    colour = NA_character_,
    stringsAsFactors = FALSE
  )
  mesh <- list(
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 0, j = 1, k = 2)
  )
  atlas_data$mesh <- list(mesh)

  meshes <- build_tract_meshes(
    atlas_data, "#CCCCCC", color_by = "colour"
  )

  expect_equal(meshes[[1]]$colors, rep("#CCCCCC", 3))
})

test_that("build_centerline_data returns NULL when no centerlines", {
  atlas <- structure(
    list(
      data = structure(
        list(centerlines = NULL),
        class = c("ggseg_data_tract", "ggseg_atlas_data")
      )
    ),
    class = c("tract_atlas", "ggseg_atlas", "list")
  )

  expect_null(build_centerline_data(atlas))
})

test_that("build_centerline_data skips NULL points in centerlines", {
  cl_data <- data.frame(
    label = c("tract_a", "tract_b"),
    stringsAsFactors = FALSE
  )
  cl_data$points <- list(
    matrix(c(0, 0, 0, 1, 0, 0), nrow = 2, byrow = TRUE),
    NULL
  )

  atlas <- structure(
    list(
      data = structure(
        list(centerlines = cl_data),
        class = c("ggseg_data_tract", "ggseg_atlas_data")
      )
    ),
    class = c("tract_atlas", "ggseg_atlas", "list")
  )

  result <- build_centerline_data(atlas)

  expect_type(result, "list")
  expect_null(result$centerlines$points[[2]])
  expect_equal(nrow(result$centerlines$points[[1]]), 2)
})
