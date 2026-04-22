# Shiny bindings for ggseg3d

Output and render functions for using ggseg3d within Shiny applications
and interactive R Markdown documents.

## Usage

``` r
ggseg3dOutput(outputId, width = "100%", height = "400px")

renderGgseg3d(expr, env = parent.frame(), quoted = FALSE)
```

## Arguments

- outputId:

  output variable to read from

- width, height:

  Must be a valid CSS unit (like `'100%'`, `'400px'`, `'auto'`) or a
  number, which will be coerced to a string and have `'px'` appended.

- expr:

  An expression that generates a ggseg3d

- env:

  The environment in which to evaluate `expr`.

- quoted:

  Is `expr` a quoted expression (with
  [`quote()`](https://rdrr.io/r/base/substitute.html))? This is useful
  if you want to save an expression in a variable.

## Value

\`ggseg3dOutput\` returns an HTML widget output element for use in a
Shiny UI. \`renderGgseg3d\` returns a render function for use in a Shiny
server.

## Examples

``` r
if (FALSE) { # interactive() && rlang::is_installed("shiny")
library(shiny)
ui <- fluidPage(ggseg3dOutput("brain"))
server <- function(input, output) {
  output$brain <- renderGgseg3d(ggseg3d())
}
}
```
