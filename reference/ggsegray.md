# Render brain atlas with rgl

Creates an rgl 3D scene from a brain atlas. Uses the same atlas
preparation pipeline as \[ggseg3d()\] but outputs to rgl instead of
htmlwidgets. The resulting scene can be piped into \[pan_camera()\],
\[add_glassbrain()\], and \[set_background()\], then rendered with
rayshader's \`render_highquality()\` or captured with
\`rgl::snapshot3d()\`.

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

  A \`ggseg_atlas\` object containing 3D vertex mappings, or a string
  naming an atlas function (deprecated).

- label_by:

  String. Column name used as hover label for each region.

- text_by:

  String. Column name for extra hover text shown below the region label.

- colour_by:

  String. Column name mapped to mesh colours.

- palette:

  String. Vector of colour names or HEX colours. Can also be a named
  numeric vector, with colours as names, and breakpoint for that colour
  as the value

- na_colour:

  String. Either name, hex of RGB for colour of NA in colour.

- na_alpha:

  Numeric. A number between 0 and 1 to control transparency of
  NA-regions.

- material:

  Named list of rgl material properties passed to \[rgl::tmesh3d()\].
  Controls how the mesh surface is shaded.

- ...:

  Type-specific arguments passed to the atlas method. See section
  \*\*Type-specific arguments\*\* below.

- label, text, colour:

  \`r lifecycle::badge("deprecated")\` Use \`label_by\`, \`text_by\`,
  and \`colour_by\` instead.

## Value

An object of class \`ggsegray\` (invisibly), which wraps the rgl device
ID. Pipe into \[pan_camera()\], \[add_glassbrain()\], or
\[set_background()\] to modify the scene.

## Material properties

Useful material list entries:

- \`specular\`:

  \`"black"\` (matte) or \`"white"\` (glossy).

- \`shininess\`:

  Specular exponent. Higher = tighter highlights.

- \`lit\`:

  \`FALSE\` disables lighting.

- \`alpha\`:

  Transparency, 0 (invisible) to 1 (opaque).

- \`smooth\`:

  \`TRUE\` for Gouraud shading, \`FALSE\` for flat.

See \[rgl::material3d()\] for the full list.

## Type-specific arguments

Cortical atlases (\`cortical_atlas\`):

- \`surface\`:

  Surface type: \`"LCBC"\` (default, alias for inflated),
  \`"inflated"\`, \`"semi-inflated"\`, \`"white"\`, \`"pial"\`.

- \`hemisphere\`:

  Character vector of hemispheres: \`"right"\`, \`"left"\`.

- \`edge_by\`:

  Column name for region boundary edges.

- \`brain_meshes\`:

  Custom brain mesh data.

Tract atlases (\`tract_atlas\`):

- \`tract_color\`:

  \`"palette"\` (default) or \`"orientation"\` (direction-based RGB).

- \`tube_radius\`:

  Tube radius (numeric, default 5).

- \`tube_segments\`:

  Tube segment count (integer, default 8).

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
