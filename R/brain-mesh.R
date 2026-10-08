#' Resolve brain surface mesh
#'
#' Resolves and prepares a brain surface mesh for rendering. Delegates to
#' [ggseg.formats::get_brain_mesh()] for inflated surfaces and to
#' [ggseg.meshes::get_cortical_mesh()] for pial, white, semi-inflated, and
#' other surfaces. Returned meshes use the shared anatomical axis convention
#' (`x` = left-right, `y` = anterior-posterior, `z` = superior-inferior) with
#' `lh` positioned at `x <= 0` and `rh` at `x >= 0`, medial edges meeting at
#' the midline (`x = 0`).
#'
#' @param hemisphere `"lh"` or `"rh"`
#' @param surface Surface type: `"inflated"`, `"semi-inflated"`, `"white"`,
#'   `"pial"`, `"sphere"`, `"smoothwm"`, `"orig"`
#' @param brain_meshes Optional user-supplied mesh data. Passed through to
#'   [ggseg.formats::get_brain_mesh()] for format details.
#'
#' @return list with vertices (data.frame with x, y, z) and faces
#'   (data.frame with i, j, k), or NULL if mesh not found
#'
#' @examples
#' mesh <- resolve_brain_mesh("lh", "inflated")
#' str(mesh, max.level = 1)
#'
#' @export
resolve_brain_mesh <- function(
  hemisphere = c("lh", "rh"),
  surface = c(
    "inflated",
    "semi-inflated",
    "white",
    "pial",
    "sphere",
    "smoothwm",
    "orig"
  ),
  brain_meshes = NULL
) {
  hemisphere <- match.arg(hemisphere)
  surface <- match.arg(surface)

  from_ggseg_meshes <- is.null(brain_meshes) && surface != "inflated"

  if (from_ggseg_meshes) {
    check_ggseg_meshes(surface)
    mesh <- ggseg.meshes::get_cortical_mesh(hemisphere, surface)
  } else {
    mesh <- ggseg.formats::get_brain_mesh(hemisphere, surface, brain_meshes)
  }

  if (is.null(mesh)) {
    return(NULL)
  }

  mesh <- as_one_based_mesh(mesh)

  normalize_cortical_mesh(mesh, hemisphere, from_ggseg_meshes)
}


#' Face index base of a mesh
#'
#' `ggseg.meshes` publishes the base its face indices are counted from as a
#' `face_index_base` attribute on the mesh, and reading it matters because the
#' ecosystem genuinely mixes bases: `ggseg.formats` inflated surfaces are
#' 0-based, `ggseg.meshes` cortical surfaces are 1-based, and `ggseg.meshes`
#' cerebellar surfaces are 0-based.
#'
#' The attribute is a contract internal to the core packages. Meshes from
#' `ggseg.formats` and from third-party atlas packages may legitimately carry
#' no attribute at all, so its absence is normal input rather than an error
#' and the base is inferred from the indices instead.
#'
#' @param mesh List with `vertices` and `faces`
#'
#' @return `0L` or `1L`
#' @keywords internal
#' @noRd
face_index_base <- function(mesh) {
  base <- attr(mesh, "face_index_base")

  if (!is.null(base)) {
    base <- as.integer(base)
    if (!base %in% c(0L, 1L)) {
      cli::cli_abort(
        "Mesh {.field face_index_base} must be 0 or 1, not {.val {base}}."
      )
    }
    return(base)
  }

  infer_face_index_base(mesh)
}


# Fallback for meshes that publish no base. An index of 0 can only be
# 0-based, and an index equal to the vertex count can only be 1-based; when
# neither is decisive, a span that ends one short of the vertex count is
# 0-based. Anything still ambiguous (a mesh whose highest vertices are unused)
# is read as 1-based, which is what ggseg3d works in.
infer_face_index_base <- function(mesh) {
  indices <- c(mesh$faces$i, mesh$faces$j, mesh$faces$k)
  n_vertices <- nrow(mesh$vertices)

  if (min(indices) == 0L) {
    return(0L)
  }
  if (max(indices) == n_vertices) {
    return(1L)
  }
  if (max(indices) == n_vertices - 1L) {
    return(0L)
  }

  1L
}


