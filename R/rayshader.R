utils::globalVariables("dk")

#' Render brain atlas with rgl
#'
#' Creates an rgl 3D scene from a brain atlas. Uses the same atlas
#' preparation pipeline as [ggseg3d()] but outputs to rgl instead of
#' htmlwidgets. The resulting scene can be piped into [pan_camera()],
#' [add_glassbrain()], and [set_background()], then rendered with
#' rayshader's `render_highquality()` or captured with `rgl::snapshot3d()`.
#'
#' @inheritParams ggseg3d
#' @param specular Character. Specular reflection colour for the mesh
#'   material. Set to `"black"` for a fully matte surface. Default `"white"`.
#' @param shininess Numeric. Shininess coefficient for specular highlights.
#'   Higher values produce tighter, glossier highlights. Default `50`.
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
  atlas = dk, # nolint [object_usage_linter]
  surface = "LCBC",
  hemisphere = c("right", "subcort"),
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  tract_color = c("palette", "orientation"),
  specular = "black",
  shininess = 128,
  brain_meshes = NULL
) {
  rlang::check_installed("rgl", reason = "to render 3D brain scenes")

  tract_color <- match.arg(tract_color)

  if (!inherits(atlas, "ggseg_atlas") && !inherits(atlas, "brain_atlas")) {
    cli::cli_abort(
      "{.arg atlas} must be a {.cls ggseg_atlas} object,
      not {.obj_type_friendly {atlas}}."
    )
  }

  if (!is_unified_atlas(atlas)) {
    cli::cli_abort(c(
      "{.arg atlas} is a {.cls ggseg_atlas} but has no 3D data.",
      "i" = "Use atlases from {.pkg ggseg.formats}
      that include vertex or mesh data."
    ))
  }

  unified_surface <- if (surface == "LCBC") "inflated" else surface

  # nolint start [object_usage_linter]
  prepared <- prepare_brain_meshes(
    .data = .data,
    atlas = atlas,
    surface = unified_surface,
    hemisphere = hemisphere,
    label = label,
    text = text,
    colour = colour,
    palette = palette,
    na_colour = na_colour,
    na_alpha = na_alpha,
    edge_by = edge_by,
    tract_color = tract_color,
    brain_meshes = brain_meshes
  )
  # nolint end

  rgl::open3d()

  for (mesh_entry in prepared$meshes) {
    mesh3d <- mesh_entry_to_mesh3d(
      mesh_entry,
      specular = specular,
      shininess = shininess
    )
    rgl::shade3d(mesh3d)
    render_edges_rgl(mesh_entry)
  }

  structure(
    list(
      device = rgl::cur3d(),
      hemisphere = hemisphere,
      surface = unified_surface
    ),
    class = "ggsegray"
  )
}


#' Convert mesh entry to rgl mesh3d object
#'
#' Converts the internal mesh_entry list structure (as built by
#' [make_mesh_entry()]) into an [rgl::tmesh3d()] object for rgl rendering.
#'
#' @param mesh_entry A mesh entry list with vertices, faces, colors,
#'   colorMode, and opacity.
#' @param specular Character. Specular reflection colour.
#' @param shininess Numeric. Shininess coefficient.
#'
#' @return An rgl `mesh3d` object
#' @keywords internal
mesh_entry_to_mesh3d <- function(
  mesh_entry,
  specular = "white",
  shininess = 50
) {
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
      alpha = alpha,
      specular = specular,
      shininess = shininess
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


#' Compute rgl rotation matrix to look at the origin from a given position
#'
#' Builds a 4x4 rotation matrix suitable for `rgl::view3d(userMatrix = ...)`
#' that orients the scene as if the camera is at `eye` looking toward the
#' origin with z pointing up.
#'
#' @param eye Numeric vector of length 3 (x, y, z) — camera position.
#'
#' @return A 4x4 rotation matrix.
#' @keywords internal
look_at_origin <- function(eye) {
  eye_n <- eye / sqrt(sum(eye^2))

  up <- c(0, 0, 1)
  if (abs(eye_n[3]) > 0.999) {
    up <- c(0, 1, 0)
  }

  fwd <- -eye_n
  right <- c(
    fwd[2] * up[3] - fwd[3] * up[2],
    fwd[3] * up[1] - fwd[1] * up[3],
    fwd[1] * up[2] - fwd[2] * up[1]
  )
  right <- right / sqrt(sum(right^2))

  actual_up <- c(
    right[2] * fwd[3] - right[3] * fwd[2],
    right[3] * fwd[1] - right[1] * fwd[3],
    right[1] * fwd[2] - right[2] * fwd[1]
  )

  m <- diag(4)
  m[1, 1:3] <- right
  m[2, 1:3] <- actual_up
  m[3, 1:3] <- eye_n
  m
}


render_edges_rgl <- function(mesh_entry) {
  edges <- mesh_entry$boundaryEdges
  edge_color <- mesh_entry$edgeColor
  if (is.null(edges) || is.null(edge_color) || length(edges) == 0) {
    return(invisible(NULL))
  }

  edge_width <- mesh_entry$edgeWidth %||% 1
  verts <- mesh_entry$vertices

  edge_matrix <- do.call(rbind, edges)
  idx1 <- edge_matrix[, 1] + 1L
  idx2 <- edge_matrix[, 2] + 1L

  x <- as.vector(rbind(verts$x[idx1], verts$x[idx2]))
  y <- as.vector(rbind(verts$y[idx1], verts$y[idx2]))
  z <- as.vector(rbind(verts$z[idx1], verts$z[idx2]))

  rgl::segments3d(x, y, z, color = edge_color, lwd = edge_width)
  invisible(NULL)
}


#' @export
print.ggsegray <- function(x, ...) {
  rgl::set3d(x$device)
  print(rgl::rglwidget())
}

#' @importFrom knitr knit_print
#' @export
knit_print.ggsegray <- function(x, ...) {
  rgl::set3d(x$device)
  knitr::knit_print(rgl::rglwidget(), ...)
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
