#' Get brain surface mesh
#'
#' Retrieves a brain surface mesh for the specified hemisphere and surface type
#' from the internal brain_meshes data.
#'
#' @param hemisphere "lh" or "rh"
#' @param surface Surface type: "inflated", "semi-inflated", "white", "pial"
#'
#' @return list with vertices (data.frame with x, y, z) and faces
#'   (data.frame with i, j, k), or NULL if mesh not found
#' @export
get_brain_mesh <- function(
  hemisphere = c("lh", "rh"),
  surface = c("inflated", "semi-inflated", "white", "pial")
) {
  hemisphere <- match.arg(hemisphere)
  surface <- match.arg(surface)

  mesh_name <- paste(hemisphere, surface, sep = "_")

  if (!exists("brain_meshes", envir = asNamespace("ggseg3d"))) {
    cli::cli_warn("Internal brain_meshes data not found.")
    return(NULL)
  }

  meshes <- get("brain_meshes", envir = asNamespace("ggseg3d"))

  if (!mesh_name %in% names(meshes)) {
    cli::cli_warn(c(
      "Brain mesh {.val {mesh_name}} not available.",
      "i" = "Available meshes: {.val {names(meshes)}}"
    ))
    return(NULL)
  }

  mesh <- meshes[[mesh_name]]

  if (min(mesh$faces$i) == 0) {
    mesh$faces$i <- mesh$faces$i + 1L
    mesh$faces$j <- mesh$faces$j + 1L
    mesh$faces$k <- mesh$faces$k + 1L
  }

  mesh
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


#' Map atlas vertex indices to region labels
#'
#' Given a brain_atlas with vertices column and a brain mesh, creates a label
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_label Label for vertices not in any region
#'
#' @return Character vector of labels, one per mesh vertex
#' @keywords internal
vertices_to_labels <- function(
  atlas_data,
  n_vertices,
  na_label = NA_character_
) {
  vertex_labels <- rep(na_label, n_vertices)

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_label <- atlas_data$region[i]

    if (length(region_vertices) > 0 && !is.na(region_label)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_labels[idx] <- region_label
    }
  }

  vertex_labels
}


#' Map vertices to group values for edge detection
#'
#' Assigns group values to mesh vertices based on a column in atlas data.
#' Used for computing boundary edges between different groups rather than
#' between different colors.
#'
#' @param atlas_data Data frame with vertices list column and grouping column
#' @param n_vertices Total number of vertices in the mesh
#' @param group_col Name of the column containing group values
#' @param na_group Value for vertices not in any region
#'
#' @return Character vector of group values, one per mesh vertex
#' @noRd
#' @keywords internal
vertices_to_groups <- function(
  atlas_data,
  n_vertices,
  group_col,
  na_group = NA_character_
) {
  vertex_groups <- rep(na_group, n_vertices)

  if (!group_col %in% names(atlas_data)) {
    cli::cli_abort(
      "Column {.val {group_col}} not found in atlas data."
    )
  }

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    region_group <- as.character(atlas_data[[group_col]][i])

    if (length(region_vertices) > 0 && !is.na(region_group)) {
      idx <- region_vertices + 1L
      idx <- idx[idx >= 1 & idx <= n_vertices]
      vertex_groups[idx] <- region_group
    }
  }

  vertex_groups
}


