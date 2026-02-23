# Set region boundary edges

Adds coloured outlines around brain regions. This is useful for
highlighting region boundaries in figures. Works with both htmlwidget
(\`ggseg3d\`) and rgl (\`ggsegray\`) objects. For rgl, edges must have
been computed at creation time via \`edge_by\`.

## Usage

``` r
set_edges(p, colour = "black", width = 1)
```

## Arguments

- p:

  A \`ggseg3d\` widget or \`ggsegray\` rgl object.

- colour:

  string. Edge colour (hex or named color). Set to NULL to hide edges.

- width:

  numeric. Width of edge lines (default: 1). Note: line width \> 1 may
  not render on all systems due to WebGL limitations.

## Value

The input object (modified), for piping.

## Lifecycle

\`r lifecycle::badge("experimental")\`

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d(hemisphere = "left", edge_by = "region") |>
  set_edges("black") |>
  pan_camera("left lateral")

ggsegray(hemisphere = "left", edge_by = "region") |>
  set_edges("red", width = 2) |>
  pan_camera("left lateral")
} # }
```
