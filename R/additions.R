#' Add glass brain to ggseg3d plot
#'
#' Adds a translucent brain surface to a ggseg3d plot for anatomical reference.
#' Particularly useful for subcortical and tract visualizations where spatial
#' context helps interpretation.
#'
#' @param p ggseg3d widget object
#' @param hemisphere Character vector. Hemispheres to add: "left", "right",
#'   or both.
#' @param surface Character. Surface type: "inflated", "white", or "pial".
#' @param colour Character. Colour for the glass brain surface (hex or named).
#' @param opacity Numeric. Transparency of the glass brain (0-1).
#'
#' @return ggseg3d widget object with glass brain tri-surface mesh
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d(atlas = my_tract_atlas, hemisphere = "subcort") |>
#'   add_glassbrain() |>
#'   pan_camera("left lateral")
#'
#' ggseg3d(atlas = aseg) |>
#'   add_glassbrain("left", opacity = 0.2)
#' }
add_glassbrain <- function(
    p,
    hemisphere = c("left", "right"),
    surface = "pial",
    colour = "#CCCCCC",
    opacity = 0.3) {
  check_ggseg3d(p)

  colour <- if (grepl("^#", colour)) colour else col2hex(colour)
  hemi_map <- c("left" = "lh", "right" = "rh")

  new_meshes <- list()

  for (hemi in hemisphere) {
    hemi_short <- hemi_map[hemi]
    mesh <- get_brain_mesh(hemisphere = hemi_short, surface = surface)

    if (is.null(mesh)) {
      cli::cli_warn(
        "Brain mesh not available for {.val {hemi}} {.val {surface}}. Skipping."
      )
      next
    }

    vertices <- position_hemisphere(mesh$vertices, hemi)

    n_vertices <- nrow(vertices)
    vertex_colors <- rep(colour, n_vertices)

    new_meshes[[length(new_meshes) + 1]] <- make_mesh_entry(
      name = paste("glass brain", hemi),
      vertices = vertices,
      faces = mesh$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      opacity = opacity
    )
  }

  p$x$meshes <- c(new_meshes, p$x$meshes)
  p
}


#' Pan camera position of ggseg3d plot
#'
#' Sets the camera position for a ggseg3d widget
#' to standard anatomical views or custom positions.
#'
#' @param p ggseg3d widget object
#' @param camera string or list. Camera position preset name or custom eye
#'   position.
#'
#' \strong{Available camera presets:}
#' \itemize{
#' \item `left lateral` or `left_lateral`
#' \item `left medial` or `left_medial`
#' \item `right lateral` or `right_lateral`
#' \item `right medial` or `right_medial`
#' \item `left superior` or `left_superior`
#' \item `right superior` or `right_superior`
#' \item `left inferior` or `left_inferior`
#' \item `right inferior` or `right_inferior`
#' \item `left anterior` or `left_anterior`
#' \item `right anterior` or `right_anterior`
#' \item `left posterior` or `left_posterior`
#' \item `right posterior` or `right_posterior`
#' }
#'
#' @return ggseg3d widget object with updated camera
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   pan_camera("right lateral")
#' }
pan_camera <- function(p, camera) {
  check_ggseg3d(p)
  if (!is.character(camera) && !is.list(camera)) {
    cli::cli_abort(
      c(
        "{.arg camera} must be a character string or list,",
        "not {.obj_type_friendly {camera}}."
      )
    )
  }

  p$x$options$camera <- camera
  p
}


#' Set background color of ggseg3d plot
#'
#' Changes the background color of a ggseg3d widget.
#'
#' @param p ggseg3d widget object
#' @param colour string. Background color (hex or named color)
#'
#' @return ggseg3d widget object with updated background
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   set_background("black")
#' }
set_background <- function(p, colour = "#ffffff") {
  check_ggseg3d(p)

  if (!grepl("^#", colour)) {
    colour <- col2hex(colour)
  }

  p$x$options$backgroundColor <- colour
  p
}


#' Set legend visibility
#'
#' Controls visibility of the colour bar legend for numeric data.
#'
#' @param p ggseg3d widget object
#' @param show logical. Whether to show the legend (default: TRUE)
#'
#' @return ggseg3d widget object with updated legend visibility
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |> set_legend(FALSE)
#' }
set_legend <- function(p, show = TRUE) {
  check_ggseg3d(p)
  p$x$options$showLegend <- show
  p
}


#' Set widget dimensions
#'
#' Changes the width and height of a ggseg3d widget.
#'
#' @param p ggseg3d widget object
#' @param width numeric. Widget width in pixels (NULL for default)
#' @param height numeric. Widget height in pixels (NULL for default)
#'
#' @return ggseg3d widget object with updated dimensions
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   set_dimensions(width = 800, height = 600)
#' }
set_dimensions <- function(p, width = NULL, height = NULL) {
  check_ggseg3d(p)
  if (!is.null(width)) {
    p$width <- width
  }
  if (!is.null(height)) {
    p$height <- height
  }
  p
}


