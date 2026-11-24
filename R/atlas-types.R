#' Check if atlas is a unified ggseg_atlas
#'
#' Checks whether an atlas object is a valid `ggseg_atlas` that carries
#' geometry `ggseg3d` can render in 3D: cortical or cerebellar vertices,
#' subcortical meshes, or tract centerlines.
#'
#' This used to reach into the list [ggseg.formats::atlas_data()] returns,
#' because the geometry accessors abort rather than answer when a component is
#' absent and there was no way to ask. [ggseg.formats::has_atlas_3d()] is that
#' way, so nothing in `ggseg3d` inspects an atlas's structure any more.
#'
#' @param atlas An atlas object to check
#'
#' @return Logical indicating if this is a renderable unified ggseg_atlas
#' @noRd
#' @keywords internal
is_unified_atlas <- function(atlas) {
  ggseg.formats::is_ggseg_atlas(atlas) &&
    ggseg.formats::has_atlas_3d(atlas)
}


#' Attach the atlas colours a plot should use
#'
#' Overwrites the `colour` column with [ggseg.formats::atlas_plot_palette()],
#' which substitutes distinguishable colours when the atlas palette gives
#' every region the same colour. Reading [ggseg.formats::atlas_palette()]
#' instead renders such atlases as a single indistinguishable silhouette.
#'
#' @inheritParams prepare_brain_meshes
#' @param atlas_data Data frame with a `label` column
#'
#' @return `atlas_data` with a `colour` column
#' @keywords internal
#' @noRd
with_plot_colours <- function(atlas, atlas_data) {
  atlas_data <- drop_duplicate_labels(atlas_data)
  palette <- ggseg.formats::atlas_plot_palette(atlas)
  atlas_data$colour <- unname(palette[atlas_data$label])
  atlas_data
}


#' Keep one geometry row per label
#'
#' `label` is the key the palette and every geometry slot join on, so a
#' duplicated label fans one region into several rows: the renderer draws it
#' twice, doubling its vertex count and double-darkening it under alpha
#' compositing. ggseg.formats warns about this at construction, but only once
#' per session, so an atlas restored from a package `.rda` reaches the plot
#' silently. Legend assembly already de-duplicates on `label`; this does the
#' same for the geometry.
#'
#' @param atlas_data Data frame with a `label` column
#'
#' @return `atlas_data` with at most one row per `label`
#' @keywords internal
#' @noRd
drop_duplicate_labels <- function(atlas_data) {
  if (!"label" %in% names(atlas_data)) {
    return(atlas_data)
  }

  is_duplicate <- duplicated(atlas_data$label)
  if (!any(is_duplicate)) {
    return(atlas_data)
  }

  dupes <- unique(atlas_data$label[is_duplicate]) # nolint: object_usage_linter
  cli::cli_warn(c(
    "Dropping {sum(is_duplicate)} duplicated atlas row{?s}: {.val {dupes}}.",
    "i" = "{.field label} must be unique; a duplicate draws the same region
           more than once."
  ))

  atlas_data[!is_duplicate, , drop = FALSE]
}


#' Prepare atlas data
#'
#' Extracts and prepares data from a ggseg_atlas object for rendering.
#' Joins vertices with core region info and plot palette colours.
#'
#' @param atlas A ggseg_atlas object
#' @param .data Optional user data to merge
#'
#' @return Prepared data frame with hemi, region, label, colour, and vertices
#' @keywords internal
#' @noRd
prepare_atlas_data <- function(atlas, .data) {
  atlas_data <- with_plot_colours(
    atlas,
    ggseg.formats::atlas_vertices(atlas)
  )

  if (!is.null(.data)) {
    atlas_data <- merge_atlas_data(.data, atlas_data)
  }

  atlas_data
}


#' Prepare mesh-based atlas data
#'
#' Extracts and prepares data from a mesh-based ggseg_atlas object
#' (subcortical/tract) for rendering. Joins meshes with core region info
#' and plot palette colours.
#'
#' @param atlas A mesh-based ggseg_atlas object
#' @param .data Optional user data to merge
#'
#' @return Prepared data frame with hemi, region, label, colour, and mesh
#' @keywords internal
#' @noRd
prepare_mesh_atlas_data <- function(atlas, .data) {
  base_data <- if (ggseg.formats::has_atlas_centerlines(atlas)) {
    centerline_metadata(atlas)
  } else {
    ggseg.formats::atlas_meshes(atlas)
  }

  atlas_data <- with_plot_colours(atlas, base_data)

  if (!is.null(.data)) {
    atlas_data <- data_merge_mesh(.data, atlas_data)
  }

  atlas_data
}


#' Tract centerline rows without their geometry columns
#'
#' Tract meshes are swept from the centerlines separately, so the prepared
#' data carries only the region metadata.
#'
#' @param atlas A tract `ggseg_atlas` object
#'
#' @return Data frame of centerline metadata
#' @keywords internal
#' @noRd
centerline_metadata <- function(atlas) {
  centerlines <- ggseg.formats::atlas_centerlines(atlas)
  geometry_cols <- c("points", "tangents")
  centerlines[, setdiff(names(centerlines), geometry_cols), drop = FALSE]
}


#' Merge user data with mesh atlas data
#'
#' @param .data User-provided data frame
#' @param atlas_data Atlas data frame
#' @return Merged data frame
#' @keywords internal
#' @noRd
data_merge_mesh <- function(.data, atlas_data) {
  join_cols <- intersect(c("region", "label", "hemi"), names(.data))

  if (length(join_cols) == 0) {
    cli::cli_warn("No common columns found for merging data with atlas")
    return(atlas_data)
  }

  dplyr::left_join(
    atlas_data,
    .data,
    by = join_cols,
    relationship = "many-to-many"
  )
}


#' Atlas rows without their geometry
#'
#' Colouring reads the metadata columns only, so the surface and nuclei rows
#' of a cerebellar atlas can be stacked into one frame -- and so share one
#' colour scale -- once the geometry each carries is set aside.
#'
#' @param atlas_data Prepared atlas data frame, or `NULL`
#'
#' @return `atlas_data` without its `vertices` or `mesh` column
#' @keywords internal
#' @noRd
mesh_metadata <- function(atlas_data) {
  atlas_data[setdiff(names(atlas_data), c("vertices", "mesh"))]
}
