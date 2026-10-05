describe("atlases whose colour table gives every region one colour", {
  it("renders subcortical regions in distinguishable colours", {
    atlas <- make_uniform_palette_atlas()

    plot <- suppressWarnings(ggseg3d(atlas = atlas))
    colours <- vapply(plot$x$meshes, function(mesh) unique(mesh$colors), "")

    expect_length(colours, 2L)
    expect_length(unique(colours), 2L)
    expect_false(any(colours == "#000000"))
  })

  it("warns that the atlas colour table is what needs fixing", {
    expect_warning(
      ggseg3d(atlas = make_uniform_palette_atlas()),
      "no usable colour palette"
    )
  })

  it("substitutes colours for vertex-based atlases too", {
    atlas <- make_test_cortical_atlas(
      palette = c(lh_bankssts = "#000000", lh_precentral = "#000000")
    )

    prepared <- suppressWarnings(prepare_atlas_data(atlas, NULL))

    expect_length(unique(prepared$colour), 2L)
  })
})

describe("atlases whose colour table distinguishes regions", {
  it("keeps the stored colours", {
    atlas <- make_uniform_palette_atlas()
    atlas <- ggseg.formats::set_atlas_palette(
      atlas,
      c("Left-Caudate" = "#112233", "Right-Caudate" = "#445566")
    )

    prepared <- prepare_mesh_atlas_data(atlas, NULL)

    expect_identical(prepared$colour, c("#112233", "#445566"))
  })

  it("renders without warning", {
    expect_no_warning(ggseg3d(atlas = aseg()))
  })
})
