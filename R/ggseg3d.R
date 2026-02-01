#' Plot 3D brain parcellations
#'
#' \code{ggseg3d} creates and returns an interactive Three.js brain mesh visualization.
#'
#' @author Athanasia Mowinckel and Didac Piñeiro
#'
#' @param .data A data.frame to use for plot aesthetics. Must include a
#' column called "region" corresponding to regions.
#' @param atlas Either a string with the name of a 3d atlas to use.
#' @param hemisphere String. Hemisphere to plot. Either "left" or "right"[default],
#' can also be "subcort".
#' @param surface String. Which surface to plot. Either "pial","white", or "inflated"[default]
#' @param label String. Quoted name of column in atlas/data that should be used to name traces
#' @param text String. Quoted name of column in atlas/data that should be added as extra
#' information in the hover text.
#' @param colour String. Quoted name of column from which colour should be supplied
#' @param palette String. Vector of colour names or HEX colours. Can also be a named
#' numeric vector, with colours as names, and breakpoint for that colour as the value
#' @param na.colour String. Either name, hex of RGB for colour of NA in colour.
#' @param na.alpha Numeric. A number between 0 and 1 to control transparency of NA-regions.
#' @param show.legend Logical. Toggle legend if colour is numeric.
#' @param camera String or list. Camera position preset or custom position.
#' @param background String. Background color (hex or named color).
#' @param width Numeric. Widget width in pixels.
#' @param height Numeric. Widget height in pixels.
#'
#' \strong{Available surfaces:}
#' \itemize{
#' \item `inflated:` Fully inflated surface
#' \item `semi-inflated:` Semi-inflated surface
#' \item `white:` white matter surface
#'  }
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
#' @return an htmlwidget object for interactive 3D brain visualization
#'
#' @importFrom dplyr filter full_join select distinct summarise mutate
#' @importFrom scales colour_ramp brewer_pal rescale gradient_n_pal
#' @importFrom tidyr unite
#' @importFrom htmlwidgets createWidget sizingPolicy
#'
#' @examples
#' ggseg3d()
#' ggseg3d(hemisphere = "left")
#' ggseg3d(surface = "inflated")
#' ggseg3d(show.legend = FALSE)
#'
#' @export
ggseg3d <- function(.data = NULL, atlas = "dk_3d",
                    surface = "LCBC", hemisphere = c("right", "subcort"),
                    label = "region", text = NULL, colour = "colour",
                    palette = NULL, na.colour = "darkgrey", na.alpha = 1,
                    show.legend = TRUE, camera = "right lateral",
                    background = "#ffffff",
                    width = NULL, height = NULL) {

  atlas3d <- get_atlas(atlas, surface = surface, hemisphere = hemisphere)

  if (!is.null(.data)) {
    atlas3d <- data_merge(.data, atlas3d)
  }

  pal.colours <- get_palette(palette)

  is_numeric_colour <- is.numeric(unlist(atlas3d[, colour]))

  if (is_numeric_colour) {
    data_min <- min(atlas3d[, colour], na.rm = TRUE)
    data_max <- max(atlas3d[, colour], na.rm = TRUE)

    if (data_min == data_max) {
      atlas3d$new_col <- pal.colours$orig[1]
      fill <- "new_col"
    } else {
      if (is.null(names(palette))) {
        pal.colours$values <- seq(data_min, data_max, length.out = nrow(pal.colours))
      }
      atlas3d$new_col <- gradient_n_pal(pal.colours$orig, pal.colours$values, "Lab")(
        unlist(atlas3d[, colour]))
      fill <- "new_col"
    }
  } else {
    fill <- colour
  }

  meshes <- list()
  for (tt in seq_len(nrow(atlas3d))) {
    col <- rep(unlist(atlas3d[tt, fill]), nrow(atlas3d$mesh[[tt]]$faces))
    col <- ifelse(is.na(col), na.colour, col)
    col <- unname(vapply(col, function(c) {
      if (grepl("^#", c)) c else col2hex(c)
    }, character(1)))

    op <- unname(ifelse(is.na(unlist(atlas3d[tt, fill])), na.alpha, 1))

    hover_text <- if (is.null(text)) {
      NULL
    } else {
      paste0(text, ": ", unlist(atlas3d[tt, text]))
    }

    meshes[[tt]] <- list(
      name = as.character(unlist(atlas3d[tt, label])),
      vertices = list(
        x = unname(as.numeric(atlas3d$mesh[[tt]]$vertices$x)),
        y = unname(as.numeric(atlas3d$mesh[[tt]]$vertices$y)),
        z = unname(as.numeric(atlas3d$mesh[[tt]]$vertices$z))
      ),
      faces = list(
        i = unname(as.integer(atlas3d$mesh[[tt]]$faces$i - 1)),
        j = unname(as.integer(atlas3d$mesh[[tt]]$faces$j - 1)),
        k = unname(as.integer(atlas3d$mesh[[tt]]$faces$k - 1))
      ),
      colors = col,
      colorMode = "facecolor",
      opacity = op,
      hoverText = hover_text
    )
  }

  legend_data <- NULL
  if (show.legend) {
    if (is_numeric_colour && data_min != data_max) {
      if (!is.null(names(palette))) {
        bp_min <- min(pal.colours$values)
        bp_max <- max(pal.colours$values)
        legend_data <- list(
          type = "continuous",
          title = colour,
          min = bp_min,
          max = bp_max,
          colors = unname(sapply(pal.colours$orig, col2hex)),
          breakpoints = unname(pal.colours$values)
        )
      } else {
        colorbar_values <- seq(data_min, data_max, length.out = 10)
        colorbar_colors <- gradient_n_pal(pal.colours$orig, pal.colours$values, "Lab")(colorbar_values)

        legend_data <- list(
          type = "continuous",
          title = colour,
          min = data_min,
          max = data_max,
          colors = unname(colorbar_colors),
          values = unname(colorbar_values)
        )
      }
    } else if (!is_numeric_colour) {
      unique_values <- unique(unlist(atlas3d[, colour]))
      unique_values <- unique_values[!is.na(unique_values)]
      unique_labels <- unique(unlist(atlas3d[, label]))
      unique_labels <- unique_labels[!is.na(unique_labels)]

      if (length(unique_values) <= 50) {
        color_label_map <- stats::setNames(
          as.character(unlist(atlas3d[, colour])),
          as.character(unlist(atlas3d[, label]))
        )
        color_label_map <- color_label_map[!is.na(names(color_label_map))]
        color_label_map <- color_label_map[!duplicated(names(color_label_map))]

        legend_data <- list(
          type = "discrete",
          title = label,
          labels = unname(names(color_label_map)),
          colors = unname(color_label_map)
        )
      }
    }
  }

  options <- list(
    camera = camera,
    showLegend = show.legend,
    backgroundColor = background
  )

  x <- list(
    meshes = meshes,
    options = options,
    colorbar = legend_data
  )

  htmlwidgets::createWidget(
    name = "ggseg3d",
    x = x,
    width = width,
    height = height,
    package = "ggseg3d",
    sizingPolicy = htmlwidgets::sizingPolicy(
      defaultWidth = 600,
      defaultHeight = 500,
      viewer.defaultHeight = 500,
      viewer.defaultWidth = 600,
      browser.defaultHeight = 500,
      browser.defaultWidth = 600,
      knitr.defaultWidth = 600,
      knitr.defaultHeight = 500,
      padding = 0,
      browser.fill = TRUE
    )
  )
}

if (getRversion() >= "2.15.1") {
  utils::globalVariables(c("tt", "surf", "mesh", "new_col"))
}
