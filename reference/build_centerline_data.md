# Build centerline data for tract atlases

Extracts centerline data from a tract atlas, applies native coordinate
offsets, and assembles the tube generation parameters.

## Usage

``` r
build_centerline_data(atlas, tube_radius = NULL, tube_segments = NULL)
```

## Arguments

- atlas:

  A \`tract_atlas\` object

- tube_radius:

  Optional radius override

- tube_segments:

  Optional segment count override

## Value

List with centerlines, tube_radius, tube_segments, or NULL
