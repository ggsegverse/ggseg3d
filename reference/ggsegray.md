# Render brain atlas with rgl

Creates an rgl 3D scene from a brain atlas. Uses the same atlas
preparation pipeline as
[`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md)
but outputs to rgl instead of htmlwidgets. The resulting scene can be
piped into
[`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md),
[`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md),
and
[`set_background()`](https://ggsegverse.github.io/ggseg3d/reference/set_background.md),
then rendered with rayshader's `render_highquality()` or captured with
[`rgl::snapshot3d()`](https://dmurdoch.github.io/rgl/dev/reference/snapshot.html).

## Usage

``` r
ggsegray(
  .data = NULL,
  atlas = dk(),
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  material = list(),
  ...,
  label = deprecated(),
  text = deprecated(),
  colour = deprecated()
)
```

## Arguments

- .data:

  A data.frame to use for plot aesthetics. Must include a column called
  "region" corresponding to regions.

- atlas:

  A `ggseg_atlas` object carrying 3D geometry.

- label_by:

  String. Column name used as hover label for each region.

- text_by:

  String. Column name for extra hover text shown below the region label.

- colour_by:

  String. Column name mapped to mesh colours.

- palette:

  Character vector of colour names or hex colours. May instead be a
  named numeric vector whose names are the colours and whose values are
  the breakpoints those colours sit at.

- na_colour:

  String. Colour drawn for regions with no value in `.data`, as a colour
  name or a hex code.

- na_alpha:

  Numeric between 0 and 1. Opacity of regions with no value in `.data`:
  `1` (default) draws them opaque in `na_colour`, lower values fade
  them. Cortical and cerebellar surfaces fade per vertex, subcortical
  structures and tracts per mesh.

- material:

  Named list of rgl material properties passed to
  [`rgl::tmesh3d()`](https://dmurdoch.github.io/rgl/dev/reference/mesh3d.html).
  Controls how the mesh surface is shaded.

- ...:

  Type-specific arguments passed to the atlas method. See section
  **Type-specific arguments** below.

- label, text, colour:

  **\[deprecated\]** Use `label_by`, `text_by`, and `colour_by` instead.

## Value

An object of class `ggsegray` (invisibly), which wraps the rgl device
ID. Pipe into
[`pan_camera()`](https://ggsegverse.github.io/ggseg3d/reference/pan_camera.md),
[`add_glassbrain()`](https://ggsegverse.github.io/ggseg3d/reference/add_glassbrain.md),
or
[`set_background()`](https://ggsegverse.github.io/ggseg3d/reference/set_background.md)
to modify the scene.

## Material properties

Useful material list entries:

- `specular`:

  `"black"` (matte) or `"white"` (glossy).

- `shininess`:

  Specular exponent. Higher = tighter highlights.

- `lit`:

  `FALSE` disables lighting.

- `alpha`:

  Transparency, 0 (invisible) to 1 (opaque).

- `smooth`:

  `TRUE` for Gouraud shading, `FALSE` for flat.

See
[`rgl::material3d()`](https://dmurdoch.github.io/rgl/dev/reference/material.html)
for the full list.

## Type-specific arguments

Cortical atlases (`cortical_atlas`):

- `surface`:

  `"LCBC"` (default, an alias for `"inflated"`) or any surface
  [`resolve_brain_mesh()`](https://ggsegverse.github.io/ggseg3d/reference/resolve_brain_mesh.md)
  accepts.

- `hemisphere`:

  Character vector of hemispheres: `"left"`, `"right"`, or their
  `"lh"`/`"rh"` spellings.

- `edge_by`:

  Column name for region boundary edges.

- `brain_meshes`:

  Custom brain mesh data.

Cerebellar atlases (`cerebellar_atlas`):

- `surface_opacity`:

  Opacity of the cerebellar surface mesh. Defaults to `0.3` when the
  atlas carries deep nuclei, so they stay visible through the surface,
  and `1` otherwise.

Tract atlases (`tract_atlas`):

- `tract_color`:

  `"palette"` (default) or `"orientation"` (direction-based RGB).

- `tube_radius`:

  Tube radius (numeric, default `2`).

- `tube_segments`:

  Tube segment count (integer, default `10`).

## See also

Other brain plots:
[`ggseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d.md)

## Examples

``` r
if (FALSE) { # \dontrun{
# rgl requires OpenGL; not run in check environments.
ggsegray(hemisphere = "left") |>
  pan_camera("left lateral")

ggsegray(atlas = aseg()) |>
  add_glassbrain(opacity = 0.15) |>
  pan_camera("right lateral") |>
  set_background("black")
} # }
```
