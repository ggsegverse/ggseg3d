test_that("resolve_brain_mesh returns mesh for inflated surface", {
  mesh <- resolve_brain_mesh(hemisphere = "lh", surface = "inflated")

  expect_false(is.null(mesh))
  expect_true("vertices" %in% names(mesh))
  expect_true("faces" %in% names(mesh))
  expect_gt(nrow(mesh$vertices), 0)
  expect_gt(nrow(mesh$faces), 0)
  expect_identical(ncol(mesh$vertices), 3L)
  expect_identical(ncol(mesh$faces), 3L)
})

test_that("resolve_brain_mesh returns both hemispheres", {
  lh <- resolve_brain_mesh(hemisphere = "lh", surface = "inflated")
  rh <- resolve_brain_mesh(hemisphere = "rh", surface = "inflated")

  expect_false(is.null(lh))
  expect_false(is.null(rh))
  expect_identical(nrow(lh$vertices), nrow(rh$vertices))
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
  expect_identical(colors[1:3], rep("#FF0000", 3))
  expect_identical(colors[4:5], rep("#00FF00", 2))
  expect_identical(colors[6], "#CCCCCC")
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

  expect_identical(colors[1:2], rep("#FF0000", 2))
  expect_identical(colors[3:4], rep("#AAAAAA", 2))
  expect_identical(colors[5], "#AAAAAA")
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
  expect_identical(groups[1:3], rep("frontal", 3))
  expect_identical(groups[4:5], rep("parietal", 2))
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

  expect_false(is.null(lh))
  expect_false(is.null(rh))
})

test_that("resolve_brain_mesh returns white surface", {
  mesh <- resolve_brain_mesh(hemisphere = "lh", surface = "white")
  expect_false(is.null(mesh))
  expect_true("vertices" %in% names(mesh))
  expect_true("faces" %in% names(mesh))
})

test_that("vertices_to_colors handles empty vertices", {
  atlas_data <- data.frame(
    region = "a",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(integer(0))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 5,
    na_colour = "#CCCCCC"
  )

  expect_identical(colors, rep("#CCCCCC", 5))
})

test_that("vertices_to_colors handles out-of-bounds indices", {
  atlas_data <- data.frame(
    region = "a",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(-1, 0, 100))

  colors <- vertices_to_colors(
    atlas_data,
    n_vertices = 5,
    na_colour = "#CCCCCC"
  )

  expect_identical(colors[1], "#FF0000")
  expect_identical(colors[5], "#CCCCCC")
})

test_that("vertices_to_groups handles NA group values", {
  atlas_data <- data.frame(
    region = c("a", "b"),
    lobe = c("frontal", NA),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1), c(2, 3))

  groups <- vertices_to_groups(atlas_data, n_vertices = 5, group_col = "lobe")

  expect_identical(groups[1:2], rep("frontal", 2))
  expect_true(is.na(groups[3]))
  expect_true(is.na(groups[4]))
})

test_that("is_unified_atlas detects atlas with data component", {
  expect_true(is_unified_atlas(make_test_cortical_atlas()))
  expect_true(is_unified_atlas(make_test_cerebellar_atlas()))
})

test_that("is_unified_atlas returns FALSE for atlas without 3d data", {
  expect_false(is_unified_atlas(make_test_2d_only_atlas()))
})

test_that("is_subcortical_atlas detects subcortical atlases", {
  expect_true(is_subcortical_atlas(aseg()))
  expect_false(is_subcortical_atlas(dk()))
})

test_that("is_unified_atlas rejects pre-unification atlas objects", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "left"),
      vertices = data.frame(label = "a")
    ),
    class = "ggseg_atlas"
  )
  atlas$vertices$vertices <- list(1:10)

  expect_false(is_unified_atlas(atlas))
})

test_that("atlas_3d_components reports the geometry each atlas carries", {
  expect_identical(
    atlas_3d_components(dk()),
    c(vertices = TRUE, meshes = FALSE, centerlines = FALSE)
  )
  expect_identical(
    atlas_3d_components(aseg()),
    c(vertices = FALSE, meshes = TRUE, centerlines = FALSE)
  )
  expect_identical(
    atlas_3d_components(tracula()),
    c(vertices = FALSE, meshes = FALSE, centerlines = TRUE)
  )
})

