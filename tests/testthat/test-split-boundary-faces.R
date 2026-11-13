tri_mesh <- function(labels) {
  list(
    vertices = data.frame(
      x = c(0, 1, 0),
      y = c(0, 0, 1),
      z = c(0, 0, 0)
    ),
    faces = data.frame(i = 1L, j = 2L, k = 3L),
    labels = labels
  )
}

face_groups <- function(split) {
  apply(
    cbind(
      split$labels[split$faces$i],
      split$labels[split$faces$j],
      split$labels[split$faces$k]
    ),
    1,
    function(x) length(unique(x))
  )
}

describe("split_boundary_faces()", {
  it("leaves a face whose vertices share a region alone", {
    m <- tri_mesh(c("a", "a", "a"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_identical(nrow(s$faces), 1L)
    expect_identical(nrow(s$vertices), 3L)
    expect_identical(s$faces, m$faces)
  })

  it("cuts a two-region face into three single-region faces", {
    m <- tri_mesh(c("a", "b", "b"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_identical(nrow(s$faces), 3L)
    expect_identical(nrow(s$vertices), 7L)
    expect_true(all(face_groups(s) == 1L))
  })

  it("cuts a three-region face into six single-region faces", {
    m <- tri_mesh(c("a", "b", "c"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_identical(nrow(s$faces), 6L)
    expect_identical(nrow(s$vertices), 12L)
    expect_true(all(face_groups(s) == 1L))
  })

  it("puts the new border vertices on the edge midpoints", {
    m <- tri_mesh(c("a", "b", "b"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    added <- s$vertices[-seq_len(s$n_original_vertices), ]
    midpoints <- unique(data.frame(x = c(0.5, 0), y = c(0, 0.5), z = c(0, 0)))
    expect_setequal(paste(added$x, added$y), paste(midpoints$x, midpoints$y))
  })

  it("emits each midpoint once per region so the two sides differ", {
    m <- tri_mesh(c("a", "b", "b"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    added <- s$vertices[-seq_len(s$n_original_vertices), ]
    coords <- paste(added$x, added$y, added$z)
    expect_identical(length(unique(coords)), 2L)
    expect_identical(nrow(added), 4L)
  })

  it("treats NA as a region of its own, and keeps it NA", {
    m <- tri_mesh(c(NA, "b", "b"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_true(all(face_groups(s) == 1L))
    expect_true(anyNA(s$labels))
    expect_false(any(s$labels == "\r<NA>", na.rm = TRUE))
  })

  it("keeps every original vertex, unmoved and first", {
    m <- tri_mesh(c("a", "b", "c"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_identical(
      s$vertices[seq_len(s$n_original_vertices), ],
      m$vertices
    )
  })

  it("sources every vertex from an original vertex of the same region", {
    m <- tri_mesh(c("a", "b", "c"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_true(all(s$source <= s$n_original_vertices))
    expect_identical(m$labels[s$source], s$labels)
  })

  it("indexes only vertices it emitted", {
    m <- tri_mesh(c("a", "b", "c"))
    s <- split_boundary_faces(m$vertices, m$faces, m$labels)
    expect_true(all(unlist(s$faces) %in% seq_len(nrow(s$vertices))))
  })
})

describe("split_mesh_boundaries()", {
  m <- tri_mesh(c("a", "b", "b"))
  mesh <- list(vertices = m$vertices, faces = m$faces, extra = "kept")

  it("carries per-vertex vectors onto the new vertices", {
    res <- split_mesh_boundaries(
      mesh,
      m$labels,
      list(colour = c("red", "blue", "blue"))
    )
    expect_length(res$vectors$colour, nrow(res$mesh$vertices))
    expect_identical(
      unique(res$vectors$colour[res$mesh$faces$i[[1]]]),
      "red"
    )
  })

  it("leaves a NULL vector NULL", {
    res <- split_mesh_boundaries(mesh, m$labels, list(texts = NULL))
    expect_null(res$vectors$texts)
  })

  it("keeps the mesh's other elements", {
    res <- split_mesh_boundaries(mesh, m$labels, list())
    expect_identical(res$mesh$extra, "kept")
  })
})

describe("ggseg3d(split_boundaries =)", {
  mesh_of <- function(split) {
    p <- ggseg3d(
      atlas = dk(),
      hemisphere = "left",
      surface = "inflated",
      split_boundaries = split
    )
    p$x$meshes[[1]]
  }

  it("adds geometry only where regions meet", {
    plain <- mesh_of(FALSE)
    split <- mesh_of(TRUE)
    expect_gt(length(split$vertices$x), length(plain$vertices$x))
    # the split is bounded: only the faces straddling a border grow
    expect_lt(length(split$faces$i), 2 * length(plain$faces$i))
  })

  it("leaves no face spanning two colours", {
    split <- mesh_of(TRUE)
    cols <- split$colors
    per_face <- cbind(
      cols[split$faces$i + 1L],
      cols[split$faces$j + 1L],
      cols[split$faces$k + 1L]
    )
    expect_true(all(apply(per_face, 1, function(x) length(unique(x))) == 1L))
  })

  it("still spans two colours per face when turned off", {
    plain <- mesh_of(FALSE)
    cols <- plain$colors
    per_face <- cbind(
      cols[plain$faces$i + 1L],
      cols[plain$faces$j + 1L],
      cols[plain$faces$k + 1L]
    )
    expect_gt(sum(apply(per_face, 1, function(x) length(unique(x))) > 1L), 0)
  })

  it("keeps every per-vertex vector the same length as the vertices", {
    split <- mesh_of(TRUE)
    n <- length(split$vertices$x)
    expect_length(split$colors, n)
    expect_length(split$vertexLabels, n)
  })
})
