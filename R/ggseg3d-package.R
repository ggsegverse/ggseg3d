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
#' The package uses `brain_atlas` objects from ggseg.formats
#' that contain 3D vertex mappings.
#'
#' @name ggseg3d-package
#' @docType package
#' @keywords internal
#' @import ggseg.formats
#' @importFrom cli cli_abort cli_warn cli_inform
#' @importFrom utils data
"_PACKAGE"

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
    full.names = TRUE
  )
  if (length(orig) == 0L) {
    cli::cli_inform("No .Rmd.orig files found in vignettes/")
    return(invisible())
  }
  old_wd <- getwd() # nolint: undesirable_function_linter
  setwd("vignettes") # nolint: undesirable_function_linter
  on.exit(setwd(old_wd)) # nolint: undesirable_function_linter
  invisible(lapply(basename(orig), function(f) {
    out <- sub("\\.orig$", "", f)
    cli::cli_inform("Knitting {f} -> {out}")
    knitr::knit(f, output = out)
  }))
  cli::cli_inform("Done. Commit the .Rmd files and any generated figures.")
  invisible()
}
# nocov end
