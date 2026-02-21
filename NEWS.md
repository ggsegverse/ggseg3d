# ggseg3d 2.0.0

## Major changes

- Complete rewrite using htmlwidgets with Three.js instead of plotly
- New pipe-friendly API with chainable addition functions
- Support for unified brain_atlas format from ggseg.formats package

## New features

- `set_background()` - set background colour
- `set_legend()` - control legend visibility
- `set_dimensions()` - set widget width and height
- `set_edges()` - add region boundary edges
- `set_flat_shading()` - disable lighting for exact colours
- `set_orthographic()` - use orthographic projection
- `pan_camera()` - position camera at standard anatomical views
- `add_glassbrain()` - add translucent brain surface overlay
- `snapshot_brain()` - save widget as PNG image
- `edge.by` parameter for edge grouping by data columns

## Breaking changes

- Removed plotly dependency
- ggseg3d_atlas objects are deprecated (still supported with warning)

# ggseg3d 1.6.3

- Prepare for CRAN
- Remove white surface from `dk_3d` to reduce size and pass CRAN checks
- Update github urls to new org

# ggseg3d 1.6.02

- Fix bug where installing with vignettes fails

# ggseg3d 1.6.01

- Added ellipsis `...` to plotly::add_trace for people to add more arguments

# ggseg3d 1.5.2

- Adapted to work with dplyr 0.8.1

# ggseg3d 1.5.1

- Changed ggseg_atlas-class to have nested columns for easier viewing and wrangling

# ggseg3d 1.5

- Changed atlas.info to function `atlas_info()`
- Changed brain.pal to function `brain_pal()`
- Reduced code necessary for `brain_pals_info`
- Simplified `display_brain_pal()`
- Moved palettes of ggseg.extra atlases to ggseg.extra package
- Added a `NEWS.md` file to track changes to the package
- Changes all `data` options to `.data` to decrease possibility of column naming overlap
- Added compatibility with `grouped` data.frames
- Reduced internal atlases, to improve CRAN compatibility
- Added function to install extra atlases from github easily
- Changes vignettes to comply with new functionality
