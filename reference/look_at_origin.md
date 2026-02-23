# Compute rgl rotation matrix to look at the origin from a given position

Builds a 4x4 rotation matrix suitable for \`rgl::view3d(userMatrix =
...)\` that orients the scene as if the camera is at \`eye\` looking
toward the origin with z pointing up.

## Usage

``` r
look_at_origin(eye)
```

## Arguments

- eye:

  Numeric vector of length 3 (x, y, z) — camera position.

## Value

A 4x4 rotation matrix.
