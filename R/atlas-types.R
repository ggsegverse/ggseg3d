#' Check if atlas is a unified ggseg_atlas
#'
#' Checks whether an atlas object is a valid `ggseg_atlas` that carries
#' geometry `ggseg3d` can render in 3D: cortical or cerebellar vertices,
#' subcortical meshes, or tract centerlines.
#'
#' @param atlas An atlas object to check
#'
#' @return Logical indicating if this is a renderable unified ggseg_atlas
#' @noRd
#' @keywords internal
is_unified_atlas <- function(atlas) {
  ggseg.formats::is_ggseg_atlas(atlas) && any(atlas_3d_components(atlas))
}


#' Which 3D geometry components an atlas carries
#'
#' ggseg.formats exposes no predicate for which geometry an atlas holds, and
#' its accessors abort rather than return `NULL` when a component is absent,
#' so presence has to be read off the data slot. This is the only place in
#' `ggseg3d` that inspects atlas structure directly; every read of the
#' geometry itself goes through the ggseg.formats accessors.
#'
#' @inheritParams prepare_brain_meshes
#'
#' @return Named logical vector with `vertices`, `meshes` and `centerlines`
#' @keywords internal
#' @noRd
atlas_3d_components <- function(atlas) {
  data <- atlas$data
  c(
    vertices = !is.null(data$vertices),
    meshes = !is.null(data$meshes),
    centerlines = !is.null(data$centerlines)
  )
}

#' @noRd
has_atlas_meshes <- function(atlas) {
  atlas_3d_components(atlas)[["meshes"]]
}

#' @noRd
has_atlas_centerlines <- function(atlas) {
  atlas_3d_components(atlas)[["centerlines"]]
}


#' Attach the atlas colours a plot should use
#'
#' Overwrites the `colour` column with [ggseg.formats::atlas_plot_palette()],
#' which substitutes distinguishable colours when the atlas palette gives
#' every region the same colour. Reading `atlas$palette` instead renders such
#' atlases as a single indistinguishable silhouette.
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
  base_data <- if (has_atlas_centerlines(atlas)) {
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


#' Merge legend data from surface and deep cerebellar components
#' @noRd
merge_legend_data <- function(surface_legend, deep_legend) {
  if (is.null(surface_legend) && is.null(deep_legend)) {
    return(NULL)
  }
  if (is.null(surface_legend)) {
    return(deep_legend)
  }
  if (is.null(deep_legend)) {
    return(surface_legend)
  }

  combined <- rbind(surface_legend, deep_legend)
  combined[!duplicated(combined$label), , drop = FALSE]
}
