# Save ggseg3d widget as image

Takes a screenshot of a ggseg3d widget and saves it as a PNG image.
Requires a Chrome-based browser to be installed.

## Usage

``` r
snapshot_brain(p, file, width = 600, height = 500, delay = 1, zoom = 2, ...)
```

## Arguments

- p:

  ggseg3d widget object

- file:

  string. Output file path (should end in .png)

- width:

  numeric. Image width in pixels (default: 600)

- height:

  numeric. Image height in pixels (default: 500)

- delay:

  numeric. Seconds to wait for widget to render before capture (default:
  1)

- zoom:

  numeric. Zoom factor for higher resolution (default: 2)

- ...:

  Additional arguments passed to webshot2::webshot

## Value

The file path (invisibly)

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |>
  pan_camera("left lateral") |>
  snapshot_brain("brain.png")
} # }
```
