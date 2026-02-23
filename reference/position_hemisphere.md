# Position hemisphere vertices for anatomical display

Offsets hemisphere vertices so left is at negative x and right at
positive x, with medial surfaces adjacent at the midline. Used by
\[add_glassbrain()\] for anatomical context.

## Usage

``` r
position_hemisphere(vertices, hemisphere)
```

## Arguments

- vertices:

  data.frame with x, y, z columns

- hemisphere:

  "left" or "right"

## Value

data.frame with adjusted x coordinates
