# ggseg3d 2.1.3

## Bug fixes

- A duplicated `label` in an atlas now draws its region once, with a warning
  naming the duplicates, instead of once per duplicate row at double the
  vertex count and double darkness under transparency.

- A `colour_by`, `label_by` or `text_by` column that is not in the atlas data
  now raises one error naming the typo and the columns available. `colour_by`
  used to fail inside tibble's recycling code, `label_by` fell back to
  `label`, and `text_by` silently did nothing.

- `add_glassbrain()` accepts the `"lh"`/`"rh"` hemisphere spellings the rest
  of the package takes, and errors on an unrecognised one instead of silently
  returning the plot unchanged.

- `surface = "midthickness"` now reaches `ggseg.meshes`; the surface shipped
  but no ggseg3d function would accept the name.

- Data with a single distinct value no longer colours every region as if it
  had data: regions with no value keep `na_colour`, and the legend shows a
  single swatch instead of disappearing.

- `na_alpha` now does what it documents. Regions with no value in `.data` fade
  per vertex on cortical and cerebellar surfaces and per mesh on subcortical
  structures and tracts. It was accepted and ignored in every previous
  release. Values outside 0-1 are now an error.

- Transparent meshes are drawn front-faces-only and without depth writes, so
  a requested opacity renders as asked instead of blending the mesh against
  its own back faces.

- Mesh face indices now follow the `face_index_base` attribute `ggseg.meshes`
  publishes, falling back to the smallest index used. The previous heuristic
  inspected only the `i` column, so a 0-based mesh that put no vertex 0 there
  would have reached the renderer without being shifted.

- A numeric `colour_by` column matching no atlas region no longer fails with
  `'from' must be a finite number`.

- Atlases whose colour lookup table gives every region the same colour (often
  black) no longer render as a single indistinguishable brain. Region colours
  now come from `ggseg.formats::atlas_plot_palette()`, which substitutes
  distinguishable colours and warns that the atlas colour table is what needs
  fixing. Previously `ggseg3d()` read `atlas$palette` directly and drew such
  atlases faithfully as one solid silhouette, while the same atlas plotted
  correctly in 2D through `ggseg`.

- `print()` on a `ggsegray` object now returns the object invisibly, as print
  methods are expected to. It still renders the scene; only the return value
  changed, and piping was never supported off `print()`.

## Documentation

- `surface` is documented once, in `resolve_brain_mesh()`, instead of four
  mutually inconsistent lists; `sphere`, `smoothwm` and `orig` are now
  documented where a `ggseg3d()` user looks.

- The documented `tube_radius` and `tube_segments` defaults were wrong in both
  places they appeared (5 and 8); they are 2 and 10.

- `surface_opacity` now appears in the "Type-specific arguments" section, and
  the nine widget modifiers cross-reference each other.

- Vignette examples passed the `names`-column spelling (`"superior parietal"`)
  as a `region` value, and full tract names for tracula; neither joined.
  Figures regenerated.

- Roxygen markdown is now enabled, so cross-references and formatting in the
  help pages render as intended. Previously `?ggsegray` and `?ggseg3d` showed
  literal text such as `[pan_camera()]` instead of a link, and the deprecation
  badge on `label`, `text` and `colour` never rendered.

- The error raised for a non-atlas input now points at
  `ggseg.extra::create_cortical_from_labels()`; the function it named before
  does not exist.

## Internal

- All atlas reads now go through the `ggseg.formats` accessors
  (`atlas_vertices()`, `atlas_meshes()`, `atlas_centerlines()`,
  `atlas_plot_palette()`) instead of reaching into `atlas$core`,
  `atlas$palette` and `atlas$data`, except one presence check that reads
  `atlas$data` because the accessors abort rather than return `NULL`. This
  requires a newer `ggseg.formats`; `DESCRIPTION` carries the floor.

- Atlas objects predating the unified `ggseg_atlas` layout, which stored
  `vertices` or `meshes` at the top level instead of under `data`, are no
  longer accepted. They are rejected up front with the usual
  "must be a ggseg_atlas object with 3D data" error rather than failing deeper
  in rendering. No released atlas package ships that layout.

- `png` and `rayshader` moved from `Suggests` to `Config/Needs/website`; they
  are used only by the pkgdown-only articles, which are not part of the built
  package.

- Test fixtures now resolve region names dynamically via
  `ggseg.formats::atlas_regions()` instead of hard-coding schema-specific
  strings, so `ggseg3d` checks cleanly against both the released and
  development `ggseg.formats` atlas schema. Geometry snapshots skip on CRAN.

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