test_that("cross_product computes correct cross products", {
  expect_identical(cross_product(c(1, 0, 0), c(0, 1, 0)), c(0, 0, 1))
  expect_identical(cross_product(c(0, 1, 0), c(0, 0, 1)), c(1, 0, 0))
  expect_identical(cross_product(c(1, 0, 0), c(1, 0, 0)), c(0, 0, 0))
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
  expect_identical(nrow(result$vertices), 4L * 6L)
  expect_identical(nrow(result$faces), (4L - 1L) * 6L * 2L)
  expect_identical(result$metadata$n_centerline_points, 4L)
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

  expect_identical(nrow(result$vertices), 3L * 4L)
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
  expect_identical(nrow(frames$tangents), 4L)
  expect_identical(nrow(frames$normals), 4L)
  expect_identical(nrow(frames$binormals), 4L)

  for (i in 1:4) {
    expect_equal(sqrt(sum(frames$tangents[i, ]^2)), 1, tolerance = 1e-10)
    expect_equal(sqrt(sum(frames$normals[i, ]^2)), 1, tolerance = 1e-10)
    expect_equal(sqrt(sum(frames$binormals[i, ]^2)), 1, tolerance = 1e-10)
  }
})

test_that("build_tract_meshes with centerlines creates tube meshes", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = "#FF0000",
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
  expect_identical(meshes[[1]]$name, "tract_a")
  expect_identical(meshes[[1]]$colorMode, "vertexcolor")
  expect_length(meshes[[1]]$colors, 3 * 4)
})

test_that("build_tract_meshes warns with no data", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = "#FF0000",
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
    label = "tract_a",
    colour = "#FF0000",
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
    hemisphere = "lh",
    surface = "pial",
    brain_meshes = list()
  )
  expect_null(result)
})

test_that("resolve_brain_mesh anatomically separates hemispheres on x", {
  lh <- resolve_brain_mesh("lh", "inflated")
  rh <- resolve_brain_mesh("rh", "inflated")

  expect_lte(max(lh$vertices$x), 1e-6)
  expect_gte(min(rh$vertices$x), -1e-6)
})

test_that("resolve_brain_mesh separates hemispheres for pial surface", {
  skip_if_not_installed("ggseg.meshes")
  lh <- resolve_brain_mesh("lh", "pial")
  rh <- resolve_brain_mesh("rh", "pial")

  expect_lte(max(lh$vertices$x), 1e-6)
  expect_gte(min(rh$vertices$x), -1e-6)
})

test_that("pial meshes use shared axis convention after normalization", {
  skip_if_not_installed("ggseg.meshes")
  pial_lh <- resolve_brain_mesh("lh", "pial")
  infl_lh <- resolve_brain_mesh("lh", "inflated")

  # Both surfaces should have LH medial edge at x = 0 and widest extent
  # on the AP axis (y).
  expect_equal(max(pial_lh$vertices$x), 0, tolerance = 1e-6)
  expect_equal(max(infl_lh$vertices$x), 0, tolerance = 1e-6)
  expect_gt(
    diff(range(pial_lh$vertices$y)),
    diff(range(pial_lh$vertices$x))
  )
})

test_that("is_flat_mesh detects flat surfaces", {
  flat <- data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0))
  vol <- data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 1))
  expect_true(is_flat_mesh(flat))
  expect_false(is_flat_mesh(vol))
})

test_that("build_tract_meshes with mesh data (no centerlines)", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = "#FF0000",
    stringsAsFactors = FALSE
  )
  mesh <- list(
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 0, j = 1, k = 2)
  )
  atlas_data$mesh <- list(mesh)

  meshes <- build_tract_meshes(atlas_data, "#CCCCCC", color_by = "colour")

  expect_length(meshes, 1)
  expect_identical(meshes[[1]]$name, "tract_a")
  expect_identical(meshes[[1]]$colors, rep("#FF0000", 3))
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
  expect_identical(meshes[[1]]$name, "tract_a")
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
  expect_identical(meshes[[1]]$name, "tract_a")
})

