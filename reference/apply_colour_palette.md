# Apply colour palette

Processes colour mapping for ggseg_atlas objects using vertex-based
colouring.

## Usage

``` r
apply_colour_palette(atlas_data, colour, palette, na_colour)
```

## Arguments

- atlas_data:

  Atlas data frame with vertices column

- colour:

  Column name for colour values

- palette:

  Colour palette specification

- na_colour:

  Colour for NA values

## Value

List with data, fill column name, palette, and colour metadata
