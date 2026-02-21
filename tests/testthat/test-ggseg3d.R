test_that("Check that ggseg3d is working", {
  p <- ggseg3d()
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true("meshes" %in% names(p$x))
  expect_true("options" %in% names(p$x))
  expect_true(length(p$x$meshes) > 0)
  rm(p)

  lifecycle::expect_deprecated(
    p <- ggseg3d(atlas = "aseg")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)

  expect_error(ggseg3d(atlas = hhj), "object 'hhj")

  expect_warning(
    ggseg3d(
      .data = data.frame(
        region = c(
          "transverse tempral",
          "insula",
          "precentral",
          "superior parietal"
        ),
        p = sample(seq(0, .5, .001), 4),
        stringsAsFactors = FALSE
      ),
      colour_by = "p"
    )
  )

  some_data <- data.frame(
    region = c(
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal"
    ),
    p = sample(seq(0, .5, .001), 4),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    colour_by = "p",
    text_by = "p",
    palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  p <- ggseg3d(
    .data = some_data,
    colour_by = "p",
    text_by = "p",
    palette = c("black", "white")
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(!is.null(p$x$colorbar))
  expect_true(p$x$options$showLegend)

  p_hidden <- p |> set_legend(FALSE)
  expect_false(p_hidden$x$options$showLegend)

  p_sized <- ggseg3d() |> set_dimensions(width = 800, height = 600)
  expect_equal(p_sized$width, 800)
  expect_equal(p_sized$height, 600)
})

test_that("ggseg3d works with aseg subcortical atlas", {
  p <- ggseg3d(atlas = aseg())
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})

test_that("ggseg3d with left hemisphere only", {
  p <- ggseg3d(hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})

test_that("ggseg3d with inflated surface", {
  p <- ggseg3d(hemisphere = "left", surface = "inflated")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d handles edge_by parameter", {
  some_data <- data.frame(
    region = c(
      "transverse temporal",
      "insula",
      "precentral",
      "superior parietal"
    ),
    lobe = c("temporal", "insular", "frontal", "parietal"),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    hemisphere = "left",
    edge_by = "lobe"
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d default colorbar is present", {
  p <- ggseg3d()
  expect_true(!is.null(p$x$colorbar) || p$x$colorbar$type == "discrete")
})

test_that("ggseg3d with custom palette", {
  some_data <- data.frame(
    region = c("transverse temporal", "insula"),
    p = c(0.1, 0.9),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(
    .data = some_data,
    hemisphere = "left",
    colour_by = "p",
    palette = c("blue" = 0, "white" = 0.5, "red" = 1)
  )
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_equal(p$x$colorbar$type, "continuous")
})

test_that("ggseg3d with na_colour and na_alpha", {
  p <- ggseg3d(hemisphere = "left", na_colour = "red", na_alpha = 0.5)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with label_by parameter", {
  p <- ggseg3d(hemisphere = "left", label_by = "label")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("deprecated params trigger warnings", {
  some_data <- data.frame(
    region = c("precentral", "insula"),
    p = c(0.1, 0.5),
    stringsAsFactors = FALSE
  )

  lifecycle::expect_deprecated(
    ggseg3d(hemisphere = "left", colour = "colour")
  )
  lifecycle::expect_deprecated(
    ggseg3d(hemisphere = "left", label = "label")
  )
  lifecycle::expect_deprecated(
    ggseg3d(.data = some_data, text = "p")
  )
})

test_that("ggseg3d with both hemispheres", {
  p <- ggseg3d(hemisphere = c("left", "right"))
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) >= 2)
})

test_that("ggseg3d with atlas object instead of string", {
  p <- ggseg3d(atlas = dk(), hemisphere = "left")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d unified atlas without user data", {
  p <- ggseg3d(atlas = dk(), hemisphere = "left", .data = NULL)
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
})

test_that("ggseg3d with aseg mesh atlas", {
  p <- ggseg3d(atlas = aseg(), hemisphere = "subcort")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))
  expect_true(length(p$x$meshes) > 0)
})

test_that("ggseg3d errors on invalid atlas object", {
  expect_error(ggseg3d(atlas = list()), "ggseg_atlas")
  expect_error(ggseg3d(atlas = data.frame()), "ggseg_atlas")
})

test_that("prepare_brain_meshes handles atlas with centerlines", {
  atlas_data <- data.frame(
    label = "tract_a",
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

  cl_data <- data.frame(label = "tract_a", stringsAsFactors = FALSE)
  cl_data$points <- list(centerline)
  cl_data$tangents <- list(tangents)

  atlas <- structure(
    list(
      atlas = "test_tract",
      type = "tract",
      core = data.frame(
        label = "tract_a",
        region = "tract a",
        hemi = "subcort",
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(centerlines = cl_data),
        class = c("ggseg_data_tract", "ggseg_atlas_data")
      ),
      palette = c("tract_a" = "#FF0000")
    ),
    class = c("tract_atlas", "ggseg_atlas", "list")
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_type(prepared, "list")
  expect_true(length(prepared$meshes) > 0)
})

test_that("prepare_brain_meshes handles atlas$data$meshes path", {
  meshes_data <- data.frame(
    label = "Left-Caudate",
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(
    list(
      vertices = data.frame(x = 1:3, y = 1:3, z = 1:3),
      faces = data.frame(i = 1L, j = 2L, k = 3L)
    )
  )

  atlas <- structure(
    list(
      atlas = "test_subcort",
      type = "subcortical",
      core = data.frame(
        label = "Left-Caudate",
        region = "caudate",
        hemi = "subcort",
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(meshes = meshes_data),
        class = c("ggseg_data_subcortical", "ggseg_atlas_data")
      ),
      palette = c("Left-Caudate" = "#FF0000")
    ),
    class = c("subcortical_atlas", "ggseg_atlas", "list")
  )

  prepared <- prepare_brain_meshes(atlas)

  expect_type(prepared, "list")
  expect_true(length(prepared$meshes) > 0)
})

test_that("prepare_brain_meshes uses orientation coloring for tracts", {
  centerline <- matrix(
    c(0, 0, 0, 1, 0, 0, 2, 0, 0),
    nrow = 3, byrow = TRUE
  )
  tangents <- matrix(
    c(1, 0, 0, 0, 1, 0, 0, 0, 1),
    nrow = 3, byrow = TRUE
  )

  cl_data <- data.frame(label = "tract_a", stringsAsFactors = FALSE)
  cl_data$points <- list(centerline)
  cl_data$tangents <- list(tangents)

  meshes_data <- data.frame(
    label = "tract_a",
    stringsAsFactors = FALSE
  )
  meshes_data$mesh <- list(NULL)

  atlas <- structure(
    list(
      atlas = "test_tract",
      type = "tract",
      core = data.frame(
        label = "tract_a", region = "tract a", hemi = "subcort",
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(
          meshes = meshes_data,
          centerlines = cl_data
        ),
        class = c("ggseg_data_tract", "ggseg_atlas_data")
      ),
      palette = c("tract_a" = "#FF0000")
    ),
    class = c("tract_atlas", "ggseg_atlas", "list")
  )

  prepared <- prepare_brain_meshes(atlas, tract_color = "orientation")

  expect_true(length(prepared$meshes) > 0)
  expect_true(all(grepl("^#", prepared$meshes[[1]]$colors)))
})

test_that("prepare_brain_meshes.default errors on unknown atlas class", {
  fake <- structure(list(), class = "weird_atlas")
  expect_error(prepare_brain_meshes(fake), "No method")
})

test_that("ggseg3d errors on nonexistent string atlas name", {
  expect_error(
    lifecycle::expect_deprecated(
      ggseg3d(atlas = "nonexistent_atlas_xyz")
    ),
    "Could not find atlas"
  )
})

test_that("vertices_to_text returns NA vector when column is missing", {
  atlas_data <- data.frame(
    label = "a",
    region = "r",
    stringsAsFactors = FALSE
  )
  atlas_data$vertices <- list(c(0L, 1L))

  result <- vertices_to_text(atlas_data, 3, "nonexistent")

  expect_equal(length(result), 3)
  expect_true(all(is.na(result)))
})

test_that("text_by works with subcortical atlas", {
  some_data <- data.frame(
    region = c("Thalamus", "Caudate"),
    p = c(0.1, 0.5),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(.data = some_data, atlas = aseg(), text_by = "p")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  hover_texts <- vapply(
    p$x$meshes,
    function(m) m$hoverText %||% "",
    character(1)
  )
  expect_true(any(grepl("p:", hover_texts)))
})

test_that("text_by works with tract atlas", {
  some_data <- data.frame(
    region = c("arcuate fasciculus", "corticospinal tract"),
    fa = c(0.45, 0.55),
    stringsAsFactors = FALSE
  )

  p <- ggseg3d(.data = some_data, atlas = tracula(), text_by = "fa")
  expect_s3_class(p, c("ggseg3d", "htmlwidget"))

  hover_texts <- vapply(
    p$x$meshes,
    function(m) m$hoverText %||% "",
    character(1)
  )
  expect_true(any(grepl("fa:", hover_texts)))
})
