# Pan camera position of ggseg3d plot

Sets the camera position for a ggseg3d widget or ggsegray rgl scene to
standard anatomical views or custom positions.

## Usage

``` r
pan_camera(p, camera)
```

## Arguments

- p:

  A \`ggseg3d\` widget or \`ggsegray\` rgl object.

- camera:

  string, list, or numeric vector. Camera position preset name, custom
  eye position list, or \`c(x, y, z)\` for rgl.

  **Available camera presets:**

  - \`left lateral\` or \`left_lateral\`

  - \`left medial\` or \`left_medial\`

  - \`right lateral\` or \`right_lateral\`

  - \`right medial\` or \`right_medial\`

  - \`left superior\` or \`left_superior\`

  - \`right superior\` or \`right_superior\`

  - \`left inferior\` or \`left_inferior\`

  - \`right inferior\` or \`right_inferior\`

  - \`left anterior\` or \`left_anterior\`

  - \`right anterior\` or \`right_anterior\`

  - \`left posterior\` or \`left_posterior\`

  - \`right posterior\` or \`right_posterior\`

## Value

The input object (modified), for piping.

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |> pan_camera("right lateral")

ggsegray(atlas = dk(), hemisphere = "left") |>
  pan_camera("left lateral")
} # }
```
