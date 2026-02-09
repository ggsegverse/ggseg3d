test_that("build_meshes skips hemisphere without data", {
  atlas_data <- data.frame(
    label = c("a"),
    region = c("region a"),
    hemi = c("left"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0, 1, 2))

  meshes <- build_meshes(
    atlas_data,
    c("left", "right"),
    "inflated",
    "#CCCCCC",
    NULL,
    NULL
  )

  expect_true(length(meshes) >= 1)
})

test_that("build_meshes with edge.by parameter", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    hemi = c("left", "left"),
    colour = c("#FF0000", "#00FF00"),
    lobe = c("frontal", "parietal"),
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(0:50, 51:100)

  meshes <- build_meshes(
    atlas_data,
    "left",
    "inflated",
    "#CCCCCC",
    "lobe",
    NULL
  )

  expect_true(length(meshes) > 0)
  expect_true(!is.null(meshes[[1]]$edgeColor))
})

test_that("build_meshes handles subcort hemisphere", {
  atlas_data <- data.frame(
    label = c("Left-Caudate"),
    region = c("caudate"),
    hemi = c("subcort"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:3, y = 1:3, z = 1:3),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  )

  subcort_atlas <- structure(
    list(core = data.frame(label = "Left-Caudate", hemi = "subcort")),
    class = c("subcortical_atlas", "ggseg_atlas")
  )

  meshes <- build_meshes(
    atlas_data,
    "subcort",
    "inflated",
    "#CCCCCC",
    NULL,
    atlas_data,
    atlas = subcort_atlas
  )

  expect_true(length(meshes) > 0)
})

test_that("build_meshes handles tract atlas type", {
  atlas_data <- data.frame(
    label = c("tract1"),
    region = c("tract 1"),
    hemi = c("subcort"),
    colour = c("#FF0000"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:4, y = 1:4, z = 1:4),
      faces = data.frame(i = c(1, 2), j = c(2, 3), k = c(3, 4))
    )
  )

  tract_atlas <- structure(
    list(core = data.frame(label = "tract1", hemi = "subcort")),
    class = c("tract_atlas", "ggseg_atlas")
  )

  meshes <- build_meshes(
    atlas_data,
    "subcort",
    "inflated",
    "#CCCCCC",
    NULL,
    atlas_data,
    atlas = tract_atlas
  )

  expect_true(length(meshes) > 0)
})
