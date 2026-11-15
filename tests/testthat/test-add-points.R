sensors <- function(n = 3) {
  # Built at full size and then cut down: paste0() treats a zero-length
  # argument as "", so seq_len(0) would give a one-row frame, not an empty one.
  out <- data.frame(
    x = (1:3) * 10,
    y = (1:3) * -5,
    z = (1:3) * 2,
    name = paste0("S", 1:3),
    stringsAsFactors = FALSE
  )
  out[seq_len(n), , drop = FALSE]
}

sphere_vertices <- nrow(unit_sphere()$vertices)

describe("unit_sphere()", {
  it("is a closed unit sphere", {
    s <- unit_sphere()
    expect_equal(
      range(sqrt(rowSums(s$vertices^2))),
      c(1, 1),
      tolerance = 1e-12
    )
  })

  it("indexes only vertices it has", {
    s <- unit_sphere()
    expect_true(all(unlist(s$faces) %in% seq_len(nrow(s$vertices))))
  })
})

describe("add_points()", {
  base <- function() ggseg3d(atlas = dk(), hemisphere = "left")

  it("adds one mesh holding every marker", {
    p <- add_points(base(), sensors(3), x = x, y = y, z = z)
    added <- p$x$meshes[[length(p$x$meshes)]]
    expect_identical(added$name, "points")
    expect_length(added$vertices$x, 3L * sphere_vertices)
    # Faces matter as much as vertices: a marker with vertices and no faces
    # is invisible, and collapsing every index to 1 once passed this file.
    expect_length(added$faces$i, 3L * nrow(unit_sphere()$faces))
    expect_true(all(unlist(added$faces) < 3L * sphere_vertices))
    expect_setequal(
      unique(added$faces$i %/% sphere_vertices),
      0:2
    )
  })

  it("draws one sphere per row even when a coordinate is constant", {
    # A scalar coordinate used to leave every marker but the first with no
    # faces at all -- silently, with no warning.
    p <- add_points(base(), sensors(3), x = 0, y = y, z = z)
    added <- p$x$meshes[[length(p$x$meshes)]]
    expect_length(added$faces$i, 3L * nrow(unit_sphere()$faces))
    expect_length(added$colors, 3L * sphere_vertices)
  })

  it("colours every vertex it draws", {
    # A short colour vector leaves trailing vertices black in the renderer.
    p <- add_points(base(), sensors(3), x = x, y = y, z = z)
    added <- p$x$meshes[[length(p$x$meshes)]]
    expect_length(added$colors, length(added$vertices$x))
  })

  it("refuses a non-numeric coordinate", {
    d <- sensors(2)
    d$x <- factor(c("a", "b"))
    expect_error(add_points(base(), d, x = x, y = y, z = z), "must be numeric")
  })

  it("drops markers with missing coordinates, and says so", {
    d <- sensors(3)
    d$x[2] <- NA
    out <- NULL
    expect_warning(
      out <- add_points(base(), d, x = x, y = y, z = z),
      "missing coordinates"
    )
    added <- out$x$meshes[[length(out$x$meshes)]]
    expect_length(added$vertices$x, 2L * sphere_vertices)
  })

  it("rejects an opacity that is not a fraction", {
    expect_error(
      add_points(base(), sensors(1), x = x, y = y, z = z, opacity = 50),
      "between 0 and 1"
    )
  })

  it("carries opacity onto the entry", {
    p <- add_points(base(), sensors(1), x = x, y = y, z = z, opacity = 0.5)
    expect_equal(p$x$meshes[[length(p$x$meshes)]]$opacity, 0.5)
  })

  it("refuses a missing colour rather than drawing it white", {
    expect_error(
      add_points(
        base(),
        sensors(2),
        x = x,
        y = y,
        z = z,
        colour = c("red", NA)
      ),
      "missing value"
    )
  })

  it("refuses a malformed hex colour", {
    expect_error(
      add_points(base(), sensors(1), x = x, y = y, z = z, colour = "#GGGGGG"),
      "not a valid hex"
    )
  })

  it("leaves the brain meshes in place", {
    before <- length(base()$x$meshes)
    p <- add_points(base(), sensors(2), x = x, y = y, z = z)
    expect_length(p$x$meshes, before + 1L)
  })

  it("puts each marker at its own coordinates", {
    p <- add_points(base(), sensors(2), x = x, y = y, z = z, size = 1)
    v <- p$x$meshes[[length(p$x$meshes)]]$vertices
    first <- seq_len(sphere_vertices)
    # A UV sphere repeats its poles and seam, so the vertex mean is not the
    # centre; the bounding box's midpoint is.
    midpoint <- function(v) mean(range(v))
    expect_equal(midpoint(v$x[first]), 10, tolerance = 1e-6)
    expect_equal(midpoint(v$y[first]), -5, tolerance = 1e-6)
    expect_equal(midpoint(v$z[first]), 2, tolerance = 1e-6)

    second <- sphere_vertices + first
    expect_equal(midpoint(v$x[second]), 20, tolerance = 1e-6)
    expect_equal(midpoint(v$z[second]), 4, tolerance = 1e-6)
  })

  it("scales a marker by size", {
    small <- add_points(base(), sensors(1), x = x, y = y, z = z, size = 1)
    big <- add_points(base(), sensors(1), x = x, y = y, z = z, size = 5)
    spread <- function(p) {
      diff(range(p$x$meshes[[length(p$x$meshes)]]$vertices$x))
    }
    expect_equal(spread(big) / spread(small), 5, tolerance = 1e-6)
  })

  it("accepts a colour per marker and converts names to hex", {
    p <- add_points(
      base(),
      sensors(2),
      x = x,
      y = y,
      z = z,
      colour = c("red", "#00FF00")
    )
    cols <- unique(p$x$meshes[[length(p$x$meshes)]]$colors)
    expect_setequal(toupper(cols), c("#FF0000", "#00FF00"))
  })

  it("errors when a per-marker argument is the wrong length", {
    expect_error(
      add_points(
        base(),
        sensors(3),
        x = x,
        y = y,
        z = z,
        colour = c("red", "blue")
      ),
      "length 1 or 3"
    )
    expect_error(
      add_points(base(), sensors(3), x = x, y = y, z = z, size = c(1, 2)),
      "length 1 or 3"
    )
  })

  it("carries hover text on the field the renderer reads", {
    # BrainMeshRenderer only reads vertexTexts inside a vertexLabels branch,
    # so asserting vertexTexts alone passed while hover showed "points".
    p <- add_points(base(), sensors(2), x = x, y = y, z = z, text = name)
    added <- p$x$meshes[[length(p$x$meshes)]]
    expect_setequal(unique(added$vertexLabels), c("S1", "S2"))
    expect_length(added$vertexLabels, length(added$vertices$x))
  })

  it("adds no text when none is asked for", {
    p <- add_points(base(), sensors(2), x = x, y = y, z = z)
    expect_null(p$x$meshes[[length(p$x$meshes)]]$vertexLabels)
  })

  it("warns and changes nothing when data has no rows", {
    before <- length(base()$x$meshes)
    p <- NULL
    expect_warning(
      p <- add_points(base(), sensors(0), x = x, y = y, z = z),
      "no rows"
    )
    expect_length(p$x$meshes, before)
  })

  it("rejects something that is not a data frame", {
    expect_error(
      add_points(base(), list(x = 1, y = 2, z = 3), x = x, y = y, z = z),
      "data.frame"
    )
  })

  it("rejects something that is not a ggseg3d plot", {
    expect_error(
      add_points(list(), sensors(1), x = x, y = y, z = z),
      "ggseg3d"
    )
  })
})

