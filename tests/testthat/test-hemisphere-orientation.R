blob <- function(centre_x) {
  list(
    vertices = data.frame(
      x = centre_x + c(-1, 1, 0, 0),
      y = c(0, 0, 1, 0),
      z = c(0, 0, 0, 1)
    ),
    faces = data.frame(i = 1L, j = 2L, k = 3L)
  )
}

describe("warn_hemisphere_orientation()", {
  it("stays quiet when left is at x <= 0 and right at x >= 0", {
    expect_no_warning(
      warn_hemisphere_orientation(
        c("left", "right"),
        list(blob(-20), blob(20))
      )
    )
  })

  it("names both hemispheres when the atlas is mirrored", {
    expect_warning(
      warn_hemisphere_orientation(
        c("left", "right"),
        list(blob(20), blob(-20))
      ),
      "mirrored"
    )
  })

  it("counts only the structures that are actually across the midline", {
    expect_warning(
      warn_hemisphere_orientation(
        c("left", "left", "right"),
        list(blob(20), blob(-20), blob(20))
      ),
      "1 of 3"
    )
  })

  it("names the single affected hemisphere when only one side is wrong", {
    expect_warning(
      warn_hemisphere_orientation(c("left", "right"), list(blob(20), blob(20))),
      "left"
    )
  })

  it("ignores rows with no geometry rather than counting them", {
    expect_no_warning(
      warn_hemisphere_orientation(
        c("left", "right"),
        list(NULL, blob(20))
      )
    )
    expect_warning(
      warn_hemisphere_orientation(
        c("left", "left"),
        list(NULL, blob(20))
      ),
      "1 of 1"
    )
  })

  it("ignores hemispheres the contract does not place", {
    expect_no_warning(
      warn_hemisphere_orientation(
        c("midline", NA),
        list(blob(20), blob(-20))
      )
    )
  })

  it("says nothing when there is nothing to check", {
    expect_no_warning(warn_hemisphere_orientation(character(), list()))
    expect_no_warning(warn_hemisphere_orientation("left", list()))
  })

  it("explains the consequence, not just the fact", {
    expect_warning(
      warn_hemisphere_orientation("left", list(blob(20))),
      "pan_camera"
    )
  })
})

describe("subcortical atlases are checked as they are built", {
  mirrored_data <- data.frame(
    label = c("left_thalamus", "right_thalamus"),
    region = c("thalamus", "thalamus"),
    hemi = c("left", "right"),
    colour = c("#FF0000", "#00FF00"),
    stringsAsFactors = FALSE
  )
  mirrored_data$mesh <- list(blob(20), blob(-20))

  it("warns when the geometry is mirrored", {
    expect_warning(
      build_subcortical_meshes(mirrored_data, na_colour = "grey"),
      "wrong side of the midline"
    )
  })

  it("still returns the meshes, because only the atlas can fix this", {
    meshes <- NULL
    expect_warning(
      meshes <- build_subcortical_meshes(mirrored_data, na_colour = "grey"),
      "wrong side of the midline"
    )
    expect_length(meshes, 2)
  })

  it("stays quiet for an atlas that honours the contract", {
    ok <- mirrored_data
    ok$mesh <- list(blob(-20), blob(20))
    expect_no_warning(build_subcortical_meshes(ok, na_colour = "grey"))
  })
})
