# Update background in Shiny

Sends a message to update the background color of a ggseg3d widget in a
Shiny app.

## Usage

``` r
updateGgseg3dBackground(session, outputId, colour)
```

## Arguments

- session:

  The Shiny session object

- outputId:

  The output ID of the ggseg3d widget

- colour:

  Background color (hex or named color)

## Value

None, called for side effects (sends message to client)

## Examples

``` r
if (FALSE) { # interactive() && rlang::is_installed("shiny")
if (FALSE) { # \dontrun{
updateGgseg3dBackground(session, "brain", "black")
} # }
}
```
