# Build atlas fixtures through ggseg.formats' exported constructors so tests
# exercise ggseg3d behaviour without depending on ggseg.formats' internal S3
# layout. Tests supply the meaningful data (core, vertices, meshes, ...) and
# these helpers assemble a valid ggseg_atlas.

cerebellar_atlas_fixture <- function(
  core,
  vertices = NULL,
  meshes = NULL,
  palette,
  atlas = "test_cerebellar"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "cerebellar",
    core = core,
    data = ggseg.formats::ggseg_data_cerebellar(
      vertices = vertices,
      meshes = meshes
    ),
    palette = palette
  )
}

# Minimal cerebellar atlas used by the visual/snapshot tests so they do not
# depend on external atlas packages.
make_test_cerebellar_atlas <- function() {
  vertices_data <- data.frame(
    label = c("left_I-IV", "right_I-IV"),
    stringsAsFactors = FALSE
  )
  vertices_data$vertices <- list(0L:99L, 100L:199L)

  cerebellar_atlas_fixture(
    core = data.frame(
      label = c("left_I-IV", "right_I-IV"),
      region = c("I-IV", "I-IV"),
      hemi = c("left", "right"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices_data,
    palette = c("left_I-IV" = "#FF0000", "right_I-IV" = "#00FF00")
  )
}

subcortical_atlas_fixture <- function(
  core,
  meshes,
  palette,
  atlas = "test_subcortical"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "subcortical",
    core = core,
    data = ggseg.formats::ggseg_data_subcortical(meshes = meshes),
    palette = palette
  )
}

tract_atlas_fixture <- function(
  core,
  centerlines = NULL,
  meshes = NULL,
  palette,
  atlas = "test_tract"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "tract",
    core = core,
    data = ggseg.formats::ggseg_data_tract(
      centerlines = centerlines,
      meshes = meshes
    ),
    palette = palette
  )
}

cortical_atlas_fixture <- function(
  core,
  vertices = NULL,
  geom = NULL,
  palette,
  atlas = "test_cortical"
) {
  ggseg.formats::ggseg_atlas(
    atlas = atlas,
    type = "cortical",
    core = core,
    data = ggseg.formats::ggseg_data_cortical(
      geom = geom,
      vertices = vertices
    ),
    palette = palette
  )
}

# Cortical atlas carrying vertex indices but no 2D geometry, for the data
# preparation path ggseg3d uses.
make_test_cortical_atlas <- function(
  palette = c(lh_bankssts = "#FF0000", lh_precentral = "#00FF00")
) {
  vertices <- data.frame(
    label = c("lh_bankssts", "lh_precentral"),
    stringsAsFactors = FALSE
  )
  vertices$vertices <- list(0L:9L, 10L:19L)

  cortical_atlas_fixture(
    core = data.frame(
      label = c("lh_bankssts", "lh_precentral"),
      region = c("banks sts", "precentral"),
      hemi = c("left", "left"),
      stringsAsFactors = FALSE
    ),
    vertices = vertices,
    palette = palette
  )
}

# Valid cortical atlas with 2D geometry only, so it carries nothing ggseg3d
# can render in 3D.
make_test_2d_only_atlas <- function() {
  geom <- ggseg.formats::atlas_polygons(dk())
  labels <- unique(geom$label)

  cortical_atlas_fixture(
    core = data.frame(
      label = labels,
      region = sub("^[lr]h_", "", labels),
      hemi = ifelse(startsWith(labels, "lh"), "left", "right"),
      stringsAsFactors = FALSE
    ),
    geom = geom,
    palette = stats::setNames(rep("#FF0000", length(labels)), labels),
    atlas = "test_2d_only"
  )
}

# Subcortical atlas whose colour lookup table gives every region the same
# colour, the shape that used to render as a single black brain.
make_uniform_palette_atlas <- function(colour = "#000000") {
  triangle <- function(offset) {
    list(
      vertices = data.frame(
        x = offset + c(0, 1, 0),
        y = c(0, 0, 1),
        z = c(0, 0, 0)
      ),
      faces = data.frame(i = 1, j = 2, k = 3)
    )
  }

  meshes <- data.frame(
    label = c("Left-Caudate", "Right-Caudate"),
    stringsAsFactors = FALSE
  )
  meshes$mesh <- list(triangle(0), triangle(10))

  subcortical_atlas_fixture(
    core = data.frame(
      label = c("Left-Caudate", "Right-Caudate"),
      region = c("caudate", "caudate"),
      hemi = c("left", "right"),
      stringsAsFactors = FALSE
    ),
    meshes = meshes,
    palette = c("Left-Caudate" = colour, "Right-Caudate" = colour)
  )
}
