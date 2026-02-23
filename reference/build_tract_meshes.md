# Build mesh list for tract atlases

Creates mesh data structures for tract atlases with per-vertex
colouring. Supports palette colours (uniform per tract) or
orientation-based RGB colours computed from centerline tangent vectors.

## Usage

``` r
build_tract_meshes(
  atlas_data,
  na_colour,
  color_by = "colour",
  atlas_centerlines = NULL,
  text_by = NULL,
  label_by = "region"
)
```

## Arguments

- atlas_data:

  Prepared atlas data frame with label, colour, and mesh columns

- na_colour:

  Colour for NA values

- color_by:

  How to colour tracts: "colour" (use colour column), "orientation"
  (direction-based RGB from tangents)

## Value

List of mesh data structures