#' Set region boundary edges
#'
#' Adds coloured outlines around brain regions. This is useful for
#' highlighting region boundaries in figures.
#'
#' @param p ggseg3d widget object
#' @param colour string. Edge colour (hex or named color). Set to NULL to
#'   hide edges.
#' @param width numeric. Width of edge lines (default: 1). Note: line width > 1
#'   may not render on all systems due to WebGL limitations.
#'
#' @return ggseg3d widget object with updated edge settings
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d(hemisphere = "left") |>
#'   set_edges("black") |>
#'   pan_camera("left lateral")
#' }
set_edges <- function(p, colour = "black", width = 1) {
  check_ggseg3d(p)

  if (is.null(colour)) {
    for (i in seq_along(p$x$meshes)) {
      p$x$meshes[[i]]$edgeColor <- NULL
      p$x$meshes[[i]]$edgeWidth <- NULL
    }
  } else {
    edge_col <- if (grepl("^#", colour)) colour else col2hex(colour)
    for (i in seq_along(p$x$meshes)) {
      p$x$meshes[[i]]$edgeColor <- edge_col
      p$x$meshes[[i]]$edgeWidth <- width
    }
  }
  p
}


#' Enable flat shading for ggseg3d plot
#'
#' Disables lighting effects to show colors exactly as specified.
#' Useful for screenshots where accurate color reproduction is needed,
#' such as atlas creation pipelines that extract contours from images.
#'
#' @param p ggseg3d widget object
#' @param flat logical. Enable flat shading (default: TRUE)
#'
#' @return ggseg3d widget object with updated shading
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   set_flat_shading()
#' }
set_flat_shading <- function(p, flat = TRUE) {
  check_ggseg3d(p)
  p$x$options$flatShading <- flat
  p
}


#' Enable orthographic camera for ggseg3d plot
#'
#' Uses orthographic projection instead of perspective. This eliminates
#' perspective distortion and ensures consistent sizing across all views.
#'
#' @param p ggseg3d widget object
#' @param ortho logical. Enable orthographic mode (default: TRUE)
#' @param frustum_size numeric. Size of the orthographic frustum. Controls
#'   how much of the scene is visible. Default 220 works well for brain meshes.
#'   Use the same value across all views for consistent sizing.
#'
#' @return ggseg3d widget object with updated camera mode
#' @export
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   set_orthographic()
#' }
set_orthographic <- function(p, ortho = TRUE, frustum_size = 220) {
  check_ggseg3d(p)
  p$x$options$orthographic <- ortho
  p$x$options$frustumSize <- frustum_size
  p
}


#' Set hemisphere positioning mode
#'
#' Repositions meshes in a ggseg3d widget to either anatomical or centered mode.
#' This modifies the x-coordinates of all meshes in the widget.
#'
#' @param p ggseg3d widget object
#' @param positioning How to position hemispheres:
#'   - "anatomical": Offset so medial surfaces are adjacent at midline.
#'     Left at negative x, right at positive x. Best for displaying both
#'     hemispheres together.
#'   - "centered": Center each hemisphere at the origin. Best for
#'     single-hemisphere snapshots where consistent sizing is needed.
#'
#' @return ggseg3d widget object with repositioned meshes
#' @export
#'
#' @examples
#' \dontrun{
#' # View both hemispheres anatomically positioned
#' ggseg3d(hemisphere = c("left", "right")) |>
#'   set_positioning("anatomical") |>
#'   pan_camera("left lateral")
#'
#' # Atlas creation: centered (default) for consistent sizing
#' ggseg3d(hemisphere = "left") |>
#'   set_orthographic() |>
#'   pan_camera("left lateral") |>
#'   snapshot_brain("left_lateral.png")
#' }
set_positioning <- function(p, positioning = c("anatomical", "centered")) {
  check_ggseg3d(p)
  positioning <- match.arg(positioning)

  for (i in seq_along(p$x$meshes)) {
    mesh <- p$x$meshes[[i]]
    name <- mesh$name %||% ""

    is_left <- grepl("left", name, ignore.case = TRUE)
    is_right <- grepl("right", name, ignore.case = TRUE)

    if (!is_left && !is_right) next

    vertices <- mesh$vertices
    x_range <- range(vertices$x)
    half_width <- (x_range[2] - x_range[1]) / 2
    x_center <- mean(x_range)

    if (positioning == "centered") {
      vertices$x <- vertices$x - x_center
    } else {
      vertices$x <- vertices$x - x_center
      if (is_left) {
        vertices$x <- vertices$x - half_width
      } else if (is_right) {
        vertices$x <- vertices$x + half_width
      }
    }

    p$x$meshes[[i]]$vertices <- vertices
  }

  p
}


#' Save ggseg3d widget as image
#'
#' Takes a screenshot of a ggseg3d widget and saves it as a PNG image.
#' Requires a Chrome-based browser to be installed.
#'
#' @param p ggseg3d widget object
#' @param file string. Output file path (should end in .png)
#' @param width numeric. Image width in pixels (default: 600)
#' @param height numeric. Image height in pixels (default: 500)
#' @param delay numeric. Seconds to wait for widget to render before capture
#'   (default: 1)
#' @param zoom numeric. Zoom factor for higher resolution (default: 2)
#' @param ... Additional arguments passed to webshot2::webshot
#'
#' @return The file path (invisibly)
#' @export
#' @importFrom webshot2 webshot
#'
#' @examples
#' \dontrun{
#' ggseg3d() |>
#'   pan_camera("left lateral") |>
#'   snapshot_brain("brain.png")
#' }
# nocov start
snapshot_brain <- function(
    p,
    file,
    width = 600,
    height = 500,
    delay = 1,
    zoom = 2,
    ...) {
  check_ggseg3d(p)

  tmpfile <- tempfile(fileext = ".html")
  on.exit(unlink(tmpfile), add = TRUE)

  htmlwidgets::saveWidget(p, tmpfile, selfcontained = TRUE)

  webshot2::webshot(
    url = tmpfile,
    file = file,
    vwidth = width,
    vheight = height,
    delay = delay,
    zoom = zoom,
    ...
  )

  invisible(file)
}
# nocov end
