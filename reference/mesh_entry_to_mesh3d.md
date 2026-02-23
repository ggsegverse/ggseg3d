# Convert mesh entry to rgl mesh3d object

Converts the internal mesh_entry list structure (as built by
\[make_mesh_entry()\]) into an \[rgl::tmesh3d()\] object for rgl
rendering.

## Usage

``` r
mesh_entry_to_mesh3d(mesh_entry, ...)
```

## Arguments

- mesh_entry:

  A mesh entry list with vertices, faces, colors, colorMode, and
  opacity.

- ...:

  Material properties merged into the \`material\` list of
  \[rgl::tmesh3d()\]. Overrides defaults (\`specular = "black"\`,
  \`shininess = 128\`). See \[rgl::material3d()\] for all options.

## Value

An rgl \`mesh3d\` object
