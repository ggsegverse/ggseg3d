# Update camera in Shiny

Sends a message to update the camera position of a ggseg3d widget in a
Shiny app.

## Usage

``` r
updateGgseg3dCamera(session, outputId, camera)
```

## Arguments

- session:

  The Shiny session object

- outputId:

  The output ID of the ggseg3d widget

- camera:

  Camera position preset or custom position

## Value

None, called for side effects (sends message to client)

## Examples

``` r
if (FALSE) { # interactive() && rlang::is_installed("shiny")
if (FALSE) { # \dontrun{
updateGgseg3dCamera(session, "brain", "left lateral")
} # }
}
```
