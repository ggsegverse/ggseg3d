# Generate tube mesh from centerline

Creates a 3D tube mesh around a centerline path using parallel transport
frames for smooth geometry without twisting artifacts.

## Usage

``` r
generate_tube_mesh(centerline, radius = 0.5, segments = 8)
```

## Arguments

- centerline:

  Matrix with N rows and 3 columns (x, y, z coordinates)

- radius:

  Tube radius. Either a single value or vector of length N.

- segments:

  Number of segments around tube circumference.

## Value

List with vertices (data.frame), faces (data.frame), and metadata
