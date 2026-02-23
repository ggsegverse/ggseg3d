# Set background color of ggseg3d plot

Changes the background color of a ggseg3d widget or ggsegray rgl scene.

## Usage

``` r
set_background(p, colour = "#ffffff")
```

## Arguments

- p:

  A \`ggseg3d\` widget or \`ggsegray\` rgl object.

- colour:

  string. Background color (hex or named color)

## Value

The input object (modified), for piping.

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |> set_background("black")

ggsegray(atlas = dk()) |> set_background("black")
} # }
```
