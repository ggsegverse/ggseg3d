# Resolve brain surface mesh

Resolves and prepares a brain surface mesh for rendering. Delegates to
\[ggseg.formats::get_brain_mesh()\] for inflated surfaces, provides
pial, white, and semi-inflated surfaces from ggseg3d internal data,
corrects 0-based face indices, and centers inflated/semi-inflated meshes
on pial centroids.

## Usage

``` r
resolve_brain_mesh(
  hemisphere = c("lh", "rh"),
  surface = c("inflated", "semi-inflated", "white", "pial"),
  brain_meshes = NULL
)
```

## Arguments

- hemisphere:

  \`"lh"\` or \`"rh"\`

- surface:

  Surface type: \`"inflated"\`, \`"semi-inflated"\`, \`"white"\`,
  \`"pial"\`

- brain_meshes:

  Optional user-supplied mesh data. Passed through to
  \[ggseg.formats::get_brain_mesh()\] for format details.

## Value

list with vertices (data.frame with x, y, z) and faces (data.frame with
i, j, k), or NULL if mesh not found
