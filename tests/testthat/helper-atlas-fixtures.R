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
  ggseg_atlas(
    atlas = atlas,
    type = "cerebellar",
    core = core,
    data = ggseg_data_cerebellar(vertices = vertices, meshes = meshes),
    palette = palette
  )
}

subcortical_atlas_fixture <- function(
  core,
  meshes,
  palette,
  atlas = "test_subcortical"
) {
  ggseg_atlas(
    atlas = atlas,
    type = "subcortical",
    core = core,
    data = ggseg_data_subcortical(meshes = meshes),
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
  ggseg_atlas(
    atlas = atlas,
    type = "tract",
    core = core,
    data = ggseg_data_tract(centerlines = centerlines, meshes = meshes),
    palette = palette
  )
}
