# Build legend data structure

Creates the appropriate legend data structure based on whether the
colour variable is numeric (continuous colorbar) or categorical
(discrete legend).

## Usage

``` r
build_legend_data(
  is_numeric,
  data_min,
  data_max,
  palette,
  pal_colours,
  colour_col,
  label_col,
  fill_col,
  data
)
```

## Arguments

- is_numeric:

  Whether the colour variable is numeric

- data_min:

  Minimum data value (for continuous)

- data_max:

  Maximum data value (for continuous)

- palette:

  Original palette specification

- pal_colours:

  Processed palette colours

- colour_col:

  Name of the colour column

- label_col:

  Name of the label column

- fill_col:

  Name of the fill column

- data:

  Atlas data

## Value

List with legend specification or NULL