#' Convert a mesh to 1-based face indices
#'
#' ggseg3d works in 1-based face indices internally and subtracts one when
#' serialising for the renderer in `make_mesh_entry()`.
#'
#' @param mesh List with `vertices` and `faces`
#'
#' @return `mesh` with 1-based faces and `face_index_base` set to `1L`
#' @keywords internal
#' @noRd
as_one_based_mesh <- function(mesh) {
  if (face_index_base(mesh) == 0L) {
    mesh$faces$i <- mesh$faces$i + 1L
    mesh$faces$j <- mesh$faces$j + 1L
    mesh$faces$k <- mesh$faces$k + 1L
  }

  attr(mesh, "face_index_base") <- 1L
  mesh
}


check_ggseg_meshes <- function(surface) {
  if (!requireNamespace("ggseg.meshes", quietly = TRUE)) {
    cli::cli_abort(c(
      "{.pkg ggseg.meshes} is required for {.val {surface}}.",
      "i" = "Install with: {.run install.packages('ggseg.meshes')}"
    ))
  }
}


# ggseg.meshes surfaces are stored rotated 90 deg CCW relative to FreeSurfer
# native axes (see ggseg.meshes/data-raw/make_cortical_meshes.R): stored
# `x` = AP, stored `y` = -LR, stored `z` = SI. ggseg.formats inflated and
# subcortical/cerebellar meshes already use native axes (x = LR, y = AP,
# z = SI). After axis alignment we shift each hemisphere so medial edges sit
# at x = 0 — LH occupies x <= 0, RH occupies x >= 0 — so both hemispheres
# display side-by-side without overlap regardless of surface choice.
normalize_cortical_mesh <- function(mesh, hemisphere, rotate_axes) {
  if (rotate_axes) {
    v <- mesh$vertices
    mesh$vertices$x <- -v$y
    mesh$vertices$y <- v$x
  }

  mesh$vertices$x <- if (hemisphere == "lh") {
    mesh$vertices$x - max(mesh$vertices$x)
  } else {
    mesh$vertices$x - min(mesh$vertices$x)
  }

  mesh
}


#' Scatter one value per atlas row onto the mesh vertices it covers
#'
#' Shared core of the `vertices_to_*()` helpers: every vertex of row `i`'s
#' region takes `values[i]`, and vertices no region claims keep `fill`. Atlas
#' vertex indices are 0-based; mesh vectors are 1-based.
#'
#' @param atlas_data Data frame with a `vertices` list column
#' @param n_vertices Number of vertices in the mesh
#' @param values Vector of one value per row of `atlas_data`
#' @param fill Value for vertices not in any region
#'
#' @return Vector of length `n_vertices`
#' @keywords internal
#' @noRd
map_vertex_values <- function(atlas_data, n_vertices, values, fill) {
  mapped <- rep(fill, n_vertices)

  for (i in seq_len(nrow(atlas_data))) {
    region_vertices <- atlas_data$vertices[[i]]
    value <- values[[i]]

    if (length(region_vertices) > 0 && !is.na(value)) {
      idx <- region_vertices + 1L
      mapped[idx[idx >= 1 & idx <= n_vertices]] <- value
    }
  }

  mapped
}


#' Map atlas vertex indices to mesh colors
#'
#' Given a ggseg_atlas with vertices column and a brain mesh, creates a color
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region, colour, and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_colour Color for vertices not in any region
#'
#' @return Character vector of colors, one per mesh vertex
#' @keywords internal
#' @noRd
vertices_to_colors <- function(
  atlas_data,
  n_vertices,
  na_colour = "#CCCCCC"
) {
  map_vertex_values(atlas_data, n_vertices, atlas_data$colour, na_colour)
}