#' Build mesh list for atlases
#'
#' Creates mesh data structures for brain_atlas objects using
#' shared brain meshes with vertex-based colouring.
#'
#' @param atlas_data Prepared atlas data frame
#' @param hemisphere Hemispheres to include
#' @param surface Surface type
#' @param na_colour Colour for NA values
#' @param edge_by Column for edge grouping (or NULL)
#' @param atlas_meshes Optional meshes component from brain_atlas for
#'   subcortical rendering
#' @param atlas_type Type of atlas ("cortical", "subcortical", "tract")
#' @param color_by How to colour tracts: "colour" or "orientation"
#'
#' @return List of mesh data structures
#' @importFrom rlang .data
#' @keywords internal
build_meshes <- function(
  atlas_data,
  hemisphere,
  surface,
  na_colour,
  edge_by,
  atlas_meshes = NULL,
  atlas_type = "cortical",
  color_by = "colour",
  atlas_centerlines = NULL
) {
  meshes <- list()
  hemi_map <- c("right" = "rh", "left" = "lh")

  for (current_hemi in hemisphere) {
    if (current_hemi == "subcort") {
      if (atlas_type == "tract") {
        tract_meshes <- build_tract_meshes(
          atlas_data,
          na_colour,
          color_by,
          atlas_centerlines
        )
        meshes <- c(meshes, tract_meshes)
      } else if (!is.null(atlas_meshes)) {
        subcort_meshes <- build_subcortical_meshes(atlas_data, na_colour)
        meshes <- c(meshes, subcort_meshes)
      }
      next
    }

    hemi_short <- hemi_map[current_hemi]
    mesh <- get_brain_mesh(hemisphere = hemi_short, surface = surface)

    if (is.null(mesh)) {
      cli::cli_warn(
        "Brain mesh not found for {.val {hemi_short}} {.val {surface}}."
      )
      next
    }

    hemi_data <- dplyr::filter(atlas_data, .data$hemi == current_hemi)
    if (nrow(hemi_data) == 0) {
      next
    }

    vertices <- mesh$vertices

    n_vertices <- nrow(vertices)
    vertex_colors <- vertices_to_colors(hemi_data, n_vertices, na_colour)
    vertex_labels <- vertices_to_labels(hemi_data, n_vertices, na_label = "")

    if (!is.null(edge_by)) {
      edge_groups <- vertices_to_groups(hemi_data, n_vertices, edge_by)
      boundary <- find_boundary_edges(mesh$faces, edge_groups)
    } else {
      boundary <- find_boundary_edges(mesh$faces, vertex_colors)
    }

    edge_color <- if (!is.null(edge_by)) "#000000" else NULL

    mesh_entry <- make_mesh_entry(
      name = paste(current_hemi, surface),
      vertices = vertices,
      faces = mesh$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      boundary_edges = boundary,
      edge_color = edge_color,
      vertex_labels = vertex_labels
    )

    meshes[[length(meshes) + 1]] <- mesh_entry
  }

  meshes
}


#' Position hemisphere vertices for anatomical display
#'
#' Offsets hemisphere vertices so left is at negative x and right at positive x,
#' with medial surfaces adjacent at the midline. Used by [add_glassbrain()]
#' for anatomical context.
#'
#' @param vertices data.frame with x, y, z columns
#' @param hemisphere "left" or "right"
#' @return data.frame with adjusted x coordinates
#' @keywords internal
position_hemisphere <- function(vertices, hemisphere) {
  x_range <- range(vertices$x)
  half_width <- (x_range[2] - x_range[1]) / 2

  if (hemisphere == "left") {
    vertices$x <- vertices$x - half_width
  } else if (hemisphere == "right") {
    vertices$x <- vertices$x + half_width
  }

  vertices
}


#' Build mesh list for subcortical atlases
#'
#' Creates mesh data structures for subcortical atlases with per-region mesh
#' data using face-based colouring (each structure is a separate mesh).
#'
#' @param atlas_data Prepared atlas data frame with label, colour, and mesh
#'   columns
#' @param na_colour Colour for NA values
#'
#' @return List of mesh data structures
#' @keywords internal
build_subcortical_meshes <- function(atlas_data, na_colour) {
  meshes <- list()

  for (i in seq_len(nrow(atlas_data))) {
    label <- atlas_data$label[i]
    mesh_data <- atlas_data$mesh[[i]]

    if (is.null(mesh_data)) {
      next
    }

    colour <- atlas_data$colour[i]
    if (is.na(colour)) {
      colour <- na_colour
    }

    colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))
    face_colors <- rep(colour, nrow(mesh_data$faces))

    mesh_entry <- make_mesh_entry(
      name = label,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = face_colors,
      color_mode = "facecolor",
      hover_text = paste0("Region: ", label)
    )

    meshes[[length(meshes) + 1]] <- mesh_entry
  }

  meshes
}


