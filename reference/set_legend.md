# Set legend visibility

For htmlwidget output, toggles legend visibility. For rgl output, draws
or removes the legend overlay.

## Usage

``` r
set_legend(p, show = TRUE)
```

## Arguments

- p:

  A ggseg3d or ggsegray object

- show:

  logical. Whether to show the legend (default: TRUE)

## Value

The input object, modified

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |> set_legend(FALSE)
ggsegray(hemisphere = "left") |> set_legend()
} # }
```
