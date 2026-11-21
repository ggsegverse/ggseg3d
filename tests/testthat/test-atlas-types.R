test_that("prepare_atlas_data extracts vertices and joins core", {
  atlas <- make_test_cortical_atlas()

  result <- prepare_atlas_data(atlas, NULL)

  expect_identical(nrow(result), 2L)
  expect_true(
    all(c("label", "region", "hemi", "colour", "vertices") %in% names(result))
  )
  expect_identical(result$colour[result$label == "lh_bankssts"], "#FF0000")
})

test_that("prepare_atlas_data merges user data", {
  atlas <- make_test_cortical_atlas()
  user_data <- data.frame(
    label = c("lh_bankssts", "lh_precentral"),
    my_value = c(10, 20),
    stringsAsFactors = FALSE
  )

  result <- prepare_atlas_data(atlas, user_data)

  expect_true("my_value" %in% names(result))
  expect_identical(result$my_value[result$label == "lh_bankssts"], 10)
})

test_that("prepare_mesh_atlas_data extracts meshes and joins core", {
  atlas <- ggseg.formats::set_atlas_palette(
    make_uniform_palette_atlas(),
    c("Left-Caudate" = "#123456", "Right-Caudate" = "#654321")
  )

  result <- prepare_mesh_atlas_data(atlas, NULL)

  expect_true(all(c("label", "mesh", "colour") %in% names(result)))
  expect_identical(result$colour[result$label == "Left-Caudate"], "#123456")
})

test_that("prepare_mesh_atlas_data joins tract centerline metadata", {
  result <- prepare_mesh_atlas_data(tracula(), NULL)

  expect_true(all(c("label", "region", "hemi", "colour") %in% names(result)))
  expect_false(any(c("points", "tangents") %in% names(result)))
})

test_that("data_merge_mesh joins user data with atlas", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    hemi = c(NA_character_, NA_character_),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list(), list())

  user_data <- data.frame(
    label = c("a", "b"),
    value = c(100, 200),
    stringsAsFactors = FALSE
  )

  result <- data_merge_mesh(user_data, atlas_data)

  expect_true("value" %in% names(result))
  expect_identical(result$value[result$label == "a"], 100)
})

test_that("data_merge_mesh warns when no common columns", {
  atlas_data <- data.frame(
    label = "a",
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list())

  user_data <- data.frame(
    unrelated_col = "x",
    stringsAsFactors = FALSE
  )

  expect_warning(
    result <- data_merge_mesh(user_data, atlas_data),
    "No common columns"
  )

  expect_identical(result, atlas_data)
})

test_that("data_merge_mesh joins on region column", {
  atlas_data <- data.frame(
    label = c("a", "b"),
    region = c("region a", "region b"),
    stringsAsFactors = FALSE
  )
  atlas_data$mesh <- list(list(), list())

  user_data <- data.frame(
    region = c("region a", "region b"),
    score = c(1.5, 2.5),
    stringsAsFactors = FALSE
  )

  result <- data_merge_mesh(user_data, atlas_data)

  expect_true("score" %in% names(result))
  expect_equal(result$score[result$region == "region a"], 1.5)
})

test_that("prepare_mesh_atlas_data merges user data", {
  atlas <- make_uniform_palette_atlas()
  user_data <- data.frame(
    label = c("Left-Caudate", "Right-Caudate"),
    value = c(100, 200),
    stringsAsFactors = FALSE
  )

  result <- suppressWarnings(prepare_mesh_atlas_data(atlas, user_data))

  expect_true("value" %in% names(result))
  expect_identical(result$value[result$label == "Left-Caudate"], 100)
})

test_that("duplicated atlas labels are dropped once, with a warning", {
  atlas <- make_duplicate_label_atlas()

  expect_warning(
    atlas_data <- prepare_mesh_atlas_data(atlas, NULL),
    "Left-Caudate"
  )

  expect_identical(nrow(atlas_data), 2L)
  expect_identical(sort(atlas_data$label), c("Left-Caudate", "Right-Caudate"))
})

# Changed back deliberately. For a while the boundary refused a duplicated
# core label outright, which is the stricter behaviour -- but a published 2.x
# atlas is exactly where duplicates come from, and refusing them stopped such
# atlases drawing at all. The boundary now collapses the duplicate and says
# which label it collapsed.
test_that("ggseg3d() collapses a duplicated label with a warning", {
  atlas <- make_duplicate_label_atlas()

  expect_warning(result <- ggseg3d(atlas = atlas), "Left-Caudate")

  expect_s3_class(result, "ggseg3d")
})

# The complaint has to name the label. This atlas carries meshes; saying
# "no 3D data" would send the reader looking at geometry that is in fact
# there.
test_that("ggseg3d() says which label it collapsed", {
  atlas <- make_duplicate_label_atlas()

  expect_warning(ggseg3d(atlas = atlas), "duplicat")
  expect_true(ggseg.formats::has_atlas_3d(atlas))
})

test_that("unique atlas labels pass through untouched", {
  atlas <- ggseg.formats::set_atlas_palette(
    make_uniform_palette_atlas(),
    c("Left-Caudate" = "#123456", "Right-Caudate" = "#654321")
  )

  expect_silent(atlas_data <- prepare_mesh_atlas_data(atlas, NULL))
  expect_identical(nrow(atlas_data), 2L)
})
