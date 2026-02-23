# Plot 3D brain parcellations

\`ggseg3d\` creates and returns an interactive Three.js brain mesh
visualization. Dispatches to atlas-type-specific methods via
\[prepare_brain_meshes()\].

## Usage

``` r
ggseg3d(
  .data = NULL,
  atlas = dk(),
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
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

- ...:

  Type-specific arguments passed to the atlas method. See section
  \*\*Type-specific arguments\*\* below.

- label, text, colour:

  \`r lifecycle::badge("deprecated")\` Use \`label_by\`, \`text_by\`,
  and \`colour_by\` instead.

## Value

an htmlwidget object for interactive 3D brain visualization

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

## See also

\[pan_camera()\] for camera position, \[set_background()\] for
background colour, \[set_legend()\] for legend visibility

## Author

Athanasia Mowinckel and Didac Piñeiro

## Examples

``` r
if (FALSE) { # \dontrun{
ggseg3d()
ggseg3d(hemisphere = "left") |> pan_camera("left lateral")
ggseg3d() |> set_legend(FALSE)
ggseg3d() |> set_background("black")
} # }
```
