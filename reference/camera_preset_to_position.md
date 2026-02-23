# Map camera preset name to position vector

Converts a camera preset string to an xyz position vector matching the
same presets used in the Three.js viewer.

## Usage

``` r
camera_preset_to_position(preset)
```

## Arguments

- preset:

  Character string naming the camera preset.

## Value

Numeric vector of length 3 (x, y, z).
