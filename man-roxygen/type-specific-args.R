#' @section Type-specific arguments:
#' Cortical atlases (`cortical_atlas`):
#' \describe{
#'   \item{`surface`}{Surface type: `"LCBC"` (default, alias for
#'     inflated), `"inflated"`, `"semi-inflated"`, `"white"`, `"pial"`.}
#'   \item{`hemisphere`}{Character vector of hemispheres: `"right"`,
#'     `"left"`.}
#'   \item{`edge_by`}{Column name for region boundary edges.}
#'   \item{`brain_meshes`}{Custom brain mesh data.}
#' }
#'
#' Tract atlases (`tract_atlas`):
#' \describe{
#'   \item{`tract_color`}{`"palette"` (default) or `"orientation"`
#'     (direction-based RGB).}
#'   \item{`tube_radius`}{Tube radius override (numeric).}
#' }
