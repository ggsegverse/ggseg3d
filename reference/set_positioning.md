# Set hemisphere positioning mode

Repositions meshes in a ggseg3d widget to either anatomical or centered
mode. This modifies the x-coordinates of all meshes in the widget.

## Usage

``` r
set_positioning(p, positioning = c("anatomical", "centered"))
```

## Arguments

- p:

  ggseg3d widget object

- positioning:

  How to position hemispheres: - "anatomical": Offset so medial surfaces
  are adjacent at midline. Left at negative x, right at positive x. Best
  for displaying both hemispheres together. - "centered": Center each
  hemisphere at the origin. Best for single-hemisphere snapshots where
  consistent sizing is needed.

## Value

ggseg3d widget object with repositioned meshes

## Examples

``` r
if (FALSE) { # \dontrun{
# View both hemispheres anatomically positioned
ggseg3d(hemisphere = c("left", "right")) |>
  set_positioning("anatomical") |>
  pan_camera("left lateral")

# Atlas creation: centered (default) for consistent sizing
ggseg3d(hemisphere = "left") |>
  set_orthographic() |>
  pan_camera("left lateral") |>
  snapshot_brain("left_lateral.png")
} # }
```
