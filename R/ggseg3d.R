#' Plot 3D brain parcellations
#'
#' `ggseg3d` creates and returns an interactive Three.js brain mesh
#' visualization. Dispatches to atlas-type-specific methods via
#' [prepare_brain_meshes()].
#'
#' @author Athanasia Mowinckel and Didac Piñeiro
#'
#' @param .data A data.frame to use for plot aesthetics. Must include a
#'   column called "region" corresponding to regions.
#' @param atlas Either a string with the name of a 3d atlas to use, or a
#'   `brain_atlas` object containing 3D vertex mappings.
#' @param label String. Quoted name of column in atlas/data that should
#'   be used to name traces
#' @param text String. Quoted name of column in atlas/data that should be
#'   added as extra information in the hover text.
#' @param colour String. Quoted name of column from which colour should
#'   be supplied
#' @param palette String. Vector of colour names or HEX colours. Can also
#'   be a named numeric vector, with colours as names, and breakpoint for
#'   that colour as the value
#' @param na_colour String. Either name, hex of RGB for colour of NA in
#'   colour.
#' @param na_alpha Numeric. A number between 0 and 1 to control
#'   transparency of NA-regions.
#' @param ... Type-specific arguments passed to the atlas method.
#'   See section **Type-specific arguments** below.
#'
#' @template type-specific-args
#'
#' @return an htmlwidget object for interactive 3D brain visualization
#'
#' @seealso [pan_camera()] for camera position, [set_background()] for
#'   background colour, [set_legend()] for legend visibility
#'
#' @importFrom dplyr filter full_join select distinct summarise mutate
#' @importFrom scales colour_ramp brewer_pal rescale gradient_n_pal
#' @importFrom tidyr unite
#' @importFrom htmlwidgets createWidget sizingPolicy
#' @importFrom lifecycle deprecate_warn
#' @importFrom rlang %||%
#'
#' @examples
#' \dontrun{
#' ggseg3d()
#' ggseg3d(hemisphere = "left") |> pan_camera("left lateral")
#' ggseg3d() |> set_legend(FALSE)
#' ggseg3d() |> set_background("black")
#' }
#'
#' @export
ggseg3d <- function(
  .data = NULL,
  atlas = "dk",
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  ...
) {
  atlas <- if (is.character(atlas)) get(atlas) else atlas

  if (!is_unified_atlas(atlas)) {
    cli::cli_abort(c(
      "Atlas must be a {.cls ggseg_atlas} object with 3D data.",
      "i" = "Use atlases from {.pkg ggseg.formats}.",
      "i" = "Create atlases with {.fn ggsegExtra::create_cortical_atlas}."
    ))
  }

  prepared <- prepare_brain_meshes(
    atlas,
    .data = .data,
    label = label,
    text = text,
    colour = colour,
    palette = palette,
    na_colour = na_colour,
    na_alpha = na_alpha,
    ...
  )

  create_ggseg3d_widget(prepared$meshes, prepared$legend_data)
}


# prepare_brain_meshes S3 generic ----

#' Prepare brain meshes and legend data
#'
#' S3 generic that dispatches to atlas-type-specific preparation methods.
#' Builds mesh data structures and legend data from a `brain_atlas`.
#'
#' @param atlas A `brain_atlas` object
#' @param ... Type-specific arguments passed to methods
#'
#' @return List with `meshes` (list of mesh entries) and `legend_data`
#' @keywords internal
prepare_brain_meshes <- function(atlas, ...) {
  UseMethod("prepare_brain_meshes")
}

#' @export
#' @keywords internal
prepare_brain_meshes.default <- function(atlas, ...) {
  cls <- paste(class(atlas), collapse = "/") # nolint: object_usage_linter
  cli::cli_abort(c(
    "No method for atlas of class {.val {cls}}.",
    "i" = "Expected {.cls cortical_atlas}, {.cls subcortical_atlas},
    or {.cls tract_atlas}."
  ))
}

#' @method prepare_brain_meshes cortical_atlas
#' @param .data Optional user data to merge
#' @param surface Surface type: `"inflated"` (default), `"semi-inflated"`,
#'   `"white"`, `"pial"`. Use `"LCBC"` as alias for `"inflated"`.
#' @param hemisphere Character vector of hemispheres: `"right"`, `"left"`.
#' @param label Column name for trace labels
#' @param text Column name for hover text
#' @param colour Column name for colour values
#' @param palette Colour palette specification
#' @param na_colour Colour for NA values
#' @param na_alpha Transparency for NA regions
#' @param edge_by Column name for region boundary edge grouping
#' @param brain_meshes Optional user-supplied brain meshes
#' @export
#' @rdname prepare_brain_meshes
#' @keywords internal
prepare_brain_meshes.cortical_atlas <- function(
  atlas,
  .data = NULL,
  surface = "LCBC",
  hemisphere = c("right", "left"),
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  brain_meshes = NULL,
  ...
) {
  surface <- if (surface == "LCBC") "inflated" else surface

  atlas_data <- prepare_atlas_data(atlas, .data)
  result <- apply_colours_and_legend(
    atlas_data,
    colour,
    palette,
    na_colour,
    label
  )
  meshes <- build_cortical_meshes(
    result$atlas_data,
    hemisphere,
    surface,
    na_colour,
    edge_by,
    brain_meshes
  )

  list(meshes = meshes, legend_data = result$legend_data)
}

