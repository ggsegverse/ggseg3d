# Build mesh list for cortical atlases

Creates mesh data structures for cortical ggseg_atlas objects using
shared brain meshes with vertex-based colouring.

## Usage

``` r
build_cortical_meshes(
  atlas_data,
  hemisphere,
  surface,
  na_colour,
  edge_by,
  brain_meshes = NULL,
  text_by = NULL,
  label_by = "region"
)
```

## Arguments

- atlas_data:

  Prepared atlas data frame

- hemisphere:

  Hemispheres to include

- surface:

  Surface type

- na_colour:

  Colour for NA values

- edge_by:

  Column for edge grouping (or NULL)

- brain_meshes:

  Optional user-supplied brain meshes

## Value

List of mesh data structures
