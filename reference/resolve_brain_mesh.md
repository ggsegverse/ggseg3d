# Resolve brain surface mesh

Resolves and prepares a brain surface mesh for rendering. Delegates to
\[ggseg.formats::get_brain_mesh()\] for inflated surfaces and to
\[ggseg.meshes::get_cortical_mesh()\] for pial, white, semi-inflated,
and other surfaces. Returned meshes use the shared anatomical axis
convention (\`x\` = left-right, \`y\` = anterior-posterior, \`z\` =
superior-inferior) with \`lh\` positioned at \`x \<= 0\` and \`rh\` at
\`x \>= 0\`, medial edges meeting at the midline (\`x = 0\`).

## Usage

``` r
resolve_brain_mesh(
  hemisphere = c("lh", "rh"),
  surface = c("inflated", "semi-inflated", "white", "pial", "sphere", "smoothwm", "orig"),
  brain_meshes = NULL
)
```

## Arguments

- hemisphere:

  \`"lh"\` or \`"rh"\`

- surface:

  Surface type: \`"inflated"\`, \`"semi-inflated"\`, \`"white"\`,
  \`"pial"\`, \`"sphere"\`, \`"smoothwm"\`, \`"orig"\`

- brain_meshes:

  Optional user-supplied mesh data. Passed through to
  \[ggseg.formats::get_brain_mesh()\] for format details.

## Value

list with vertices (data.frame with x, y, z) and faces (data.frame with
i, j, k), or NULL if mesh not found

## Examples

``` r
mesh <- resolve_brain_mesh("lh", "inflated")
str(mesh, max.level = 1)
#> List of 2
#>  $ vertices:'data.frame':    10242 obs. of  3 variables:
#>  $ faces   :'data.frame':    20480 obs. of  3 variables:
```
