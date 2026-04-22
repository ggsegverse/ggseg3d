# Build mesh list for cerebellar atlases

Creates mesh data structures for cerebellar ggseg_atlas objects using
the shared SUIT cerebellar surface with vertex-based colouring.

## Usage

``` r
build_cerebellar_meshes(
  atlas_data,
  na_colour,
  text_by = NULL,
  label_by = "region",
  opacity = 1
)
```

## Arguments

- atlas_data:

  Prepared atlas data frame with vertices column

- na_colour:

  Colour for NA values

- text_by:

  Column for hover text (or NULL)

- label_by:

  Column for vertex labels

- opacity:

  Numeric opacity for the mesh (0 = transparent, 1 = opaque)

## Value

List of mesh data structures
