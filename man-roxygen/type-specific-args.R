#' @section Type-specific arguments:
#' Cortical atlases (`cortical_atlas`):
#' \describe{
#'   \item{`surface`}{`"LCBC"` (default, an alias for `"inflated"`) or any
#'     surface [resolve_brain_mesh()] accepts.}
#'   \item{`hemisphere`}{Character vector of hemispheres: `"left"`,
#'     `"right"`, or their `"lh"`/`"rh"` spellings.}
#'   \item{`edge_by`}{Column name for region boundary edges.}
#'   \item{`brain_meshes`}{Custom brain mesh data.}
#' }
#'
#' Cerebellar atlases (`cerebellar_atlas`):
#' \describe{
#'   \item{`surface_opacity`}{Opacity of the cerebellar surface mesh.
#'     Defaults to `0.3` when the atlas carries deep nuclei, so they stay
#'     visible through the surface, and `1` otherwise.}
#' }
#'
#' Tract atlases (`tract_atlas`):
#' \describe{
#'   \item{`tract_color`}{`"palette"` (default) or `"orientation"`
#'     (direction-based RGB).}
#'   \item{`tube_radius`}{Tube radius (numeric, default `2`).}
#'   \item{`tube_segments`}{Tube segment count (integer, default `10`).}
#' }
