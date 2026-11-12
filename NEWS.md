# ggseg3d (development version)

## New features

- The read-only atlas accessors from `ggseg.formats` are re-exported, so
  `atlas_palette()`, `atlas_regions()`, `atlas_meshes()` and their siblings
  work after `library(ggseg3d)` and an atlas package, without attaching
  `ggseg.formats`. Requires `ggseg.formats (>= 0.0.4.9015)`
  (ggsegverse/ggseg#183).

## Bug fixes

- An atlas whose vertex indices do not fit the mesh it is drawn on warns
  instead of rendering silently wrong. The warning names how many fall
  outside and says the 2D geometry is unaffected.

- Atlases whose colour table gives every region the same colour no longer
  render as a single indistinguishable brain. Region colours come from
  `ggseg.formats::atlas_plot_palette()`, which substitutes distinguishable
  colours and warns that the atlas colour table is what needs fixing.

- `na_alpha` does what it documents: regions with no value fade per vertex on
  surfaces and per mesh on structures and tracts. It was accepted and ignored
  in every previous release. Values outside 0-1 are an error.

- Transparent meshes are drawn front-faces-only and without depth writes, so
  a requested opacity renders as asked rather than blending against its own
  back faces.

- Data with a single distinct value no longer colours every region as if it
  had data: regions with no value keep `na_colour`, and the legend shows a
  single swatch.

- A duplicated `label` draws its region once, with a warning naming the
  duplicates, instead of once per duplicate row at double darkness.

- A `colour_by`, `label_by` or `text_by` column not in the atlas raises one
  error naming the typo and the columns available.

- Mesh face indices follow the `face_index_base` attribute `ggseg.meshes`
  publishes, falling back to the smallest index used. The previous heuristic
  inspected only the `i` column.

- `add_glassbrain()` accepts the `"lh"`/`"rh"` spellings the rest of the
  package takes, and errors on an unrecognised one.

- `surface = "midthickness"` reaches `ggseg.meshes`; the surface shipped but
  no function would accept the name.

- A numeric `colour_by` column matching no atlas region no longer fails with
  `'from' must be a finite number`.

- `ggseg3d()` says why an atlas it rejects is invalid, reporting the
  structural complaint rather than "must be a `<ggseg_atlas>` object with 3D
  data".

- `print()` on a `ggsegray` object returns the object invisibly. It still
  renders the scene.

## Documentation

- `surface` is documented once, in `resolve_brain_mesh()`, instead of four
  inconsistent lists; `sphere`, `smoothwm` and `orig` are documented where a
  `ggseg3d()` user looks.

- The documented `tube_radius` and `tube_segments` defaults were wrong in
  both places they appeared; they are 2 and 10.

- `surface_opacity` appears in the "Type-specific arguments" section, and the
  nine widget modifiers cross-reference each other.

- Vignette examples passed a `display` name where a `region` was expected,
  and full tract names for tracula; neither joined. Figures regenerated.

- Roxygen markdown is enabled, so cross-references and the lifecycle badges
  render as intended.

- The error raised for a non-atlas input points at
  `ggseg.extra::create_cortical_from_labels()`; the function it named before
  does not exist.

## Internal

- All atlas reads go through the `ggseg.formats` accessors rather than
  reaching into `atlas$core`, `atlas$palette` and `atlas$data`. This requires
  a newer `ggseg.formats`; `DESCRIPTION` carries the floor.

- Atlas objects predating the unified `ggseg_atlas` layout are rejected up
  front rather than failing deeper in rendering. No released atlas package
  ships that layout.

- `png` and `rayshader` moved from `Suggests` to `Config/Needs/website`.

- Test fixtures resolve region names via `ggseg.formats::atlas_regions()`
  rather than hard-coding schema-specific strings. Geometry snapshots skip on
  CRAN.

# ggseg3d 2.1.2

- decouples tests from ggseg.formats internal workings.
- No user changes.

# ggseg3d 2.1.1

## Bug fixes

- Cortical hemispheres are now rendered anatomically side-by-side (LH at
  negative x, RH at positive x, medial edges at the midline) regardless of
  the mesh source. Previously, both hemispheres overlapped at the origin
  because `ggseg.formats` inflated meshes and `ggseg.meshes` pial/white/etc.
  surfaces arrived in different axis conventions. `resolve_brain_mesh()`
  now normalises to the shared `x = LR`, `y = AP`, `z = SI` frame and
  separates hemispheres at `x = 0`.
- `set_positioning()` no longer wrongly shifts subcortical meshes whose
  region names happen to contain "Left"/"Right" (e.g. `Left-Thalamus`); it
  only repositions cortical meshes named `"<hemi> <surface>"`.
- `add_glassbrain()` warns and skips when the widget already contains a
  flat (2D) mesh such as a cerebellar flatmap, since flatmaps share no
  coordinate frame with anatomical 3D meshes.
- `add_glassbrain()` now defaults to `surface = "inflated"` so it works
  without `ggseg.meshes` installed (inflated ships with `ggseg.formats`).

## Documentation

- Replaced `\dontrun{}` wrappers in widget-construction examples with
  executable code so examples run under `R CMD check` and render inline
  in pkgdown. Examples that require `rgl` (Suggests) are now gated with
  `@examplesIf rlang::is_installed("rgl")`.
- Added `LICENSE.note` documenting the bundled Three.js and OrbitControls
  libraries and credited their authors in `Authors@R`.

## Internal

- Removed the `native_offset()` / `to_native_coords()` / `position_hemisphere()`
  helpers. They were workarounds for the previous axis-convention mismatch
  and are no longer needed now that all meshes share a single frame.

# ggseg3d 2.1.0

## Cerebellar atlas support

- New `cerebellar_atlas` class with `prepare_brain_meshes.cerebellar_atlas()`
  method for rendering SUIT cerebellar surfaces with vertex-based colouring.
- Mixed vertex+mesh rendering for deep cerebellar nuclei: the SUIT surface
  renders at 30% opacity with opaque per-region meshes for deep structures.
- `surface_opacity` parameter controls cerebellar surface transparency when
  deep nuclei are present.
- Cortical mesh data moved to the 'ggseg.meshes' package, removing bundled
  `sysdata.rda`.

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
