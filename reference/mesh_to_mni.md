# Convert between plot coordinates and a standard space

`mesh_to_mni()` takes coordinates as the plot draws them and returns
where they are in a standard space; `mni_to_mesh()` goes the other way,
which is what you want for putting
[`add_points()`](https://ggsegverse.github.io/ggseg3d/reference/add_points.md)
somewhere specific.

## Usage

``` r
mesh_to_mni(
  x,
  y,
  z,
  hemisphere = c("lh", "rh"),
  surface = "pial",
  space = c("mni305", "mni152")
)

mni_to_mesh(
  x,
  y,
  z,
  hemisphere = c("lh", "rh"),
  surface = "pial",
  space = c("mni305", "mni152")
)
```

## Arguments

- x, y, z:

  Numeric coordinates.

- hemisphere:

  `"lh"` or `"rh"` – which hemisphere's shift applies.

- surface:

  The surface the coordinates belong to. One of `"white"`, `"pial"`,
  `"midthickness"`, `"smoothwm"` or `"orig"`.

- space:

  `"mni305"`, which fsaverage is, or `"mni152"`.

## Value

A data.frame of `x`, `y` and `z`.

## Details

The surfaces are fsaverage5, and fsaverage is an MNI305 average, so
their coordinates already *are* MNI305 apart from a shift: each
hemisphere is moved so it meets the midline at `x = 0`, which is what
lets the two be drawn together. These functions add or remove that
shift, reading it from the mesh rather than assuming it, so a rebuilt
mesh cannot silently put every point in the wrong place.

`space = "mni152"` applies FreeSurfer's published MNI305-to-MNI152
transform on top. Across the brain that moves a coordinate by two to
three millimetres.

Only anatomical surfaces can be converted. An inflated or spherical
surface has had every vertex moved, so a position on it does not
correspond to a place in the brain, and asking is an error rather than a
number that looks usable.

## Examples

``` r
# where does a point in MNI space sit in the plot?
mni_to_mesh(-42, -20, 55, hemisphere = "lh")
#>           x   y  z
#> 1 -43.22156 -20 55

# and back again
mesh_to_mni(-43.2, -20, 55, hemisphere = "lh")
#>           x   y  z
#> 1 -41.97844 -20 55
```