describe("add_atlas()", {
  base <- function() ggseg3d(atlas = dk(), hemisphere = "left")

  it("appends the added atlas's meshes", {
    before <- length(base()$x$meshes)
    p <- add_atlas(base(), aseg())
    expect_gt(length(p$x$meshes), before)
  })

  it("keeps the original atlas's meshes first", {
    p <- add_atlas(base(), aseg())
    expect_identical(p$x$meshes[[1]]$name, base()$x$meshes[[1]]$name)
  })

  it("passes arguments through to the added atlas", {
    both <- add_atlas(base(), dk(), hemisphere = c("left", "right"))
    one <- add_atlas(base(), dk(), hemisphere = "left")
    expect_gt(length(both$x$meshes), length(one$x$meshes))
  })

  it("rejects something that is not an atlas", {
    expect_error(add_atlas(base(), list()), "ggseg_atlas")
  })

  it("refuses a flat atlas being added to an anatomical plot", {
    # The commoner direction, and the one the host-side test missed: it is
    # the *added* atlas that is flat.
    local_mocked_bindings(
      prepare_brain_meshes = function(...) {
        list(meshes = list(list(name = "flat", isFlatmap = TRUE)))
      }
    )
    out <- NULL
    expect_warning(out <- add_atlas(base(), aseg()), "flat")
    expect_length(out$x$meshes, length(base()$x$meshes))
  })

  it("warns and changes nothing when the atlas produces no meshes", {
    local_mocked_bindings(
      prepare_brain_meshes = function(...) list(meshes = list())
    )
    out <- NULL
    expect_warning(out <- add_atlas(base(), aseg()), "no meshes")
    expect_length(out$x$meshes, length(base()$x$meshes))
  })

  it("draws the added atlas on the surface the plot already uses", {
    # Left to its own default the added atlas arrives inflated, which is a
    # different shape from the pial surface it would sit beside.
    host <- ggseg3d(atlas = dk(), hemisphere = "left", surface = "pial")
    out <- add_atlas(host, dk(), hemisphere = "left")
    names <- vapply(out$x$meshes, function(m) m$name, character(1))
    expect_true(all(grepl("pial$", names)))
  })

  it("refuses to combine a flat surface with anatomical meshes", {
    p <- base()
    p$x$meshes[[1]]$isFlatmap <- TRUE
    out <- NULL
    expect_warning(out <- add_atlas(p, aseg()), "flat")
    expect_length(out$x$meshes, length(p$x$meshes))
  })
})


describe("the rgl path", {
  it("accepts points and leaves a ggsegray a ggsegray", {
    skip_if_not_installed("rgl")
    p <- ggsegray(hemisphere = "left", atlas = dk()) |>
      add_points(sensors(2), x = x, y = y, z = z)
    expect_s3_class(p, "ggsegray")
    rgl::close3d()
  })

  it("accepts a second atlas", {
    skip_if_not_installed("rgl")
    p <- ggsegray(hemisphere = "left", atlas = dk()) |>
      add_atlas(aseg())
    expect_s3_class(p, "ggsegray")
    rgl::close3d()
  })
})
