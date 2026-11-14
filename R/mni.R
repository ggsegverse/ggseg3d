#' Convert between plot coordinates and a standard space
#'
#' `mesh_to_mni()` takes coordinates as the plot draws them and returns where
#' they are in a standard space; `mni_to_mesh()` goes the other way, which is
#' what you want for putting [add_points()] somewhere specific.
#'
#' @details
#' The surfaces are fsaverage5, and fsaverage is an MNI305 average, so their
#' coordinates already *are* MNI305 apart from a shift: each hemisphere is
#' moved so it meets the midline at `x = 0`, which is what lets the two be
#' drawn together. These functions add or remove that shift, reading it from
#' the mesh rather than assuming it, so a rebuilt mesh cannot silently put
#' every point in the wrong place.
#'
#' `space = "mni152"` applies FreeSurfer's published MNI305-to-MNI152
#' transform on top. It moves a coordinate by roughly a millimetre.
#'
#' Only anatomical surfaces can be converted. An inflated or spherical
#' surface has had every vertex moved, so a position on it does not
#' correspond to a place in the brain, and asking is an error rather than a
#' number that looks usable.
#'
#' @param x,y,z Numeric coordinates.
#' @param hemisphere `"lh"` or `"rh"` -- which hemisphere's shift applies.
#' @param surface The surface the coordinates belong to. One of `"white"`,
#'   `"pial"`, `"midthickness"`, `"smoothwm"` or `"orig"`.
#' @param space `"mni305"`, which fsaverage is, or `"mni152"`.
#'
#' @return A data.frame of `x`, `y` and `z`.
#' @family brain modifiers
#' @export
#'
#' @examples
#' # where does a point in MNI space sit in the plot?
#' mni_to_mesh(-42, -20, 55, hemisphere = "lh")
#'
#' # and back again
#' mesh_to_mni(-43.2, -20, 55, hemisphere = "lh")
mesh_to_mni <- function(
  x,
  y,
  z,
  hemisphere = c("lh", "rh"),
  surface = "pial",
  space = c("mni305", "mni152")
) {
  hemisphere <- match.arg(hemisphere)
  space <- match.arg(space)
  shift <- mesh_shift(hemisphere, surface)

  out <- data.frame(
    x = x - shift[["x"]],
    y = y - shift[["y"]],
    z = z - shift[["z"]]
  )
  if (identical(space, "mni152")) {
    out <- apply_affine(out, mni305_to_mni152_matrix())
  }
  out
}


#' @rdname mesh_to_mni
#' @export
mni_to_mesh <- function(
  x,
  y,
  z,
  hemisphere = c("lh", "rh"),
  surface = "pial",
  space = c("mni305", "mni152")
) {
  hemisphere <- match.arg(hemisphere)
  space <- match.arg(space)
  shift <- mesh_shift(hemisphere, surface)

  out <- data.frame(x = x, y = y, z = z)
  if (identical(space, "mni152")) {
    out <- apply_affine(out, solve(mni305_to_mni152_matrix()))
  }
  data.frame(
    x = out$x + shift[["x"]],
    y = out$y + shift[["y"]],
    z = out$z + shift[["z"]]
  )
}


#' Surfaces whose coordinates mean something anatomically
#'
#' Inflation and spherical registration move every vertex, so a point on an
#' inflated surface has no anatomical position to convert. Only the surfaces
#' that keep the brain's own shape can be mapped to a standard space.
#' @noRd
anatomical_surfaces <- function() {
  c("white", "pial", "midthickness", "smoothwm", "orig")
}


#' MNI305 to MNI152, as FreeSurfer defines it
#'
#' fsaverage is an MNI305 average, so the surfaces are already MNI305 and
#' nothing is approximated getting there. MNI152 is a further step, and this
#' is FreeSurfer's published transform for it
#' (<https://surfer.nmr.mgh.harvard.edu/fswiki/CoordinateSystems>).
#'
#' `test-mni.R` checks the rotation against the `mni152.register.dat` that
#' FreeSurfer ships, which is the part that can be verified locally. The
#' translation is taken from the published matrix: the only MNI152 volume
#' shipped with FreeSurfer here is a model template on a different convention,
#' so composing through it would not confirm it. The difference at stake is
#' about a millimetre, which this package's scope treats as guidance rather
#' than precision -- but it is a millimetre taken on authority, not measured.
#' @noRd
mni305_to_mni152_matrix <- function() {
  matrix(
    c(
      0.9975,
      -0.0073,
      0.0176,
      -0.0429,
      0.0146,
      1.0009,
      -0.0024,
      1.5496,
      -0.0130,
      -0.0093,
      0.9971,
      1.1840,
      0,
      0,
      0,
      1
    ),
    nrow = 4,
    byrow = TRUE
  )
}


#' Apply a 4x4 affine to coordinate columns
#' @noRd
apply_affine <- function(coords, m) {
  out <- cbind(as.matrix(coords), 1) %*% t(m)
  data.frame(x = out[, 1], y = out[, 2], z = out[, 3])
}


#' The shift between a drawn surface and its own coordinates
#' @noRd
mesh_shift <- function(hemisphere, surface, call = rlang::caller_env()) {
  if (!surface %in% anatomical_surfaces()) {
    cli::cli_abort(
      c(
        "{.val {surface}} has no anatomical coordinates to convert.",
        "x" = "Inflation and spherical registration move every vertex, so a
               position on this surface does not correspond to a place in the
               brain.",
        "i" = "Use one of {.val {anatomical_surfaces()}}."
      ),
      call = call
    )
  }
  mesh <- resolve_brain_mesh(hemisphere, surface)
  if (is.null(mesh)) {
    cli::cli_abort(
      "No {.val {surface}} mesh for {.val {hemisphere}}.",
      call = call
    )
  }
  shift <- attr(mesh, "mni_shift")
  if (is.null(shift)) {
    cli::cli_abort(
      c(
        "The {.val {surface}} mesh does not record how it was positioned.",
        "i" = "Converting without it would be off by the hemisphere's own
               offset from the midline."
      ),
      call = call
    )
  }
  shift
}
