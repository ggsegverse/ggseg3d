#' Add points to a ggseg3d plot
#'
#' Draws markers at coordinates of your own -- electrode or sensor positions,
#' stimulation sites, anything with an `x`, `y` and `z`. Up to ggseg3d 1.6.5
#' this was done with plotly's `add_trace()`; plotly is no longer the
#' renderer, and this replaces it.
#'
#' @details
#' Coordinates are taken in the same space the brain meshes are drawn in, so
#' they are the atlas's coordinates, not MNI: the inflated surfaces ship
#' centred on the origin with `x` left-right, `y` posterior-anterior and `z`
#' inferior-superior. Markers are drawn as small spheres, so they shade and
#' occlude like the rest of the scene rather than floating in front of it.
#'
#' @inheritParams add_glassbrain
#' @param data A data.frame of marker positions.
#' @param x,y,z Columns of `data` holding the coordinates.
#' @param colour Marker colour (hex or named), either one value or one per
#'   row of `data`.
#' @param size Marker radius, in the same units as the coordinates. One value
#'   or one per row.
#' @param text Column of `data` to show on hover, or `NULL` for none.
#' @param opacity Numeric. Marker transparency (0-1).
#'
#' @return The input object (modified), for piping.
#' @family brain modifiers
#' @export
#'
#' @examples
#' sensors <- data.frame(
#'   x = c(50, 45, 40),
#'   y = c(22, -10, -40),
#'   z = c(16, 40, 30),
#'   name = c("C4", "P4", "O2")
#' )
#'
#' \donttest{
#' ggseg3d(atlas = dk(), hemisphere = "right") |>
#'   add_points(sensors, x = x, y = y, z = z, text = name)
#' }
add_points <- function(
  p,
  data,
  x = x,
  y = y,
  z = z,
  colour = "#FF0000",
  size = 3,
  text = NULL,
  opacity = 1
) {
  is_rgl <- inherits(p, "ggsegray")
  if (is_rgl) {
    check_ggsegray(p)
  } else {
    check_ggseg3d(p)
  }

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a {.cls data.frame}.")
  }

  coords <- lapply(
    list(x = rlang::enquo(x), y = rlang::enquo(y), z = rlang::enquo(z)),
    function(q) rlang::eval_tidy(q, data)
  )
  text_values <- rlang::eval_tidy(rlang::enquo(text), data)

  n <- nrow(data)
  if (n == 0L) {
    cli::cli_warn("{.arg data} has no rows; no points added.")
    return(p)
  }

  colour <- vapply(
    recycle_markers(colour, n, "colour"),
    function(one) if (grepl("^#", one)) one else col2hex(one),
    character(1),
    USE.NAMES = FALSE
  )

  markers <- markers_mesh(
    x = coords$x,
    y = coords$y,
    z = coords$z,
    radius = recycle_markers(size, n, "size"),
    colour = colour,
    text = if (is.null(text_values)) {
      NULL
    } else {
      as.character(recycle_markers(text_values, n, "text"))
    }
  )

  entry <- make_mesh_entry(
    name = "points",
    vertices = markers$vertices,
    faces = markers$faces,
    colors = markers$colours,
    color_mode = "vertexcolor",
    opacity = opacity,
    vertex_texts = markers$texts
  )

  if (is_rgl) {
    rgl::shade3d(mesh_entry_to_mesh3d(entry))
  } else {
    p$x$meshes <- c(p$x$meshes, list(entry))
  }

  p
}


