#' ggseg3d: Plot brain segmentations in 3D
#'
#' Plots statistics on interactive 3D brain meshes, rendered with Three.js
#' through htmlwidgets. Atlases are `ggseg_atlas` objects from
#' `ggseg.formats`; `dk`, `aseg` and `tracula` are re-exported here for
#' convenience.
#'
#' @name ggseg3d-package
#' @docType package
#' @keywords internal
#' @importFrom ggseg.formats dk aseg tracula
"_PACKAGE"

#' @export
ggseg.formats::dk

#' @export
ggseg.formats::aseg

#' @export
ggseg.formats::tracula
