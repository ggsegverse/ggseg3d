#' ggseg3d: Plot brain segmentations in 3D
#'
#' Plotting results from analyses done on data derived from brain
#' segmentations is a common need, but may be quite laborious.
#' Results from such analyses are usually easier to interpret if
#' the plot can mimmick the shape and position in the brain it
#' represents.
#'
#' This package contains data from various brain parcellations,
#' with convenient functions to inspect the results directly on
#' a brain-plot using interactive 3D mesh visualizations powered
#' by Three.js via htmlwidgets.
#'
#' The package uses `ggseg_atlas` objects from ggseg.formats
#' that contain 3D vertex mappings.
#'
#' @name ggseg3d-package
#' @docType package
#' @keywords internal
#' @import ggseg.formats
"_PACKAGE"

#' @export
ggseg.formats::dk

#' @export
ggseg.formats::aseg

#' @export
ggseg.formats::tracula

# nocov start
#' @noRd
release_questions <- function() {
  c(
    "Have you re-knitted precompiled vignettes 
    with `ggseg3d:::knit_vignettes()`?"
  )
}

#' @noRd
knit_vignettes <- function() {
  orig <- list.files(
    "vignettes",
    pattern = "\\.Rmd\\.orig$",
    full.names = TRUE,
    recursive = TRUE
  ) |>
    normalizePath()
  if (length(orig) == 0L) {
    cli::cli_inform("No .Rmd.orig files found in vignettes/")
    return(invisible())
  }
  invisible(lapply(orig, function(f) {
    out <- sub("\\.orig$", "", f)
    old_root <- knitr::opts_knit$get("root.dir")
    knitr::opts_knit$set(root.dir = dirname(f))
    on.exit(
      knitr::opts_knit$set(root.dir = old_root)
    )
    knitr::knit(f, output = out)
  }))
  cli::cli_inform("Done. Commit the .Rmd files and any generated figures.")
  invisible()
}
# nocov end
