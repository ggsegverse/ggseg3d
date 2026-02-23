# Enable flat shading for ggseg3d plot

Disables lighting effects to show colors exactly as specified. Useful
for screenshots where accurate color reproduction is needed, such as
atlas creation pipelines that extract contours from images.

## Usage

``` r
set_flat_shading(p, flat = TRUE)
```

## Arguments

- p:

  ggseg3d widget object

- flat:

  logical. Enable flat shading (default: TRUE)

## Value

ggseg3d widget object with updated shading

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |>
  set_flat_shading()
} # }
```
