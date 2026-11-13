#' Split the faces that straddle a region boundary
#'
#' A parcellation assigns a region to each *vertex*, but colour is drawn across
#' *faces*, so a face whose three vertices belong to different regions has to
#' pick one. Snapping it to whichever region wins is what makes a parcel border
#' climb the triangulation in steps -- the sawtooth you see on an fsaverage5
#' surface, where one triangle spans a visible fraction of a gyrus.
#'
#' This cuts those faces along the midpoints of the edges that cross a
#' boundary, exactly as the 2D cortical pipeline in ggseg.extra does, so the
#' border follows the midpoint line rather than the mesh. Every face that comes
#' out has three vertices of one region, which is what lets the renderer keep
#' colouring per vertex: with all three the same, the interpolation it does
#' across a face is flat, and the geometry stays indexed and smooth-shaded.
#'
#' A midpoint sits on the border, so it belongs to both sides and is emitted
#' once per region. That duplication is the point: it is what gives the two
#' sides different colours at the same place. Midpoints are keyed on edge and
#' region so the faces either side of a border share them.
#'
#' @param vertices data.frame of `x`, `y`, `z`, one row per vertex.
#' @param faces data.frame of `i`, `j`, `k`, 1-based vertex indices.
#' @param labels Character vector of region labels, one per vertex. `NA` is a
#'   region like any other here -- unlabelled ground borders labelled ground,
#'   and that border wants cutting too.
#' @return A list of `vertices`, `faces` and `labels` for the split mesh, plus
#'   `source`: for every vertex of the split mesh, the index of the original
#'   vertex whose region it carries. Subsetting any per-vertex vector by
#'   `source` carries colours, alphas and hover text onto the new vertices
#'   without recomputing them.
#' @keywords internal
#' @noRd
split_boundary_faces <- function(vertices, faces, labels) {
  n_v <- nrow(vertices)
  key <- ifelse(is.na(labels), "\r<NA>", labels)

  tri <- cbind(faces$i, faces$j, faces$k)
  labs <- cbind(key[tri[, 1]], key[tri[, 2]], key[tri[, 3]])

  same_ab <- labs[, 1] == labs[, 2]
  same_bc <- labs[, 2] == labs[, 3]
  same_ac <- labs[, 1] == labs[, 3]

  interior <- same_ab & same_bc
  three <- !same_ab & !same_bc & !same_ac
  two <- !interior & !three

  corner <- function(rows, pos) tri[cbind(rows, pos)]

  # In a two-region face one vertex stands alone; it is the one the pair that
  # agrees does not contain, so the matching pair names it.
  t2 <- which(two)
  odd_pos <- rep(NA_integer_, length(t2))
  odd_pos[same_ab[t2]] <- 3L
  odd_pos[same_ac[t2]] <- 2L
  odd_pos[same_bc[t2]] <- 1L
  po <- corner(t2, odd_pos)
  pm1 <- corner(t2, odd_pos %% 3L + 1L)
  pm2 <- corner(t2, (odd_pos + 1L) %% 3L + 1L)
  lab_odd <- key[po]
  lab_maj <- key[pm1]

  t3 <- which(three)
  sides <- lapply(1:3, function(pos) {
    list(
      v = corner(t3, rep(pos, length(t3))),
      e1 = corner(t3, rep(pos %% 3L + 1L, length(t3))),
      e2 = corner(t3, rep((pos + 1L) %% 3L + 1L, length(t3)))
    )
  })

  req_a <- c(
    po,
    po,
    po,
    po,
    unlist(lapply(sides, function(s) c(s$v, s$v)))
  )
  req_b <- c(
    pm1,
    pm2,
    pm1,
    pm2,
    unlist(lapply(sides, function(s) c(s$e1, s$e2)))
  )
  req_lab <- c(
    lab_odd,
    lab_odd,
    lab_maj,
    lab_maj,
    unlist(lapply(sides, function(s) rep(key[s$v], 2)))
  )

  edge_key <- paste(pmin(req_a, req_b), pmax(req_a, req_b), req_lab, sep = "|")
  unique_key <- unique(edge_key)
  first <- match(unique_key, edge_key)
  mid_a <- req_a[first]
  mid_b <- req_b[first]
  mid_lab <- req_lab[first]
  mid_index <- n_v + match(edge_key, unique_key)

  # One centroid per region meeting in a three-region face: three distinct
  # points at the same place, one for each side to own.
  ctr_v <- unlist(lapply(sides, function(s) s$v))
  ctr_face <- rep(t3, 3)
  n_mid <- length(unique_key)
  ctr_index <- n_v + n_mid + seq_along(ctr_v)

  mean_of <- function(axis) {
    rowMeans(matrix(axis[tri[ctr_face, 1:3]], ncol = 3))
  }
  midpoint_of <- function(axis) (axis[mid_a] + axis[mid_b]) / 2

  new_vertices <- data.frame(
    x = c(vertices$x, midpoint_of(vertices$x), mean_of(vertices$x)),
    y = c(vertices$y, midpoint_of(vertices$y), mean_of(vertices$y)),
    z = c(vertices$z, midpoint_of(vertices$z), mean_of(vertices$z))
  )
  new_labels <- c(key, mid_lab, key[ctr_v])
  new_source <- c(
    seq_len(n_v),
    ifelse(key[mid_a] == mid_lab, mid_a, mid_b),
    ctr_v
  )

  n2 <- length(t2)
  n3 <- length(t3)
  m1_o <- mid_index[seq_len(n2)]
  m2_o <- mid_index[n2 + seq_len(n2)]
  m1_m <- mid_index[2 * n2 + seq_len(n2)]
  m2_m <- mid_index[3 * n2 + seq_len(n2)]
  side_mid <- lapply(1:3, function(pos) {
    offset <- 4 * n2 + (pos - 1) * 2 * n3
    list(
      first = mid_index[offset + seq_len(n3)],
      second = mid_index[offset + n3 + seq_len(n3)],
      ctr = ctr_index[(pos - 1) * n3 + seq_len(n3)]
    )
  })

  new_faces <- data.frame(
    i = c(
      tri[interior, 1],
      po,
      pm1,
      pm1,
      unlist(lapply(sides, function(s) c(s$v, s$v)))
    ),
    j = c(
      tri[interior, 2],
      m1_o,
      pm2,
      m2_m,
      unlist(lapply(side_mid, function(s) c(s$first, s$ctr)))
    ),
    k = c(
      tri[interior, 3],
      m2_o,
      m2_m,
      m1_m,
      unlist(lapply(side_mid, function(s) c(s$ctr, s$second)))
    )
  )

  list(
    vertices = new_vertices,
    faces = new_faces,
    labels = ifelse(new_labels == "\r<NA>", NA_character_, new_labels),
    source = new_source,
    n_original_vertices = n_v
  )
}

#' Carry a mesh and its per-vertex vectors through a boundary split
#'
#' @param mesh List with `vertices` and `faces`; other elements are kept.
#' @param groups Per-vertex vector the split cuts along. Colour is the right
#'   one to pass: it is what a seam is visible in, so two regions a user has
#'   given the same value cost no extra geometry.
#' @param vectors Named list of per-vertex vectors to carry onto the new
#'   vertices. `NULL` elements stay `NULL`.
#' @return A list of the split `mesh` and the re-indexed `vectors`.
#' @keywords internal
#' @noRd
split_mesh_boundaries <- function(mesh, groups, vectors) {
  split <- split_boundary_faces(mesh$vertices, mesh$faces, groups)
  mesh$vertices <- split$vertices
  mesh$faces <- split$faces
  list(
    mesh = mesh,
    vectors = lapply(vectors, function(v) v[split$source])
  )
}
