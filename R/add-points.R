#' Add points to a ggseg3d plot
#'
#' Draws markers at coordinates of your own -- electrode or sensor positions,
#' stimulation sites, anything with an `x`, `y` and `z`. Up to ggseg3d 1.6.5
#' this was done with plotly's `add_trace()`; plotly is no longer the
#' renderer, and this replaces it.
#'
#' @details
#' Coordinates are taken in the space of the surface already drawn, with `x`
#' left-right, `y` posterior-anterior and `z` inferior-superior. Which surface
#' that is decides whether measured positions land where they should:
#'
#' \itemize{
#'   \item `"pial"` and `"white"` are the anatomical surfaces. Pial spans
#'     about x -70 to 70, y -105 to 69 and z -48 to 79; white sits a few
#'     millimetres inside that. These are fsaverage surface coordinates, so
#'     positions recorded in a standard space land roughly where they belong
#'     without a transform.
#'   \item `"inflated"`, which [ggseg3d()] draws by default, is not
#'     anatomical. Inflation moves every vertex outward, leaving a rounder
#'     surface spanning about x -83 to 82 and z -73 to 73. Measured positions
#'     do not correspond to it, so plot them on `surface = "pial"` instead.
#' }
#'
#' A coordinate taken from a standard space is usually a point *inside* the
#' grey matter rather than on its surface, so a marker drawn at one can be
#' hidden by the cortex around it. Raise `size`, or draw the surface with
#' [add_glassbrain()] over a subcortical atlas, if a marker does not appear.
#'
#' Markers are drawn as small spheres, so they shade and occlude like the
#' rest of the scene rather than floating in front of it.
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
#' @return The input object, for piping. A `ggsegray` is returned unchanged:
#'   rgl draws to the open device rather than into the object.
#' @family brain modifiers
#' @export
#' @examplesIf rlang::is_installed("ggseg.meshes")
#' sensors <- data.frame(
#'   x = c(50, 45, 40),
#'   y = c(22, -10, -40),
#'   z = c(16, 40, 30),
#'   name = c("C4", "P4", "O2")
#' )
#'
#' \donttest{
#' # on an anatomical surface, so the coordinates mean something
#' ggseg3d(atlas = dk(), hemisphere = "right", surface = "pial") |>
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
  check_opacity(opacity)

  coords <- lapply(
    list(x = rlang::enquo(x), y = rlang::enquo(y), z = rlang::enquo(z)),
    function(q) rlang::eval_tidy(q, data)
  )
  text_values <- rlang::eval_tidy(rlang::enquo(text), data)

  markers <- resolve_markers(
    data = data,
    coords = coords,
    colour = colour,
    size = size,
    text = text_values
  )
  if (is.null(markers)) {
    return(p)
  }

  markers <- markers_mesh(
    x = markers$x,
    y = markers$y,
    z = markers$z,
    radius = markers$size,
    colour = markers$colour,
    text = markers$text
  )

  # The renderer reads vertexTexts only inside a vertexLabels branch, so a
  # marker with labels but no text shows nothing on hover. The label is what
  # the tooltip titles itself with.
  entry <- make_mesh_entry(
    name = "points",
    vertices = markers$vertices,
    faces = markers$faces,
    colors = markers$colours,
    color_mode = "vertexcolor",
    opacity = opacity,
    vertex_labels = markers$texts
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
#' @return The input object, for piping. A `ggsegray` is returned unchanged:
#'   rgl draws to the open device rather than into the object.
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

  entries <- added_atlas_meshes(p, atlas, is_rgl, ...)
  if (length(entries) == 0L) {
    cli::cli_warn("The atlas produced no meshes; nothing added.")
    return(p)
  }
  # The added atlas's own flatness needs no widget state, so it is checked
  # whichever renderer this is; only the host's does.
  host_flat <- !is_rgl && any_flatmap(p$x$meshes %||% list())
  if (any_flatmap(entries) || host_flat) {
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


#' Bring every per-marker argument to one validated value per marker
#'
#' Pulled out of `add_points()` because it is a distinct job: turn what the
#' caller supplied into exactly `n` of everything, or say why not. Coordinates
#' used to skip this, which let a scalar coordinate draw one marker and
#' silently discard the rest.
#'
#' @param data The caller's data.frame; its row count is the marker count.
#' @param coords List of evaluated `x`, `y` and `z`.
#' @param colour,size,text Per-marker arguments, length 1 or `nrow(data)`.
#' @return A list of equal-length `x`, `y`, `z`, `colour`, `size` and `text`,
#'   or `NULL` when nothing is left to draw.
#' @noRd
resolve_markers <- function(data, coords, colour, size, text) {
  n <- nrow(data)
  if (n == 0L) {
    cli::cli_warn("{.arg data} has no rows; no points added.")
    return(NULL)
  }

  coords <- lapply(names(coords), function(nm) {
    value <- recycle_markers(coords[[nm]], n, nm)
    if (!is.numeric(value)) {
      cli::cli_abort(c(
        "{.arg {nm}} must be numeric, not {.cls {class(value)[[1]]}}.",
        "i" = "Coordinates are positions in the surface's own space."
      ))
    }
    value
  })
  names(coords) <- c("x", "y", "z")

  out <- list(
    x = coords$x,
    y = coords$y,
    z = coords$z,
    colour = recycle_markers(colour, n, "colour"),
    size = recycle_markers(size, n, "size"),
    text = if (is.null(text)) {
      NULL
    } else {
      as.character(recycle_markers(text, n, "text"))
    }
  )

  # A marker with a missing coordinate would otherwise be drawn at the
  # origin, which is inside the brain and indistinguishable from a real
  # measurement.
  keep <- stats::complete.cases(out$x, out$y, out$z)
  if (!all(keep)) {
    dropped <- sum(!keep) # nolint: object_usage_linter
    cli::cli_warn("Dropped {dropped} marker{?s} with missing coordinates.")
    out <- lapply(out, function(v) if (is.null(v)) NULL else v[keep])
    if (length(out$x) == 0L) {
      return(NULL)
    }
  }

  out$colour <- resolve_marker_colours(out$colour)
  out
}


#' Marker transparency has to be a fraction
#' @noRd
check_opacity <- function(opacity, call = rlang::caller_env()) {
  if (
    !is.numeric(opacity) ||
      length(opacity) != 1L ||
      is.na(opacity) ||
      opacity < 0 ||
      opacity > 1
  ) {
    cli::cli_abort(
      c(
        "{.arg opacity} must be a single number between 0 and 1.",
        "x" = "Got {.val {opacity}}.",
        "i" = "It is a fraction, not a percentage."
      ),
      call = call
    )
  }
  invisible(opacity)
}


#' Turn marker colours into hex, refusing what is not a colour
#'
#' `col2rgb()` answers `NA` with white rather than an error, so a colour
#' column with a gap would draw those markers white and say nothing.
#' @noRd
resolve_marker_colours <- function(colour, call = rlang::caller_env()) {
  if (anyNA(colour)) {
    cli::cli_abort(
      c(
        "{.arg colour} has {sum(is.na(colour))} missing value{?s}.",
        "i" = "A missing colour would be drawn white, which reads as a
               deliberate choice."
      ),
      call = call
    )
  }

  vapply(
    as.character(colour),
    function(one) {
      if (grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", one)) {
        return(one)
      }
      if (grepl("^#", one)) {
        cli::cli_abort(
          "{.val {one}} is not a valid hex colour.",
          call = call
        )
      }
      col2hex(one)
    },
    character(1),
    USE.NAMES = FALSE
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


#' Does any mesh entry carry a flatmap?
#' @noRd
any_flatmap <- function(meshes) {
  any(vapply(meshes, function(m) isTRUE(m$isFlatmap), logical(1)))
}


#' Build the mesh entries for an atlas being added to an existing plot
#'
#' Separated from `add_atlas()` so the surface question has one home: left to
#' its own defaults the pipeline draws an inflated atlas, which beside an
#' anatomical one is the frame mismatch the flatmap guard refuses, in the
#' form people will actually hit.
#' @noRd
added_atlas_meshes <- function(p, atlas, is_rgl, ...) {
  dots <- list(...)
  if (!is_rgl && !"surface" %in% names(dots)) {
    host <- host_surface(p)
    if (!is.null(host)) {
      dots$surface <- host
    }
  }
  prepared <- do.call(prepare_brain_meshes, c(list(atlas), dots))
  prepared$meshes %||% list()
}


#' The surface an existing widget was drawn on
#'
#' `add_atlas()` re-enters the mesh pipeline, which would otherwise apply its
#' own default and quietly put an inflated atlas beside an anatomical one --
#' the same frame mismatch the flatmap guard refuses, in a form that is far
#' likelier. Mesh entries are named `"<hemisphere> <surface>"`, which is the
#' only record the widget keeps of what it was drawn on.
#'
#' @param p A `ggseg3d` widget.
#' @return The surface name, or `NULL` when no entry names one.
#' @noRd
host_surface <- function(p) {
  names <- vapply(
    p$x$meshes %||% list(),
    function(m) m$name %||% "",
    character(1)
  )
  found <- sub(
    "^(left|right) ",
    "",
    grep("^(left|right) ", names, value = TRUE)
  )
  found <- unique(found[nzchar(found)])
  if (length(found) != 1L) {
    return(NULL)
  }
  found
}
