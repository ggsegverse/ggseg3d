# Prepare atlas data

Extracts and prepares data from a ggseg_atlas object for rendering.
Joins vertices with core region info and palette colours.

## Usage

``` r
prepare_atlas_data(atlas, .data)
```

## Arguments

- atlas:

  A ggseg_atlas object

- .data:

  Optional user data to merge

## Value

Prepared data frame with hemi, region, label, colour, and vertices
