# Map atlas vertex indices to mesh colors

Given a ggseg_atlas with vertices column and a brain mesh, creates a
color vector for each mesh vertex based on which region it belongs to.

## Usage

``` r
vertices_to_colors(atlas_data, n_vertices, na_colour = "#CCCCCC")
```

## Arguments

- atlas_data:

  Data frame with region, colour, and vertices columns

- n_vertices:

  Number of vertices in the mesh

- na_colour:

  Color for vertices not in any region

## Value

Character vector of colors, one per mesh vertex
