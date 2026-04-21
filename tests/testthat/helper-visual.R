# Stable textual summary of a ggseg3d widget's meshes for use with
# expect_snapshot(). Captures enough shape/color information to catch
# coordinate regressions (e.g. overlapping hemispheres, wrong axis),
# missing meshes, and colour-mapping breakage, without relying on
# WebGL rendering (which varies across machines).

widget_summary <- function(p, coord_digits = 1) {
  meshes <- p$x$meshes
  if (length(meshes) == 0) return(data.frame())

  rows <- lapply(meshes, function(m) {
    v <- m$vertices
    f <- m$faces
    x_range <- round(range(v$x), coord_digits)
    y_range <- round(range(v$y), coord_digits)
    z_range <- round(range(v$z), coord_digits)

    colors <- m$colors %||% character(0)
    colors <- colors[!is.na(colors)]

    data.frame(
      name = m$name %||% NA_character_,
      n_vertices = length(v$x),
      n_faces = if (is.null(f)) NA_integer_ else length(f$i),
      x_min = x_range[1], x_max = x_range[2],
      y_min = y_range[1], y_max = y_range[2],
      z_min = z_range[1], z_max = z_range[2],
      color_mode = m$colorMode %||% NA_character_,
      n_colors = length(unique(colors)),
      color_digest = substr(rlang::hash(sort(unique(colors))), 1, 8),
      opacity = m$opacity %||% 1,
      is_flatmap = isTRUE(m$isFlatmap),
      stringsAsFactors = FALSE
    )
  })

  do.call(rbind, rows)
}


# Build a minimal cerebellar_atlas for testing so we do not depend on
# external atlas packages.
make_test_cerebellar_atlas <- function() {
  n_verts <- nrow(ggseg.formats::get_cerebellar_mesh()$vertices)

  vertices_data <- data.frame(
    label = c("left_I-IV", "right_I-IV"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:99L, 100L:199L)

  structure(
    list(
      atlas = "test_cerebellar",
      type = "cerebellar",
      core = data.frame(
        label = c("left_I-IV", "right_I-IV"),
        region = c("I-IV", "I-IV"),
        hemi = c("left", "right"),
        stringsAsFactors = FALSE
      ),
      data = structure(
        list(vertices = vertices_data),
        class = c("ggseg_data_cerebellar", "ggseg_atlas_data")
      ),
      palette = c("left_I-IV" = "#FF0000", "right_I-IV" = "#00FF00")
    ),
    class = c("cerebellar_atlas", "ggseg_atlas", "list")
  )
}
