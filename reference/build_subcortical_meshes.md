# Build mesh list for subcortical atlases

Creates mesh data structures for subcortical atlases with per-region
mesh data using face-based colouring (each structure is a separate
mesh).

## Usage

``` r
build_subcortical_meshes(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region"
)
```

## Arguments

- atlas_data:

  Prepared atlas data frame with label, colour, and mesh columns

- na_colour:

  Colour for NA values

## Value

List of mesh data structures
