#' Add glass brain to ggseg3d plot
#'
#' Adds a translucent brain on top of a ggseg3d plot
#' to create a point of reference, particularly
#' important for sub-cortical plots.
#'
#' @param p ggseg3d widget object
#' @param hemisphere string. hemisphere to plot ("left" or "right")
#' @param colour string. colour to give the glass brain
#' @param opacity numeric. transparency of the glass brain (0-1 float)
#'
#' @return ggseg3d widget object with glass brain tri-surface mesh
#' @export
#'
#' @examples
#'
#' ggseg3d(atlas = "aseg_3d") |>
#'    add_glassbrain("left")
add_glassbrain <- function(
  p,
  hemisphere = c("left", "right"),
  colour = "#cecece",
  opacity = 0.3
) {
  check_ggseg3d(p)

  cortex <- dplyr::filter(cortex_3d, hemi %in% hemisphere)
  cortex <- tidyr::unnest(cortex, ggseg_3d)

  colour <- if (grepl("^#", colour)) {
    colour
  } else {
    col2hex(colour)
  }

  new_meshes <- list()
  for (tt in seq_len(nrow(cortex))) {
    n_faces <- length(cortex$mesh[[tt]]$it[1, ])
    col <- rep(colour, n_faces)

    new_meshes[[tt]] <- list(
      name = "cerebral cortex",
      vertices = list(
        x = unname(as.numeric(cortex$mesh[[tt]]$vb["xpts", ])),
        y = unname(as.numeric(cortex$mesh[[tt]]$vb["ypts", ])),
        z = unname(as.numeric(cortex$mesh[[tt]]$vb["zpts", ]))
      ),
      faces = list(
        i = unname(as.integer(cortex$mesh[[tt]]$it[1, ] - 1)),
        j = unname(as.integer(cortex$mesh[[tt]]$it[2, ] - 1)),
        k = unname(as.integer(cortex$mesh[[tt]]$it[3, ] - 1))
      ),
      colors = unname(col),
      colorMode = "facecolor",
      opacity = opacity,
      hoverText = NULL
    )
  }

  p$x$meshes <- c(p$x$meshes, new_meshes)
  p
}

#' Pan camera position of ggseg3d plot
#'
#' Sets the camera position for a ggseg3d widget
#' to standard anatomical views or custom positions.
#'
#' @param p ggseg3d widget object
#' @param camera string or list. Camera position preset name or custom eye position.
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
#'
#' ggseg3d() |>
#'    pan_camera("right lateral")
pan_camera <- function(p, camera) {
  check_ggseg3d(p)
  if (!is.character(camera) && !is.list(camera)) {
    cli::cli_abort(
      "{.arg camera} must be a character string or list, not {.obj_type_friendly {camera}}."
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
#'
#' ggseg3d() |>
#'    set_background("black")
set_background <- function(p, colour = "#ffffff") {
  check_ggseg3d(p)

  if (!grepl("^#", colour)) {
    colour <- col2hex(colour)
  }

  p$x$options$backgroundColor <- colour
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
#' @param delay numeric. Seconds to wait for widget to render before capture (default: 1)
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
snapshot_brain <- function(
  p,
  file,
  width = 600,
  height = 500,
  delay = 1,
  zoom = 2,
  ...
) {
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
