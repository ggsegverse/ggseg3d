## R CMD check results

0 errors | 0 warnings | 0 notes

A timing NOTE for the `ggseg3d()` example can appear on a loaded machine; the
example itself uses ~2s of CPU.

Checked with `--as-cran` on macOS (R 4.5) against the development
`ggseg.formats`. Two geometry snapshot tests were regenerated for the new
`ggseg.formats` 0.1.0 atlas schema before submission.

## Release summary

Patch release. `ggseg3d()` now reads region colours through
`ggseg.formats::atlas_plot_palette()`, so atlases built from colour lookup
tables that give every region the same colour render with distinguishable
colours instead of as one solid silhouette. All atlas reads moved to the
`ggseg.formats` accessor API, which raises the dependency floor to
`ggseg.formats (>= 0.1.0)`.

Roxygen markdown is now enabled, fixing help pages that shipped literal
`[function()]` text instead of cross-references.

`png` and `rayshader` moved from `Suggests` to `Config/Needs/website`, as
they are used only by pkgdown-only articles that are not part of the built
package.
