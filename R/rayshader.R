#' Render brain atlas with rgl
#'
#' Creates an rgl 3D scene from a brain atlas. Uses the same atlas
#' preparation pipeline as [ggseg3d()] but outputs to rgl instead of
#' htmlwidgets. The resulting scene can be piped into [pan_camera()],
#' [add_glassbrain()], and [set_background()], then rendered with
#' rayshader's `render_highquality()` or captured with `rgl::snapshot3d()`.
#'
#' @inheritParams ggseg3d
#'
#' @return An object of class `ggsegray` (invisibly), which wraps the
#'   rgl device ID. Pipe into [pan_camera()], [add_glassbrain()], or
#'   [set_background()] to modify the scene.
#'
#' @examples
#' \dontrun{
#' ggsegray(hemisphere = "left") |>
#'   pan_camera("left lateral")
#'
#' ggsegray(atlas = aseg) |>
#'   add_glassbrain(opacity = 0.15) |>
#'   pan_camera("right lateral") |>
#'   set_background("black")
#' }
#'
#' @export
ggsegray <- function(
  .data = NULL,
  atlas = "dk",
  surface = "LCBC",
  hemisphere = c("right", "subcort"),
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  tract_color = c("palette", "orientation")
) {
  rlang::check_installed("rgl", reason = "to render 3D brain scenes")

  tract_color <- match.arg(tract_color)
  atlas_obj <- if (is.character(atlas)) get(atlas) else atlas

  if (!is_unified_atlas(atlas_obj)) {
    cli::cli_abort(c(
      "Atlas must be a {.cls brain_atlas} object with 3D data.",
      "i" = "Use atlases from {.pkg ggseg.formats}.",
      "i" = "Create atlases with {.fn ggsegExtra::make_brain_atlas}."
    ))
  }

  unified_surface <- if (surface == "LCBC") "inflated" else surface

  prepared <- prepare_brain_meshes(
    .data = .data,
    atlas = atlas_obj,
    surface = unified_surface,
    hemisphere = hemisphere,
    label = label,
    text = text,
    colour = colour,
    palette = palette,
    na_colour = na_colour,
    na_alpha = na_alpha,
    edge_by = edge_by,
    tract_color = tract_color
  )

  rgl::open3d()

  for (mesh_entry in prepared$meshes) {
    mesh3d <- mesh_entry_to_mesh3d(mesh_entry)
    rgl::shade3d(mesh3d)
  }

  p <- structure(
    list(
      device = rgl::cur3d(),
      hemisphere = hemisphere,
      surface = unified_surface
    ),
    class = "ggsegray"
  )

  invisible(p)
}


#' Convert mesh entry to rgl mesh3d object
#'
#' Converts the internal mesh_entry list structure (as built by
#' [make_mesh_entry()]) into an [rgl::tmesh3d()] object for rgl rendering.
#'
#' @param mesh_entry A mesh entry list with vertices, faces, colors,
#'   colorMode, and opacity.
#'
#' @return An rgl `mesh3d` object
#' @keywords internal
mesh_entry_to_mesh3d <- function(mesh_entry) {
  rlang::check_installed("rgl", reason = "to convert meshes")

  vb <- rbind(
    mesh_entry$vertices$x,
    mesh_entry$vertices$y,
    mesh_entry$vertices$z,
    1
  )

  it <- rbind(
    mesh_entry$faces$i + 1L,
    mesh_entry$faces$j + 1L,
    mesh_entry$faces$k + 1L
  )

  mesh_color <- if (mesh_entry$colorMode == "vertexcolor") {
    "vertices"
  } else {
    "faces"
  }

  alpha <- mesh_entry$opacity %||% 1

  rgl::tmesh3d(
    vertices = vb,
    indices = it,
    material = list(
      color = mesh_entry$colors,
      alpha = alpha
    ),
    meshColor = mesh_color
  )
}


#' Map camera preset name to position vector
#'
#' Converts a camera preset string to an xyz position vector matching
#' the same presets used in the Three.js viewer.
#'
#' @param preset Character string naming the camera preset.
#'
#' @return Numeric vector of length 3 (x, y, z).
#' @keywords internal
camera_preset_to_position <- function(preset) {
  presets <- list(
    "left lateral" = c(-350, 0, 0),
    "left_lateral" = c(-350, 0, 0),
    "left medial" = c(350, 0, 0),
    "left_medial" = c(350, 0, 0),
    "right lateral" = c(350, 0, 0),
    "right_lateral" = c(350, 0, 0),
    "right medial" = c(-350, 0, 0),
    "right_medial" = c(-350, 0, 0),
    "left superior" = c(-120, 0, 330),
    "left_superior" = c(-120, 0, 330),
    "right superior" = c(120, 0, 330),
    "right_superior" = c(120, 0, 330),
    "left inferior" = c(-120, 0, -330),
    "left_inferior" = c(-120, 0, -330),
    "right inferior" = c(120, 0, -330),
    "right_inferior" = c(120, 0, -330),
    "left anterior" = c(-120, 330, 0),
    "left_anterior" = c(-120, 330, 0),
    "right anterior" = c(120, 330, 0),
    "right_anterior" = c(120, 330, 0),
    "left posterior" = c(-120, -330, 0),
    "left_posterior" = c(-120, -330, 0),
    "right posterior" = c(120, -330, 0),
    "right_posterior" = c(120, -330, 0)
  )

  pos <- presets[[preset]]
  if (is.null(pos)) {
    available <- unique(gsub("_", " ", names(presets))) # nolint: object_usage_linter
    cli::cli_abort(c(
      "Unknown camera preset {.val {preset}}.",
      "i" = "Available presets: {.val {available}}"
    ))
  }

  pos
}


check_ggsegray <- function(
  p,
  arg = rlang::caller_arg(p),
  call = rlang::caller_env()
) {
  if (!inherits(p, "ggsegray")) {
    cli::cli_abort(
      "{.arg {arg}} must be a {.cls ggsegray} object, not {.obj_type_friendly {p}}.", # nolint: line_length_linter
      call = call
    )
  }
  rlang::check_installed("rgl", reason = "to modify rgl scenes")
  rgl::set3d(p$device)
}