#' Map atlas vertex indices to region labels
#'
#' Given a ggseg_atlas with vertices column and a brain mesh, creates a label
#' vector for each mesh vertex based on which region it belongs to.
#'
#' @param atlas_data Data frame with region and vertices columns
#' @param n_vertices Number of vertices in the mesh
#' @param na_label Label for vertices not in any region
#'
#' @return Character vector of labels, one per mesh vertex
#' @keywords internal
#' @noRd
vertices_to_labels <- function(
  atlas_data,
  n_vertices,
  na_label = NA_character_
) {
  map_vertex_values(atlas_data, n_vertices, atlas_data$region, na_label)
}


#' Map vertices to text values for hover display
#'
#' Assigns text values to mesh vertices based on a column in atlas data.
#' Used for per-vertex hover text in the Three.js tooltip.
#'
#' @param atlas_data Data frame with vertices list column
#' @param n_vertices Number of vertices in the mesh
#' @param text_col Name of the column containing text values
#'
#' @return Character vector of text values, one per mesh vertex
#' @keywords internal
#' @noRd
vertices_to_text <- function(atlas_data, n_vertices, text_col) {
  if (!text_col %in% names(atlas_data)) {
    return(rep(NA_character_, n_vertices))
  }

  values <- as.character(atlas_data[[text_col]])
  values <- ifelse(
    is.na(values),
    NA_character_,
    paste0(text_col, ": ", values)
  )

  map_vertex_values(atlas_data, n_vertices, values, NA_character_)
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
  if (!group_col %in% names(atlas_data)) {
    cli::cli_abort(
      "Column {.val {group_col}} not found in atlas data."
    )
  }

  map_vertex_values(
    atlas_data,
    n_vertices,
    as.character(atlas_data[[group_col]]),
    na_group
  )
}


#' Map vertices to per-vertex alpha
#'
#' Cortical and cerebellar atlases emit one mesh per hemisphere, so fading
#' regions without data cannot be done with a mesh-level opacity the way
#' per-region subcortical meshes can. Rows carry their alpha in the `alpha`
#' column written by `apply_colour_palette()`; vertices no region claims are
#' not data either, so they fade with `na_alpha` too.
#'
#' @param atlas_data Data frame with a `vertices` list column, optionally
#'   with an `alpha` column
#' @param n_vertices Number of vertices in the mesh
#' @param na_alpha Alpha for vertices not in any region
#'
#' @return Numeric vector of alphas, one per mesh vertex
#' @keywords internal
#' @noRd
vertices_to_alphas <- function(atlas_data, n_vertices, na_alpha = 1) {
  alphas <- if ("alpha" %in% names(atlas_data)) {
    atlas_data$alpha
  } else {
    rep(1, nrow(atlas_data))
  }

  map_vertex_values(atlas_data, n_vertices, alphas, na_alpha)
}


