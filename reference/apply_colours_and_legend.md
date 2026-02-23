# Apply colour palette and build legend data

Shared pipeline step for all atlas types: applies colour palette to
atlas data and builds the legend data structure.

## Usage

``` r
apply_colours_and_legend(atlas_data, colour_by, palette, na_colour, label_by)
```

## Arguments

- atlas_data:

  Prepared atlas data frame

- colour_by:

  Column name for colour values

- palette:

  Colour palette specification

- na_colour:

  Colour for NA values

- label_by:

  Column name for labels

## Value

List with \`atlas_data\` and \`legend_data\`
