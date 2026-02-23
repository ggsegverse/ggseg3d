# Map atlas vertex indices to region labels

Given a ggseg_atlas with vertices column and a brain mesh, creates a
label vector for each mesh vertex based on which region it belongs to.

## Usage

``` r
vertices_to_labels(atlas_data, n_vertices, na_label = NA_character_)
```

## Arguments

- atlas_data:

  Data frame with region and vertices columns

- n_vertices:

  Number of vertices in the mesh

- na_label:

  Label for vertices not in any region

## Value

Character vector of labels, one per mesh vertex
