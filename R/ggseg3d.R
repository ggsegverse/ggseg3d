#' Plot 3D brain parcellations
#'
#' `ggseg3d` creates and returns an interactive Three.js brain mesh
#' visualization.
#'
#' @author Athanasia Mowinckel and Didac Piñeiro
#'
#' @param .data A data.frame to use for plot aesthetics. Must include a
#'   column called "region" corresponding to regions.
#' @param atlas Either a string with the name of a 3d atlas to use, or a
#'   `brain_atlas` object containing 3D vertex mappings.
#' @param hemisphere String. Hemisphere to plot. Either "left" or
#'   "right"
#'
#'
#' , can also be "subcort".
#' @param surface String. Which surface to plot. Either "pial", "white",
#'
#'
#'
#'   or "inflated"
#'
#'
#' .
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
#' @param edge_by String. Column name to use for computing region boundary
#'   edges. If provided, edges are drawn between regions with different
#'
#'
#'   values in this column, allowing edge boundaries independent of display
#'   colours. When set, edges are displayed by default (black, width 1).
#'   Use [set_edges()] to customise appearance.
#' @param tract_color String. How to colour tract atlases: "palette"
#'   (default, use atlas palette) or "orientation" (direction-based RGB
#'   where R=left-right, G=anterior-posterior, B=superior-inferior).
#'   Only applies to tract atlases.
#'
#' \strong{Available surfaces:}
#' \itemize{
#' \item `inflated:` Fully inflated surface
#' \item `semi-inflated:` Semi-inflated surface
#' \item `white:` white matter surface
#'  }
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

  render_brain_atlas(
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
}


#' Render brain_atlas in 3D
#'
#' Internal function for rendering brain_atlas objects that contain
#' vertex mappings or per-region meshes. Uses vertex-based coloring for
#' cortical atlases on shared brain meshes, or face-based coloring for
#' subcortical/tract atlases with per-region mesh data.
#'
#' @inheritParams ggseg3d
#' @return an htmlwidget object
#' @importFrom rlang .data
#' @keywords internal
render_brain_atlas <- function(
  .data = NULL,
  atlas,
  surface = "inflated",
  hemisphere = c("right", "left"),
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  tract_color = "palette"
) {
  prepared <- prepare_brain_meshes(
    .data = .data,
    atlas = atlas,
    surface = surface,
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

  create_ggseg3d_widget(prepared$meshes, prepared$legend_data)
}


#' Prepare brain meshes and legend data
#'
#' Shared pipeline that builds mesh data structures and legend data from
#' a brain_atlas. Used by both [render_brain_atlas()] for htmlwidget output
#' and [ggsegray()] for rgl/rayshader output.
#'
#' @inheritParams ggseg3d
#' @return List with `meshes` (list of mesh entries) and `legend_data`
#' @importFrom rlang .data
#' @keywords internal
prepare_brain_meshes <- function(
  .data = NULL,
  atlas,
  surface = "inflated",
  hemisphere = c("right", "left"),
  label = "region",
  text = NULL,
  colour = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  tract_color = "palette"
) {
  is_mesh_based <- is_mesh_atlas(atlas)
  atlas_type <- atlas$type %||% "cortical"

  if (is_mesh_based && atlas_type %in% c("subcortical", "tract")) {
    hemisphere <- "subcort"
  }

  color_by <- if (atlas_type == "tract" && tract_color == "orientation") {
    "orientation"
  } else {
    "colour"
  }

  if (is_mesh_based) {
    atlas_data <- prepare_mesh_atlas_data(atlas, .data)
  } else {
    atlas_data <- prepare_atlas_data(atlas, .data)
  }

  colour_result <- apply_colour_palette(
    atlas_data,
    colour,
    palette,
    na_colour
  )
  atlas_data <- colour_result$data
  fill <- colour_result$fill
  pal_colours <- colour_result$palette

  atlas_meshes <- if (is_mesh_based) {
    if (!is.null(atlas$data$meshes)) atlas$data$meshes else atlas$meshes
  } else {
    NULL
  }

  atlas_centerlines <- if (!is.null(atlas$data$centerlines)) {
    list(
      centerlines = atlas$data$centerlines,
      tube_radius = atlas$data$tube_radius %||% 5,
      tube_segments = atlas$data$tube_segments %||% 8
    )
  } else {
    NULL
  }

  meshes <- build_meshes(
    atlas_data,
    hemisphere,
    surface,
    na_colour,
    edge_by,
    atlas_meshes,
    atlas_type,
    color_by,
    atlas_centerlines
  )

  # nolint start: object_usage_linter
  legend_data <- build_legend_data(
    is_numeric = colour_result$is_numeric,
    data_min = colour_result$data_min,
    data_max = colour_result$data_max,
    palette = palette,
    pal_colours = pal_colours,
    colour_col = colour,
    label_col = label,
    fill_col = fill,
    data = atlas_data
  )
  # nolint end

  list(meshes = meshes, legend_data = legend_data)
}