#' Build mesh list for tract atlases
#'
#' Creates mesh data structures for tract atlases with per-vertex colouring.
#' Supports palette colours (uniform per tract) or orientation-based RGB
#' colours computed from centerline tangent vectors.
#'
#' @param atlas_data Prepared atlas data frame with label, colour, and mesh
#'   columns
#' @param na_colour Colour for NA values
#' @param color_by How to colour tracts: "colour" (use colour column),
#'   "orientation" (direction-based RGB from tangents)
#'
#' @return List of mesh data structures
#' @keywords internal
build_tract_meshes <- function(
  atlas_data,
  na_colour,
  color_by = "colour",
  atlas_centerlines = NULL
) {
  meshes <- list()

  has_centerlines <- !is.null(atlas_centerlines) &&
    !is.null(atlas_centerlines$centerlines)
  has_legacy_meshes <- "mesh" %in% names(atlas_data)

  if (!has_centerlines && !has_legacy_meshes) {
    cli::cli_warn("No centerlines or meshes found for tract atlas")
    return(meshes)
  }

  for (i in seq_len(nrow(atlas_data))) {
    label <- atlas_data$label[i]

    if (has_centerlines) {
      cl_idx <- which(atlas_centerlines$centerlines$label == label)
      if (length(cl_idx) == 0) {
        next
      }

      centerline <- atlas_centerlines$centerlines$points[[cl_idx]]
      tangents <- atlas_centerlines$centerlines$tangents[[cl_idx]]

      mesh_data <- generate_tube_mesh(
        centerline = centerline,
        radius = atlas_centerlines$tube_radius,
        segments = atlas_centerlines$tube_segments
      )
      mesh_data$metadata$tangents <- tangents
    } else {
      mesh_data <- atlas_data$mesh[[i]]
      if (is.null(mesh_data)) next
    }

    n_vertices <- nrow(mesh_data$vertices)

    if (color_by == "orientation" && !is.null(mesh_data$metadata$tangents)) {
      vertex_colors <- tangents_to_colors(mesh_data)
    } else {
      colour <- atlas_data$colour[i]
      if (is.na(colour)) {
        colour <- na_colour
      }
      colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))
      vertex_colors <- rep(colour, n_vertices)
    }

    mesh_entry <- make_mesh_entry(
      name = label,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      hover_text = paste0("Tract: ", label)
    )

    meshes[[length(meshes) + 1]] <- mesh_entry
  }

  meshes
}


#' Convert tangent vectors to orientation RGB colours
#'
#' Computes direction-based RGB colours from centerline tangent vectors.
#' Standard tractography colouring: R = left-right (x),
#' G = anterior-posterior (y), B = superior-inferior (z).
#'
#' @param mesh_data Mesh data with vertices data.frame and metadata list
#' @return Character vector of hex colours (one per mesh vertex)
#' @keywords internal
tangents_to_colors <- function(mesh_data) {
  metadata <- mesh_data$metadata
  n_centerline <- metadata$n_centerline_points
  tangents <- metadata$tangents

  n_vertices <- nrow(mesh_data$vertices)
  n_segments <- as.integer(n_vertices / n_centerline)

  abs_tangents <- abs(tangents)
  row_max <- apply(abs_tangents, 1, max)
  row_max[row_max == 0] <- 1
  normalized <- abs_tangents / row_max

  centerline_colors <- grDevices::rgb(
    normalized[, 1],
    normalized[, 2],
    normalized[, 3]
  )

  rep(centerline_colors, each = n_segments)
}


# Tube mesh generation ----

