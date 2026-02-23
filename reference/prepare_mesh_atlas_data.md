# Prepare mesh-based atlas data

Extracts and prepares data from a mesh-based ggseg_atlas object
(subcortical/tract) for rendering. Joins meshes with core region info
and palette colours.

## Usage

``` r
prepare_mesh_atlas_data(atlas, .data)
```

## Arguments

- atlas:

  A mesh-based ggseg_atlas object

- .data:

  Optional user data to merge

## Value

Prepared data frame with hemi, region, label, colour, and mesh
