#' Get brain surface mesh
#'
#' Retrieves a brain surface mesh for the specified hemisphere and surface type.
#' If no mesh is found, returns NULL with a message.
#'
#' @param hemisphere "lh" or "rh"
#' @param surface Surface type: "inflated", "white", "pial"
#' @param subject FreeSurfer subject (default "fsaverage5")
#'
#' @return list with vertices (data.frame with x, y, z) and faces (data.frame with i, j, k),
#'         or NULL if mesh not found
#' @keywords internal
get_brain_mesh <- function(
    hemisphere = c("lh", "rh"),
    surface = c("inflated", "white", "pial"),
    subject = "fsaverage5"
) {
  hemisphere <- match.arg(hemisphere)
  surface <- match.arg(surface)

  mesh_name <- paste(hemisphere, surface, sep = "_")

  if (exists("brain_meshes", envir = asNamespace("ggseg3d"))) {
    meshes <- get("brain_meshes", envir = asNamespace("ggseg3d"))
    if (mesh_name %in% names(meshes)) {
      return(meshes[[mesh_name]])
    }
  }

  if (file.exists(system.file("meshes", paste0(mesh_name, ".rds"), package = "ggseg3d"))) {
    mesh <- readRDS(system.file("meshes", paste0(mesh_name, ".rds"), package = "ggseg3d"))
    return(mesh)
  }

  NULL
}


#' Map atlas vertex indices to mesh colors
#'
#' Given a brain_atlas with vertices column and a brain mesh, creates a color
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region, colour, and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_colour Color for vertices not in any region
#'
#' @return Character vector of colors, one per mesh vertex
#' @keywords internal
vertices_to_colors <- function(
    atlas_data,
    n_vertices,
    na_colour = "#CCCCCC"
) {
  vertex_colors <- rep(na_colour, n_vertices)

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_colour <- atlas_data$colour[i]

    if (length(region_vertices) > 0 && !is.na(region_colour)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_colors[idx] <- region_colour
    }
  }

  vertex_colors
}


#' Check if atlas is a unified brain_atlas
#'
#' Checks whether an atlas object is a brain_atlas with the unified format
#' (containing vertices column instead of mesh column).
#'
#' @param atlas An atlas object
#'
#' @return Logical indicating if this is a unified brain_atlas
#' @keywords internal
is_unified_atlas <- function(atlas) {
  if (!inherits(atlas, "brain_atlas")) {
    return(FALSE)
  }

  if (is.null(atlas$data)) {
    return(FALSE)

  }

  "vertices" %in% names(atlas$data)
}


#' Render brain_atlas with vertex coloring
#'
#' Internal function that renders a unified brain_atlas using vertex-based
#' coloring on shared brain meshes. Returns mesh data suitable for the
#' ggseg3d htmlwidget.
#'
#' @param atlas A brain_atlas object with vertices column
#' @param surface Surface type to render
#' @param hemisphere Hemisphere(s) to render
#' @param colour Column name for colors
#' @param label Column name for labels
#' @param text Additional text column
#' @param na.colour Color for NA regions
#' @param na.alpha Opacity for NA regions
#'
#' @return A list of mesh data for the widget
#' @keywords internal
render_unified_atlas <- function(
    atlas,
    surface = "inflated",
    hemisphere = c("right", "left"),
    colour = "colour",
    label = "region",
    text = NULL,
    na.colour = "darkgrey",
    na.alpha = 1
) {
  meshes <- list()
  hemi_map <- c("right" = "rh", "left" = "lh")

  for (hemi in hemisphere) {
    if (hemi == "subcort") next

    hemi_short <- hemi_map[hemi]
    mesh <- get_brain_mesh(hemisphere = hemi_short, surface = surface)

    if (is.null(mesh)) {
      cli::cli_warn("Brain mesh not found for {.val {hemi_short}} {.val {surface}}. Skipping hemisphere.")
      next
    }

    atlas_data <- atlas$data[atlas$data$hemi == hemi, ]

    if (nrow(atlas_data) == 0) next

    n_vertices <- nrow(mesh$vertices)
    vertex_colors <- vertices_to_colors(atlas_data, n_vertices, na.colour)

    meshes[[length(meshes) + 1]] <- list(
      name = paste(hemi, surface),
      vertices = list(
        x = unname(as.numeric(mesh$vertices$x)),
        y = unname(as.numeric(mesh$vertices$y)),
        z = unname(as.numeric(mesh$vertices$z))
      ),
      faces = list(
        i = unname(as.integer(mesh$faces$i - 1)),
        j = unname(as.integer(mesh$faces$j - 1)),
        k = unname(as.integer(mesh$faces$k - 1))
      ),
      colors = unname(vertex_colors),
      colorMode = "vertexcolor",
      opacity = 1,
      hoverText = NULL
    )
  }

  meshes
}