#' Build mesh list for cortical atlases
#'
#' Creates mesh data structures for cortical ggseg_atlas objects using
#' shared brain meshes with vertex-based colouring.
#'
#' @param hemisphere Hemispheres to include
#' @param surface Surface type
#' @param edge_by Column for edge grouping (or NULL)
#'
#' @return List of mesh data structures
#' @importFrom rlang .data
#' @inheritParams apply_colours_and_legend
#' @inheritParams resolve_brain_mesh
#' @keywords internal
#' @noRd
build_cortical_meshes <- function(
  atlas_data,
  hemisphere,
  surface,
  na_colour,
  edge_by,
  brain_meshes = NULL,
  text_by = NULL,
  label_by = "region",
  na_alpha = 1
) {
  hemi_map <- c("right" = "rh", "left" = "lh")

  meshes <- lapply(hemisphere, function(current_hemi) {
    hemi_short <- hemi_map[current_hemi]
    mesh <- resolve_brain_mesh(
      hemisphere = hemi_short,
      surface = surface,
      brain_meshes = brain_meshes
    )

    if (is.null(mesh)) {
      cli::cli_warn(
        "Brain mesh not found for {.val {hemi_short}} {.val {surface}}."
      )
      return(NULL)
    }

    hemi_data <- dplyr::filter(atlas_data, .data$hemi == current_hemi)
    if (nrow(hemi_data) == 0) {
      return(NULL)
    }

    n_vertices <- nrow(mesh$vertices)
    vertex_colors <- vertices_to_colors(hemi_data, n_vertices, na_colour)
    vertex_labels <- vertices_to_labels(hemi_data, n_vertices, na_label = "")
    vertex_alphas <- vertices_to_alphas(hemi_data, n_vertices, na_alpha)

    vertex_texts <- if (!is.null(text_by)) {
      vertices_to_text(hemi_data, n_vertices, text_by)
    }

    if (!is.null(edge_by)) {
      edge_groups <- vertices_to_groups(hemi_data, n_vertices, edge_by)
      boundary <- find_boundary_edges(mesh$faces, edge_groups)
    } else {
      boundary <- find_boundary_edges(mesh$faces, vertex_colors)
    }

    edge_color <- if (!is.null(edge_by)) "#000000" else NULL

    make_mesh_entry(
      name = paste(current_hemi, surface),
      vertices = mesh$vertices,
      faces = mesh$faces,
      colors = vertex_colors,
      color_mode = "vertexcolor",
      boundary_edges = boundary,
      edge_color = edge_color,
      vertex_labels = vertex_labels,
      vertex_texts = vertex_texts,
      vertex_alphas = vertex_alphas
    )
  })

  Filter(Negate(is.null), meshes)
}


#' Build mesh list for cerebellar atlases
#'
#' Creates mesh data structures for cerebellar ggseg_atlas objects using
#' the shared SUIT cerebellar surface with vertex-based colouring.
#'
#' @param text_by Column for hover text (or NULL)
#' @param label_by Column for vertex labels
#' @param opacity Numeric opacity for the mesh (0 = transparent, 1 = opaque)
#'
#' @return List of mesh data structures
#' @inheritParams apply_colours_and_legend
#' @keywords internal
#' @noRd
build_cerebellar_meshes <- function(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region",
  opacity = 1,
  na_alpha = 1
) {
  mesh <- ggseg.formats::get_cerebellar_mesh()

  if (is.null(mesh)) {
    cli::cli_abort("SUIT cerebellar mesh not available.")
  }

  mesh <- as_one_based_mesh(mesh)

  n_vertices <- nrow(mesh$vertices)
  vertex_colors <- vertices_to_colors(atlas_data, n_vertices, na_colour)
  vertex_labels <- vertices_to_labels(
    atlas_data,
    n_vertices,
    na_label = ""
  )
  vertex_alphas <- vertices_to_alphas(atlas_data, n_vertices, na_alpha)

  vertex_texts <- if (!is.null(text_by)) {
    vertices_to_text(atlas_data, n_vertices, text_by)
  }

  boundary <- find_boundary_edges(mesh$faces, vertex_colors)

  entry <- make_mesh_entry(
    name = "cerebellum",
    vertices = mesh$vertices,
    faces = mesh$faces,
    colors = vertex_colors,
    color_mode = "vertexcolor",
    opacity = opacity,
    boundary_edges = boundary,
    vertex_labels = vertex_labels,
    vertex_texts = vertex_texts,
    vertex_alphas = vertex_alphas
  )

  if (is_flat_mesh(mesh$vertices)) {
    entry$isFlatmap <- TRUE
  }

  list(entry)
}


# A flatmap mesh has all vertices in a single plane (negligible extent on one
# axis). Used to detect cerebellar flatmaps that cannot be combined with
# other 3D meshes.
is_flat_mesh <- function(vertices, tol = 1) {
  any(
    c(
      diff(range(vertices$x)),
      diff(range(vertices$y)),
      diff(range(vertices$z))
    ) <
      tol
  )
}