test_that("build_tract_meshes applies na_colour for NA colour", {
  atlas_data <- data.frame(
    label = "tract_a",
    colour = NA_character_,
    stringsAsFactors = FALSE
  )
  mesh <- list(
    vertices = data.frame(x = c(0, 1, 0), y = c(0, 0, 1), z = c(0, 0, 0)),
    faces = data.frame(i = 0, j = 1, k = 2)
  )
  atlas_data$mesh <- list(mesh)

  meshes <- build_tract_meshes(
    atlas_data,
    "#CCCCCC",
    color_by = "colour"
  )

  expect_identical(meshes[[1]]$colors, rep("#CCCCCC", 3))
})

test_that("build_centerline_data returns NULL when no centerlines", {
  expect_null(build_centerline_data(aseg()))
})

test_that("build_centerline_data carries centerlines and tube defaults", {
  result <- build_centerline_data(tracula())

  expect_type(result, "list")
  expect_true(all(
    c("label", "points", "tangents") %in%
      names(result$centerlines)
  ))
  expect_identical(ncol(result$centerlines$points[[1]]), 3L)
  expect_identical(result$tube_radius, 2)
  expect_identical(result$tube_segments, 10)
})

test_that("face_index_base reads the published attribute over the data", {
  # 1-based faces that happen to use no vertex 0 in `i`, the arrangement the
  # old heuristic read as 1-based whatever the attribute said.
  mesh <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )

  expect_identical(face_index_base(mesh), 1L)

  # The attribute overrides the inference, in both directions.
  attr(mesh, "face_index_base") <- 0L
  expect_identical(face_index_base(mesh), 0L)

  attr(mesh, "face_index_base") <- 2L
  expect_error(face_index_base(mesh), "must be 0 or 1")
})

test_that("as_one_based_mesh leaves 1-based faces and shifts 0-based ones", {
  one_based <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )
  attr(one_based, "face_index_base") <- 1L

  zero_based <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 0L, j = 1L, k = 2L)
  )
  attr(zero_based, "face_index_base") <- 0L

  expect_identical(as_one_based_mesh(one_based)$faces, one_based$faces)
  expect_identical(as_one_based_mesh(zero_based)$faces, one_based$faces)
  expect_identical(
    attr(as_one_based_mesh(zero_based), "face_index_base"),
    1L
  )
})

test_that("a mesh without the attribute is valid input, not an error", {
  # Third-party atlas packages are not bound by the core packages' mesh
  # contract, so a mesh may legitimately publish no base at all. ggseg.formats
  # meshes are 0-based with vertex 0 not necessarily in the `i` column.
  mesh <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 1L, j = 0L, k = 2L)
  )

  expect_no_condition(base <- face_index_base(mesh))
  expect_identical(base, 0L)
  expect_no_condition(shifted <- as_one_based_mesh(mesh))
  expect_identical(shifted$faces, data.frame(i = 2L, j = 1L, k = 3L))

  one_based <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )

  expect_no_condition(base <- face_index_base(one_based))
  expect_identical(base, 1L)
  expect_identical(as_one_based_mesh(one_based)$faces, one_based$faces)
})

test_that("the inferred base uses the whole index span, not just column i", {
  # Every index above 0, but the span stops one short of the vertex count:
  # 0-based with vertex 0 unused by this face.
  zero_based <- list(
    vertices = data.frame(x = 0:3, y = 0:3, z = 0:3),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )

  expect_identical(infer_face_index_base(zero_based), 0L)

  one_based <- list(
    vertices = data.frame(x = 0:2, y = 0:2, z = 0:2),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )

  expect_identical(infer_face_index_base(one_based), 1L)
})

test_that("resolve_brain_mesh returns 1-based faces for both index bases", {
  inflated <- resolve_brain_mesh("lh", "inflated")
  expect_identical(min(unlist(inflated$faces)), 1L)
  expect_identical(max(unlist(inflated$faces)), nrow(inflated$vertices))

  skip_if_not_installed("ggseg.meshes")
  pial <- resolve_brain_mesh("lh", "pial")
  expect_identical(min(unlist(pial$faces)), 1L)
  expect_identical(max(unlist(pial$faces)), nrow(pial$vertices))
})