#' @method prepare_brain_meshes subcortical_atlas
#' @export
#' @rdname prepare_brain_meshes
#' @keywords internal
prepare_brain_meshes.subcortical_atlas <- function(
  atlas,
  .data = NULL,
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  ...
) {
  atlas_data <- prepare_mesh_atlas_data(atlas, .data)
  result <- apply_colours_and_legend(
    atlas_data,
    colour,
    palette,
    na_colour,
    label
  )
  atlas_data <- to_native_coords(result$atlas_data)
  meshes <- build_subcortical_meshes(atlas_data, na_colour)

  list(meshes = meshes, legend_data = result$legend_data)
}

#' @method prepare_brain_meshes tract_atlas
#' @param tract_color `"palette"` (default) or `"orientation"`
#'   (direction-based RGB colouring)
#' @param tube_radius Numeric tube radius (default 5 when `NULL`).
#' @param tube_segments Integer tube segment count (default 8 when `NULL`).
#' @export
#' @rdname prepare_brain_meshes
#' @keywords internal
prepare_brain_meshes.tract_atlas <- function(
  atlas,
  .data = NULL,
  label = "region",
  text = NULL,

  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  tract_color = c("palette", "orientation"),
  tube_radius = 2,
  tube_segments = 10,
  ...
) {
  tract_color <- match.arg(tract_color)
  color_by <- if (tract_color == "orientation") "orientation" else "colour"

  atlas_data <- prepare_mesh_atlas_data(atlas, .data)
  result <- apply_colours_and_legend(
    atlas_data,
    colour,
    palette,
    na_colour,
    label
  )
  atlas_data <- to_native_coords(result$atlas_data)
  atlas_centerlines <- build_centerline_data(atlas, tube_radius, tube_segments)
  meshes <- build_tract_meshes(
    atlas_data,
    na_colour,
    color_by,
    atlas_centerlines
  )

  list(meshes = meshes, legend_data = result$legend_data)
}


# Shared helpers ----

#' Apply colour palette and build legend data
#'
#' Shared pipeline step for all atlas types: applies colour palette to
#' atlas data and builds the legend data structure.
#'
#' @param atlas_data Prepared atlas data frame
#' @param colour Column name for colour values
#' @param palette Colour palette specification
#' @param na_colour Colour for NA values
#' @param label Column name for labels
#'
#' @return List with `atlas_data` and `legend_data`
#' @keywords internal
apply_colours_and_legend <- function(
  atlas_data,
  colour,
  palette,
  na_colour,
  label
) {
  colour_result <- apply_colour_palette(
    atlas_data,
    colour,
    palette,
    na_colour
  )
  atlas_data <- colour_result$data

  # nolint start: object_usage_linter
  legend_data <- build_legend_data(
    is_numeric = colour_result$is_numeric,
    data_min = colour_result$data_min,
    data_max = colour_result$data_max,
    palette = palette,
    pal_colours = colour_result$palette,
    colour_col = colour,
    label_col = label,
    fill_col = colour_result$fill,
    data = atlas_data
  )
  # nolint end

  list(atlas_data = atlas_data, legend_data = legend_data)
}


#' Build centerline data for tract atlases
#'
#' Extracts centerline data from a tract atlas, applies native coordinate
#' offsets, and assembles the tube generation parameters.
#'
#' @param atlas A `tract_atlas` object
#' @param tube_radius Optional radius override
#' @param tube_segments Optional segment count override
#'
#' @return List with centerlines, tube_radius, tube_segments, or NULL
#' @keywords internal
build_centerline_data <- function(
  atlas,
  tube_radius = NULL,
  tube_segments = NULL
) {
  if (is.null(atlas$data$centerlines)) {
    return(NULL)
  }

  cl <- atlas$data$centerlines
  if (!is.null(cl$points)) {
    offset <- native_offset()
    cl$points <- lapply(cl$points, function(pts) {
      if (is.null(pts)) {
        return(pts)
      }
      pts[, 2] <- pts[, 2] + offset[["y"]]
      pts[, 3] <- pts[, 3] + offset[["z"]]
      pts
    })
  }

  list(
    centerlines = cl,
    tube_radius = tube_radius %||% 2,
    tube_segments = tube_segments %||% 10
  )
}
