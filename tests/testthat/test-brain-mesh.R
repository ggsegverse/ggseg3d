test_that("get_brain_mesh returns mesh for inflated surface", {
  mesh <- get_brain_mesh(hemisphere = "lh", surface = "inflated")

  expect_true(!is.null(mesh))
  expect_true("vertices" %in% names(mesh))
  expect_true("faces" %in% names(mesh))
  expect_true(nrow(mesh$vertices) > 0)
  expect_true(nrow(mesh$faces) > 0)
  expect_equal(ncol(mesh$vertices), 3)
  expect_equal(ncol(mesh$faces), 3)
})

test_that("get_brain_mesh returns both hemispheres", {
  lh <- get_brain_mesh(hemisphere = "lh", surface = "inflated")
  rh <- get_brain_mesh(hemisphere = "rh", surface = "inflated")

  expect_true(!is.null(lh))
  expect_true(!is.null(rh))
  expect_equal(nrow(lh$vertices), nrow(rh$vertices))
})

test_that("get_brain_mesh validates arguments", {
  expect_error(get_brain_mesh(hemisphere = "invalid"))
  expect_error(get_brain_mesh(surface = "invalid"))
})

test_that("is_unified_atlas identifies unified atlases correctly", {
  expect_true(is_unified_atlas(dk))
  expect_true(is_unified_atlas(aseg))

  expect_false(is_unified_atlas(list()))
  expect_false(is_unified_atlas(data.frame()))
  expect_false(is_unified_atlas(NULL))
  expect_false(is_unified_atlas("dk"))
})

test_that("is_mesh_atlas identifies mesh-based atlases", {
  expect_false(is_mesh_atlas(dk))
  expect_false(is_mesh_atlas(list()))
  expect_false(is_mesh_atlas(NULL))
})

test_that("is_tract_atlas identifies tract atlases", {
  expect_false(is_tract_atlas(dk))
  expect_false(is_tract_atlas(aseg))
  expect_false(is_tract_atlas(list()))
  expect_false(is_tract_atlas(NULL))
})

test_that("vertices_to_colors creates correct color vector", {
  atlas_data <- data.frame(
    region = c("a", "b"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2), c(3, 4))

  colors <- vertices_to_colors(
    atlas_data, n_vertices = 6, na_colour = "#CCCCCC"
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
    atlas_data, n_vertices = 5, na_colour = "#AAAAAA"
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

test_that("get_brain_mesh returns inflated surfaces", {
  lh <- get_brain_mesh(hemisphere = "lh", surface = "inflated")
  rh <- get_brain_mesh(hemisphere = "rh", surface = "inflated")

  expect_true(!is.null(lh))
  expect_true(!is.null(rh))
})

test_that("get_brain_mesh warns for unavailable surfaces", {
  expect_warning(
    get_brain_mesh(hemisphere = "lh", surface = "white"),
    "not available"
  )
})

test_that("vertices_to_colors handles empty vertices", {
  atlas_data <- data.frame(
    region = c("a"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(integer(0))

  colors <- vertices_to_colors(
    atlas_data, n_vertices = 5, na_colour = "#CCCCCC"
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
    atlas_data, n_vertices = 5, na_colour = "#CCCCCC"
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
        class = "brain_atlas_data"
      )
    ),
    class = "brain_atlas"
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
        class = "brain_atlas_data"
      )
    ),
    class = "brain_atlas"
  )

  expect_false(is_unified_atlas(atlas))
})

test_that("is_mesh_atlas detects atlas with meshes in data component", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "subcort"),
      data = structure(
        list(meshes = data.frame(label = "a")),
        class = "brain_atlas_data"
      )
    ),
    class = "brain_atlas"
  )

  expect_true(is_mesh_atlas(atlas))
})

test_that("is_mesh_atlas detects atlas with direct meshes", {
  atlas <- structure(
    list(
      core = data.frame(label = "a", region = "r", hemi = "subcort"),
      meshes = data.frame(label = "a")
    ),
    class = "brain_atlas"
  )
  atlas$meshes$mesh <- list(list())

  expect_true(is_mesh_atlas(atlas))
})
