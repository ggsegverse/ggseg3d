fsaverage5_surf <- function(hemi, surface) {
  fs <- tryCatch(freesurfer::fs_dir(), error = function(e) NA_character_)
  testthat::skip_if(is.na(fs), "FreeSurfer not available")
  f <- file.path(
    fs,
    "subjects",
    "fsaverage5",
    "surf",
    paste0(hemi, ".", surface)
  )
  testthat::skip_if_not(file.exists(f), "fsaverage5 surfaces not available")
  freesurferformats::read.fs.surface(f)$vertices
}

describe("mesh_to_mni() / mni_to_mesh()", {
  it("round-trips exactly", {
    back <- mni_to_mesh(-42, -20, 55, hemisphere = "lh")
    fwd <- mesh_to_mni(back$x, back$y, back$z, hemisphere = "lh")
    expect_equal(c(fwd$x, fwd$y, fwd$z), c(-42, -20, 55), tolerance = 1e-10)
  })

  it("round-trips through MNI152 too", {
    back <- mni_to_mesh(-42, -20, 55, hemisphere = "lh", space = "mni152")
    fwd <- mesh_to_mni(
      back$x,
      back$y,
      back$z,
      hemisphere = "lh",
      space = "mni152"
    )
    expect_equal(c(fwd$x, fwd$y, fwd$z), c(-42, -20, 55), tolerance = 1e-8)
  })

  it("leaves y and z alone, because only x is shifted", {
    out <- mesh_to_mni(-10, -20, 30, hemisphere = "lh")
    expect_identical(out$y, -20)
    expect_identical(out$z, 30)
  })

  it("shifts the two hemispheres by different amounts", {
    l <- mesh_to_mni(0, 0, 0, hemisphere = "lh")$x
    r <- mesh_to_mni(0, 0, 0, hemisphere = "rh")$x
    expect_false(isTRUE(all.equal(l, r)))
  })

  it("is vectorised", {
    out <- mesh_to_mni(c(-10, -20), c(0, 1), c(2, 3), hemisphere = "lh")
    expect_identical(nrow(out), 2L)
  })

  it("moves a coordinate by about a millimetre between the MNI spaces", {
    a <- mesh_to_mni(-43, -20, 55, hemisphere = "lh")
    b <- mesh_to_mni(-43, -20, 55, hemisphere = "lh", space = "mni152")
    d <- sqrt((a$x - b$x)^2 + (a$y - b$y)^2 + (a$z - b$z)^2)
    expect_gt(d, 0.1)
    expect_lt(d, 5)
  })

  it("refuses a surface whose coordinates mean nothing anatomically", {
    for (surf in c("inflated", "sphere", "semi-inflated")) {
      expect_error(
        mesh_to_mni(0, 0, 0, hemisphere = "lh", surface = surf),
        "anatomical",
        label = surf
      )
    }
  })

  it("puts a drawn vertex back on the surface it came from", {
    # The claim the whole helper rests on: undoing the shift recovers
    # fsaverage5's own coordinates, which are MNI305.
    src <- fsaverage5_surf("lh", "pial")
    drawn <- resolve_brain_mesh("lh", "pial")$vertices
    i <- c(1L, 500L, 5000L)
    out <- mesh_to_mni(drawn$x[i], drawn$y[i], drawn$z[i], hemisphere = "lh")
    expect_equal(out$x, src[i, 1], tolerance = 1e-5)
    expect_equal(out$y, src[i, 2], tolerance = 1e-5)
    expect_equal(out$z, src[i, 3], tolerance = 1e-5)
  })

  it("matches FreeSurfer's own MNI152 rotation", {
    # Only the rotation can be checked locally: mni152.register.dat is a
    # tkregister matrix, so its translation is in the target volume's frame,
    # not scanner RAS. A sign or axis slip in the published matrix would
    # still be caught here.
    fs <- tryCatch(freesurfer::fs_dir(), error = function(e) NA_character_)
    skip_if(is.na(fs), "FreeSurfer not available")
    f <- file.path(fs, "average", "mni152.register.dat")
    skip_if_not(file.exists(f), "mni152.register.dat not available")
    reg <- as.matrix(utils::read.table(f, skip = 4, nrows = 3))
    ours <- mni305_to_mni152_matrix()[1:3, 1:3]
    # register.dat orders its rows for the volume, not for scanner RAS.
    expect_equal(unname(reg[1, 1:3]), ours[1, ], tolerance = 1e-3)
    expect_equal(unname(-reg[3, 1:3]), ours[2, ], tolerance = 1e-3)
    expect_equal(unname(reg[2, 1:3]), ours[3, ], tolerance = 1e-3)
  })
})

describe("the mesh records how it was positioned", {
  it("carries the shift that was applied to it", {
    for (h in c("lh", "rh")) {
      shift <- attr(resolve_brain_mesh(h, "pial"), "mni_shift")
      expect_named(shift, c("x", "y", "z"))
      expect_identical(unname(shift[c("y", "z")]), c(0, 0))
    }
  })

  it("records a shift that actually puts the hemisphere on its own side", {
    for (h in c("lh", "rh")) {
      v <- resolve_brain_mesh(h, "pial")$vertices
      if (h == "lh") expect_lte(max(v$x), 0) else expect_gte(min(v$x), 0)
    }
  })

  it("agrees with the offset measured against fsaverage5", {
    src <- fsaverage5_surf("rh", "pial")
    drawn <- resolve_brain_mesh("rh", "pial")$vertices
    measured <- mean(drawn$x - src[, 1])
    expect_equal(
      attr(resolve_brain_mesh("rh", "pial"), "mni_shift")[["x"]],
      measured,
      tolerance = 1e-6
    )
  })
})