# Per-region meshes carry their own opacity, so a region without data fades
# through the mesh-level opacity the renderer already honours. The `alpha`
# column comes from `apply_colour_palette()`; builders called directly with
# hand-built data may not have it.
row_alpha <- function(atlas_data, i) {
  if (!"alpha" %in% names(atlas_data)) {
    return(1)
  }

  alpha <- atlas_data$alpha[i]
  if (is.na(alpha)) 1 else alpha
}


#' Build mesh list for subcortical atlases
#'
#' Creates mesh data structures for subcortical atlases with per-region mesh
#' data using face-based colouring (each structure is a separate mesh).
#'
#'
#' @return List of mesh data structures
#' @inheritParams apply_colours_and_legend
#' @keywords internal
#' @noRd
build_subcortical_meshes <- function(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region"
) {
  meshes <- lapply(seq_len(nrow(atlas_data)), function(i) {
    mesh_data <- atlas_data$mesh[[i]]
    if (is.null(mesh_data)) {
      return(NULL)
    }

    colour <- atlas_data$colour[i]
    if (is.na(colour)) {
      colour <- na_colour
    }
    colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))

    region_name <- if (label_by %in% names(atlas_data)) {
      atlas_data[[label_by]][i]
    } else {
      atlas_data$label[i]
    }

    hover <- NULL
    if (!is.null(text_by) && text_by %in% names(atlas_data)) {
      val <- atlas_data[[text_by]][i]
      if (!is.na(val)) hover <- paste0(text_by, ": ", val)
    }

    make_mesh_entry(
      name = region_name,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = rep(colour, nrow(mesh_data$faces)),
      color_mode = "facecolor",
      opacity = row_alpha(atlas_data, i),
      hover_text = hover
    )
  })

  Filter(Negate(is.null), meshes)
}


#' Build mesh list for tract atlases
#'
#' Creates mesh data structures for tract atlases with per-vertex colouring.
#' Supports palette colours (uniform per tract) or orientation-based RGB
#' colours computed from centerline tangent vectors.
#'
#' @param color_by How to colour tracts: "colour" (use colour column),
#'   "orientation" (direction-based RGB from tangents)
#'
#' @return List of mesh data structures
#' @inheritParams apply_colours_and_legend
#' @keywords internal
#' @noRd
build_tract_meshes <- function(
  atlas_data,
  na_colour,
  color_by = "colour",
  atlas_centerlines = NULL,
  text_by = NULL,
  label_by = "region"
) {
  has_centerlines <- !is.null(atlas_centerlines) &&
    !is.null(atlas_centerlines$centerlines)
  has_legacy_meshes <- "mesh" %in% names(atlas_data)

  if (!has_centerlines && !has_legacy_meshes) {
    cli::cli_warn("No centerlines or meshes found for tract atlas")
    return(list())
  }

  meshes <- lapply(seq_len(nrow(atlas_data)), function(i) {
    mesh_data <- if (has_centerlines) {
      tract_tube_mesh(atlas_data$label[i], atlas_centerlines)
    } else {
      atlas_data$mesh[[i]]
    }

    if (is.null(mesh_data)) {
      return(NULL)
    }

    tract_name <- if (label_by %in% names(atlas_data)) {
      atlas_data[[label_by]][i]
    } else {
      atlas_data$label[i]
    }

    make_mesh_entry(
      name = tract_name,
      vertices = mesh_data$vertices,
      faces = mesh_data$faces,
      colors = tract_vertex_colours(
        mesh_data,
        atlas_data$colour[i],
        color_by,
        na_colour
      ),
      color_mode = "vertexcolor",
      opacity = row_alpha(atlas_data, i),
      hover_text = mesh_hover_text(atlas_data, i, text_by)
    )
  })

  Filter(Negate(is.null), meshes)
}


