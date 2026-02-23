# Map vertices to text values for hover display

Assigns text values to mesh vertices based on a column in atlas data.
Used for per-vertex hover text in the Three.js tooltip.

## Usage

``` r
vertices_to_text(atlas_data, n_vertices, text_col)
```

## Arguments

- atlas_data:

  Data frame with vertices list column

- n_vertices:

  Number of vertices in the mesh

- text_col:

  Name of the column containing text values

## Value

Character vector of text values, one per mesh vertex
