# Enable orthographic camera for ggseg3d plot

Uses orthographic projection instead of perspective. This eliminates
perspective distortion and ensures consistent sizing across all views.

## Usage

``` r
set_orthographic(p, ortho = TRUE, frustum_size = 220)
```

## Arguments

- p:

  ggseg3d widget object

- ortho:

  logical. Enable orthographic mode (default: TRUE)

- frustum_size:

  numeric. Size of the orthographic frustum. Controls how much of the
  scene is visible. Default 220 works well for brain meshes. Use the
  same value across all views for consistent sizing.

## Value

ggseg3d widget object with updated camera mode

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d() |>
  set_orthographic()
} # }
```
