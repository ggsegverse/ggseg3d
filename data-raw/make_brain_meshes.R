# Generate internal brain meshes for ggseg3d
#
# Creates brain_meshes for unified atlas rendering and glassbrain.
# Requires ggsegExtra and FreeSurfer.
#
# Run with: source("data-raw/make_brain_meshes.R")

library(dplyr)

if (!requireNamespace("ggsegExtra", quietly = TRUE)) {
  stop(
    "ggsegExtra is required.",
    " Install with: remotes::install_github('ggseg/ggsegExtra')"
  )
}

if (!freesurfer::have_fs()) {
  stop("FreeSurfer is required to generate brain meshes.")
}

subject <- "fsaverage5"
surfaces <- c("inflated", "pial", "white")
hemispheres <- c("lh", "rh")

brain_meshes <- list()

for (hemi in hemispheres) {
  for (surf in surfaces) {
    mesh_name <- paste(hemi, surf, sep = "_")

    cli::cli_alert_info("Generating {mesh_name}...")

    mesh <- ggsegExtra:::get_brain_mesh(
      subject = subject,
      hemisphere = hemi,
      surface = surf
    )

    brain_meshes[[mesh_name]] <- list(
      vertices = mesh$vertices,
      faces = mesh$faces
    )

    cli::cli_alert_success(
      "Created {mesh_name}: {nrow(mesh$vertices)}v, {nrow(mesh$faces)}f"
    )
  }

  cli::cli_alert_info("Generating {hemi}_semi-inflated...")

  white_verts <- brain_meshes[[paste0(hemi, "_white")]]$vertices
  infl_verts <- brain_meshes[[paste0(hemi, "_inflated")]]$vertices

  semi_verts <- data.frame(
    x = 0.5 * white_verts$x + 0.5 * infl_verts$x,
    y = 0.5 * white_verts$y + 0.5 * infl_verts$y,
    z = 0.5 * white_verts$z + 0.5 * infl_verts$z
  )

  brain_meshes[[paste0(hemi, "_semi-inflated")]] <- list(
    vertices = semi_verts,
    faces = brain_meshes[[paste0(hemi, "_white")]]$faces
  )

  cli::cli_alert_success(
    "Created {hemi}_semi-inflated: {nrow(semi_verts)}v (interpolated)"
  )
}

usethis::use_data(
  brain_meshes,
  internal = TRUE,
  overwrite = TRUE,
  compress = "xz"
)

cli::cli_alert_success("Internal data saved to R/sysdata.rda")
