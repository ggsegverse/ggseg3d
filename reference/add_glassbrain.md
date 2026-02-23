# Add glass brain to ggseg3d plot

Adds a translucent brain surface to a ggseg3d plot for anatomical
reference. Particularly useful for subcortical and tract visualizations
where spatial context helps interpretation. Works with both htmlwidget
(\`ggseg3d\`) and rgl (\`ggsegray\`) objects.

## Usage

``` r
add_glassbrain(
  p,
  hemisphere = c("left", "right"),
  surface = "pial",
  colour = "#CCCCCC",
  opacity = 0.3,
  brain_meshes = NULL
)
```

## Arguments

- p:

  A \`ggseg3d\` widget or \`ggsegray\` rgl object.

- hemisphere:

  Character vector. Hemispheres to add: "left", "right", or both.

- surface:

  Character. Surface type: "inflated", "white", or "pial".

- colour:

  Character. Colour for the glass brain surface (hex or named).

- opacity:

  Numeric. Transparency of the glass brain (0-1).

- brain_meshes:

  Optional user-supplied brain meshes. See
  \[ggseg.formats::get_brain_mesh()\] for format details.

## Value

The input object (modified), for piping.

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d(atlas = aseg()) |>
  add_glassbrain("left", opacity = 0.2)

ggsegray(atlas = aseg()) |>
  add_glassbrain(opacity = 0.15) |>
  pan_camera("right lateral")
} # }
```
