# Generate per-surface brain meshes for ggseg3d
#
# Creates brain_mesh_pial, brain_mesh_white, and brain_mesh_semi_inflated
# for unified atlas rendering and glassbrain.
# The inflated surface lives in ggseg.formats.
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

all_meshes <- list()

for (hemi in hemispheres) {
  for (surf in surfaces) {
    mesh_name <- paste(hemi, surf, sep = "_")

    cli::cli_alert_info("Generating {mesh_name}...")

    mesh <- ggsegExtra:::read_fs_mesh(
      subject = subject,
      hemisphere = hemi,
      surface = surf
    )

    all_meshes[[mesh_name]] <- list(
      vertices = mesh$vertices,
      faces = mesh$faces
    )

    cli::cli_alert_success(
      "Created {mesh_name}: {nrow(mesh$vertices)}v, {nrow(mesh$faces)}f"
    )
  }

  cli::cli_alert_info("Generating {hemi}_semi-inflated...")

  white_verts <- all_meshes[[paste0(hemi, "_white")]]$vertices
  infl_verts <- all_meshes[[paste0(hemi, "_inflated")]]$vertices

  semi_verts <- data.frame(
    x = 0.5 * white_verts$x + 0.5 * infl_verts$x,
    y = 0.5 * white_verts$y + 0.5 * infl_verts$y,
    z = 0.5 * white_verts$z + 0.5 * infl_verts$z
  )

  all_meshes[[paste0(hemi, "_semi-inflated")]] <- list(
    vertices = semi_verts,
    faces = all_meshes[[paste0(hemi, "_white")]]$faces
  )

  cli::cli_alert_success(
    "Created {hemi}_semi-inflated: {nrow(semi_verts)}v (interpolated)"
  )
}

brain_mesh_pial <- list(
  lh = all_meshes[["lh_pial"]],
  rh = all_meshes[["rh_pial"]]
)

brain_mesh_white <- list(
  lh = all_meshes[["lh_white"]],
  rh = all_meshes[["rh_white"]]
)

brain_mesh_semi_inflated <- list(
  lh = all_meshes[["lh_semi-inflated"]],
  rh = all_meshes[["rh_semi-inflated"]]
)

usethis::use_data(
  brain_mesh_pial,
  brain_mesh_white,
  brain_mesh_semi_inflated,
  internal = TRUE,
  overwrite = TRUE,
  compress = "xz"
)

cli::cli_alert_success("Internal data saved to R/sysdata.rda")
cli::cli_alert_info("Inflated surface is in ggseg.formats::brain_mesh_inflated")
