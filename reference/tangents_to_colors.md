# Convert tangent vectors to orientation RGB colours

Computes direction-based RGB colours from centerline tangent vectors.
Standard tractography colouring: R = left-right (x), G =
anterior-posterior (y), B = superior-inferior (z).

## Usage

``` r
tangents_to_colors(mesh_data)
```

## Arguments

- mesh_data:

  Mesh data with vertices data.frame and metadata list

## Value

Character vector of hex colours (one per mesh vertex)