#' Generate tube mesh from centerline
#'
#' Creates a 3D tube mesh around a centerline path using parallel transport
#' frames for smooth geometry without twisting artifacts.
#'
#' @param centerline Matrix with N rows and 3 columns (x, y, z coordinates)
#' @param radius Tube radius. Either a single value or vector of length N.
#' @param segments Number of segments around tube circumference.
#' @return List with vertices (data.frame), faces (data.frame), and metadata
#' @keywords internal
generate_tube_mesh <- function(centerline, radius = 0.5, segments = 8) {
  if (!is.matrix(centerline) || nrow(centerline) < 2) {
    cli::cli_abort("centerline must be a matrix with at least 2 rows")
  }

  n_points <- nrow(centerline)
  frames <- compute_parallel_transport_frames(centerline)

  if (length(radius) == 1) {
    radius <- rep(radius, n_points)
  }

  n_vertices <- n_points * segments
  n_faces <- (n_points - 1) * segments * 2

  vertices <- matrix(0, nrow = n_vertices, ncol = 3)
  faces <- matrix(0L, nrow = n_faces, ncol = 3)

  angles <- seq(0, 2 * pi, length.out = segments + 1)[1:segments]

  for (i in seq_len(n_points)) {
    center <- centerline[i, ]
    normal <- frames$normals[i, ]
    binormal <- frames$binormals[i, ]
    r <- radius[i]

    for (j in seq_len(segments)) {
      angle <- angles[j]
      offset <- r * (cos(angle) * normal + sin(angle) * binormal)
      vertex_idx <- (i - 1) * segments + j
      vertices[vertex_idx, ] <- center + offset
    }
  }

  face_idx <- 1
  for (i in seq_len(n_points - 1)) {
    for (j in seq_len(segments)) {
      j_next <- if (j == segments) 1L else j + 1L

      v1 <- (i - 1L) * segments + j
      v2 <- (i - 1L) * segments + j_next
      v3 <- i * segments + j
      v4 <- i * segments + j_next

      faces[face_idx, ] <- c(v1, v2, v3)
      faces[face_idx + 1L, ] <- c(v2, v4, v3)
      face_idx <- face_idx + 2L
    }
  }

  list(
    vertices = data.frame(
      x = vertices[, 1],
      y = vertices[, 2],
      z = vertices[, 3]
    ),
    faces = data.frame(i = faces[, 1], j = faces[, 2], k = faces[, 3]),
    metadata = list(
      n_centerline_points = n_points,
      centerline = centerline,
      tangents = frames$tangents
    )
  )
}


#' Compute parallel transport frames along curve
#' @keywords internal
compute_parallel_transport_frames <- function(curve) { # nolint: object_length_linter
  n <- nrow(curve)

  tangents <- matrix(0, nrow = n, ncol = 3)
  for (i in seq_len(n - 1)) {
    tangents[i, ] <- curve[i + 1, ] - curve[i, ]
    len <- sqrt(sum(tangents[i, ]^2))
    if (len > 0) tangents[i, ] <- tangents[i, ] / len
  }
  tangents[n, ] <- tangents[n - 1, ]

  t0 <- tangents[1, ]
  arbitrary <- if (abs(t0[1]) < 0.9) c(1, 0, 0) else c(0, 1, 0)
  n0 <- cross_product(t0, arbitrary)
  n0 <- n0 / sqrt(sum(n0^2))

  normals <- matrix(0, nrow = n, ncol = 3)
  binormals <- matrix(0, nrow = n, ncol = 3)

  normals[1, ] <- n0
  binormals[1, ] <- cross_product(t0, n0)

  for (i in seq_len(n - 1)) {
    t_curr <- tangents[i, ]
    t_next <- tangents[i + 1, ]

    cross_t <- cross_product(t_curr, t_next)
    cross_norm <- sqrt(sum(cross_t^2))

    if (cross_norm < 1e-10) {
      normals[i + 1, ] <- normals[i, ]
      binormals[i + 1, ] <- binormals[i, ]
    } else {
      axis <- cross_t / cross_norm
      angle <- acos(max(-1, min(1, sum(t_curr * t_next))))

      normals[i + 1, ] <- rotate_vector(normals[i, ], axis, angle)
      normals[i + 1, ] <- normals[i + 1, ] / sqrt(sum(normals[i + 1, ]^2))
      binormals[i + 1, ] <- cross_product(t_next, normals[i + 1, ])
    }
  }

  list(tangents = tangents, normals = normals, binormals = binormals)
}


#' Cross product of two 3D vectors
#' @keywords internal
cross_product <- function(a, b) {
  c(
    a[2] * b[3] - a[3] * b[2],
    a[3] * b[1] - a[1] * b[3],
    a[1] * b[2] - a[2] * b[1]
  )
}


#' Rotate vector around axis by angle (Rodrigues' formula)
#' @keywords internal
rotate_vector <- function(v, axis, angle) {
  cos_a <- cos(angle)
  sin_a <- sin(angle)
  v *
    cos_a +
    cross_product(axis, v) * sin_a +
    axis * sum(axis * v) * (1 - cos_a)
}