#' Add another atlas to a ggseg3d plot
#'
#' Draws a second atlas into an existing plot, so a subcortical atlas can sit
#' inside a cortical one, or two parcellations can be shown together.
#'
#' @details
#' Both atlases are drawn in their own coordinates, and nothing is registered
#' between them -- they line up because the ecosystem's atlases share an
#' anatomical frame, not because this reconciles them. A flat (2D) cerebellar
#' surface shares no frame with anatomical meshes, so combining one with
#' another atlas is refused rather than drawn misaligned.
#'
#' The added atlas keeps its own colours. The plot's legend describes the
#' atlas it was built from, so colour a second atlas by palette rather than
#' by values if the legend needs to be read.
#'
#' @inheritParams add_glassbrain
#' @param atlas A `ggseg_atlas` to add.
#' @param ... Passed to the atlas's mesh preparation, as in [ggseg3d()] --
#'   `hemisphere` and `surface` for a cortical atlas, for instance.
#'
#' @return The input object (modified), for piping.
#' @family brain modifiers
#' @export
#'
#' @examples
#' \donttest{
#' # subcortical structures inside a translucent cortex
#' ggseg3d(atlas = aseg()) |>
#'   add_glassbrain(opacity = 0.15)
#'
#' # or two atlases together
#' ggseg3d(atlas = dk(), hemisphere = "left") |>
#'   add_atlas(aseg())
#' }
add_atlas <- function(p, atlas, ...) {
  is_rgl <- inherits(p, "ggsegray")
  if (is_rgl) {
    check_ggsegray(p)
  } else {
    check_ggseg3d(p)
  }

  if (!inherits(atlas, "ggseg_atlas")) {
    cli::cli_abort(c(
      "{.arg atlas} must be a {.cls ggseg_atlas}.",
      "i" = "Use atlases from {.pkg ggseg.formats}."
    ))
  }

  prepared <- prepare_brain_meshes(atlas, ...)
  entries <- prepared$meshes %||% list()
  if (length(entries) == 0L) {
    cli::cli_warn("The atlas produced no meshes; nothing added.")
    return(p)
  }

  flat <- function(meshes) {
    any(vapply(meshes, function(m) isTRUE(m$isFlatmap), logical(1)))
  }
  if (!is_rgl && (flat(entries) || flat(p$x$meshes %||% list()))) {
    cli::cli_warn(c(
      "Skipping atlas: one of the two is a flat (2D) surface.",
      "i" = "Flatmap surfaces share no coordinate frame with anatomical
        meshes; combining them produces misaligned geometry."
    ))
    return(p)
  }

  if (is_rgl) {
    lapply(entries, function(entry) {
      rgl::shade3d(mesh_entry_to_mesh3d(entry))
    })
  } else {
    p$x$meshes <- c(p$x$meshes, entries)
  }

  p
}


#' A unit sphere, as vertices and faces
#'
#' Markers are drawn as geometry rather than as a new primitive so that the
#' renderer needs nothing it does not already do: a sphere is just another
#' indexed mesh with per-vertex colours.
#'
#' @param segments Number of divisions around and over the sphere. Eight is
#'   round enough at the size a marker is drawn and keeps a large montage
#'   cheap -- a sphere costs `(segments + 1)^2` vertices.
#' @return A list of `vertices` and `faces`, radius 1, centred on the origin.
#' @keywords internal
#' @noRd
unit_sphere <- function(segments = 8L) {
  phi <- seq(0, pi, length.out = segments + 1L)
  theta <- seq(0, 2 * pi, length.out = segments + 1L)
  grid <- expand.grid(phi = phi, theta = theta)

  vertices <- data.frame(
    x = sin(grid$phi) * cos(grid$theta),
    y = sin(grid$phi) * sin(grid$theta),
    z = cos(grid$phi)
  )

  n <- segments + 1L
  ring <- seq_len(segments)
  corner <- as.vector(outer(ring, (ring - 1L) * n, `+`))
  faces <- data.frame(
    i = c(corner, corner + 1L),
    j = c(corner + 1L, corner + n + 1L),
    k = c(corner + n, corner + n)
  )
  list(vertices = vertices, faces = faces)
}


#' Build one mesh holding every marker
#'
#' One entry rather than one per point: a montage is a single object to show,
#' hide and name, and the renderer walks far fewer meshes.
#' @noRd
markers_mesh <- function(x, y, z, radius, colour, text = NULL) {
  sphere <- unit_sphere()
  n_v <- nrow(sphere$vertices)
  n_f <- nrow(sphere$faces)
  n_p <- length(x)

  offset <- rep((seq_len(n_p) - 1L) * n_v, each = n_f)
  list(
    vertices = data.frame(
      x = rep(x, each = n_v) + rep(radius, each = n_v) * sphere$vertices$x,
      y = rep(y, each = n_v) + rep(radius, each = n_v) * sphere$vertices$y,
      z = rep(z, each = n_v) + rep(radius, each = n_v) * sphere$vertices$z
    ),
    faces = data.frame(
      i = rep(sphere$faces$i, n_p) + offset,
      j = rep(sphere$faces$j, n_p) + offset,
      k = rep(sphere$faces$k, n_p) + offset
    ),
    colours = rep(colour, each = n_v),
    texts = if (is.null(text)) NULL else rep(text, each = n_v)
  )
}


#' Recycle a per-marker argument to one value per marker
#' @noRd
recycle_markers <- function(value, n, arg, call = rlang::caller_env()) {
  if (length(value) == 1L) {
    return(rep(value, n))
  }
  if (length(value) != n) {
    cli::cli_abort(
      c(
        "{.arg {arg}} must be length 1 or {n}, not {length(value)}.",
        "i" = "One value for every marker, or one for all of them."
      ),
      call = call
    )
  }
  value
}