# Builds one tract's tube mesh from its centerline, carrying the tangents
# through so orientation colouring can use them. NULL when the tract has no
# centerline.
tract_tube_mesh <- function(label, atlas_centerlines) {
  cl_idx <- which(atlas_centerlines$centerlines$label == label)
  if (length(cl_idx) == 0) {
    return(NULL)
  }

  mesh_data <- generate_tube_mesh(
    centerline = atlas_centerlines$centerlines$points[[cl_idx]],
    radius = atlas_centerlines$tube_radius,
    segments = atlas_centerlines$tube_segments
  )
  mesh_data$metadata$tangents <- atlas_centerlines$centerlines$tangents[[
    cl_idx
  ]]

  mesh_data
}


tract_vertex_colours <- function(mesh_data, colour, color_by, na_colour) {
  if (color_by == "orientation" && !is.null(mesh_data$metadata$tangents)) {
    return(tangents_to_colors(mesh_data))
  }

  if (is.na(colour)) {
    colour <- na_colour
  }
  colour <- unname(ifelse(grepl("^#", colour), colour, col2hex(colour)))

  rep(colour, nrow(mesh_data$vertices))
}


mesh_hover_text <- function(atlas_data, i, text_by) {
  if (is.null(text_by) || !text_by %in% names(atlas_data)) {
    return(NULL)
  }

  val <- atlas_data[[text_by]][i]
  if (is.na(val)) {
    return(NULL)
  }

  paste0(text_by, ": ", val)
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
#' @noRd
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
#' @noRd
generate_tube_mesh <- function(centerline, radius = 0.5, segments = 8) {
  if (!is.matrix(centerline) || nrow(centerline) < 2) {
    cli::cli_abort("centerline must be a matrix with at least 2 rows")
  }

  n_points <- nrow(centerline)
  frames <- compute_parallel_transp_fr(centerline)

  if (length(radius) == 1) {
    radius <- rep(radius, n_points)
  }

  vertices <- tube_ring_vertices(centerline, frames, radius, segments)
  faces <- tube_quad_faces(n_points, segments)

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


# One ring of `segments` vertices around each centerline point, swept in the
# normal/binormal plane of that point's frame.
tube_ring_vertices <- function(centerline, frames, radius, segments) {
  n_points <- nrow(centerline)
  vertices <- matrix(0, nrow = n_points * segments, ncol = 3)
  angles <- seq(0, 2 * pi, length.out = segments + 1)[1:segments]

  for (i in seq_len(n_points)) {
    normal <- frames$normals[i, ]
    binormal <- frames$binormals[i, ]

    for (j in seq_len(segments)) {
      offset <- radius[i] *
        (cos(angles[j]) * normal + sin(angles[j]) * binormal)
      vertices[(i - 1) * segments + j, ] <- centerline[i, ] + offset
    }
  }

  vertices
}


# Two triangles per quad between consecutive rings, wrapping the last segment
# back to the first.
tube_quad_faces <- function(n_points, segments) {
  faces <- matrix(0L, nrow = (n_points - 1) * segments * 2, ncol = 3)
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

  faces
}


#' Compute parallel transport frames along curve
#' @keywords internal
#' @noRd
compute_parallel_transp_fr <- function(curve) {
  # nolint: object_length_linter
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
#' @noRd
cross_product <- function(a, b) {
  c(
    a[2] * b[3] - a[3] * b[2],
    a[3] * b[1] - a[1] * b[3],
    a[1] * b[2] - a[2] * b[1]
  )
}


#' Rotate vector around axis by angle (Rodrigues' formula)
#' @keywords internal
#' @noRd
rotate_vector <- function(v, axis, angle) {
  cos_a <- cos(angle)
  sin_a <- sin(angle)
  v *
    cos_a +
    cross_product(axis, v) * sin_a +
    axis * sum(axis * v) * (1 - cos_a)
}
