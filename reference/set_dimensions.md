# Set widget dimensions

Changes the width and height of a ggseg3d widget.

## Usage

``` r
set_dimensions(p, width = NULL, height = NULL)
```

## Arguments

- p:

  ggseg3d widget object

- width:

  numeric. Widget width in pixels (NULL for default)

- height:

  numeric. Widget height in pixels (NULL for default)

## Value

ggseg3d widget object with updated dimensions

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |>
  set_dimensions(width = 800, height = 600)
} # }
```
