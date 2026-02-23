# Prepare brain meshes and legend data

S3 generic that dispatches to atlas-type-specific preparation methods.
Builds mesh data structures and legend data from a \`ggseg_atlas\`.

## Usage

``` r
prepare_brain_meshes(atlas, ...)

# S3 method for class 'cortical_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  surface = "LCBC",
  hemisphere = c("right", "left"),
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  edge_by = NULL,
  brain_meshes = NULL,
  ...
)

# S3 method for class 'subcortical_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  ...
)

# S3 method for class 'tract_atlas'
prepare_brain_meshes(
  atlas,
  .data = NULL,
  label_by = "region",
  text_by = NULL,
  colour_by = "colour",
  palette = NULL,
  na_colour = "darkgrey",
  na_alpha = 1,
  tract_color = c("palette", "orientation"),
  tube_radius = 2,
  tube_segments = 10,
  ...
)
```

## Arguments

- atlas:

  A \`ggseg_atlas\` object

- ...:

  Type-specific arguments passed to methods

- .data:

  Optional user data to merge

- surface:

  Surface type: \`"inflated"\` (default), \`"semi-inflated"\`,
  \`"white"\`, \`"pial"\`. Use \`"LCBC"\` as alias for \`"inflated"\`.

- hemisphere:

  Character vector of hemispheres: \`"right"\`, \`"left"\`.

- label_by:

  Column name for region hover labels

- text_by:

  Column name for extra hover text

- colour_by:

  Column name for colour values

- palette:

  Colour palette specification

- na_colour:

  Colour for NA values

- na_alpha:

  Transparency for NA regions

- edge_by:

  Column name for region boundary edge grouping

- brain_meshes:

  Optional user-supplied brain meshes

- tract_color:

  \`"palette"\` (default) or \`"orientation"\` (direction-based RGB
  colouring)

- tube_radius:

  Numeric tube radius (default 5 when \`NULL\`).

- tube_segments:

  Integer tube segment count (default 8 when \`NULL\`).

## Value

List with \`meshes\` (list of mesh entries) and \`legend_data\`
