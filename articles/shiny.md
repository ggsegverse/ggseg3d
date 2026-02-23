# Using ggseg3d in Shiny

ggseg3d widgets work in Shiny applications. This vignette covers the
output and render functions, plus reactive updates.

``` r
library(shiny)
library(ggseg3d)
```

## Basic Shiny integration

Use
[`ggseg3dOutput()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d-shiny.md)
in the UI and
[`renderGgseg3d()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d-shiny.md)
in the server:

``` r
ui <- fluidPage(
  titlePanel("Brain Atlas Viewer"),
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "hemi",
        "Hemisphere",
        choices = c("left", "right", "both"),
        selected = "left"
      )
    ),
    mainPanel(
      ggseg3dOutput("brain", height = "500px")
    )
  )
)

server <- function(input, output, session) {
  output$brain <- renderGgseg3d({
    hemi <- if (input$hemi == "both") NULL else input$hemi

    ggseg3d(hemisphere = hemi) |>
      pan_camera("left lateral")
  })
}

shinyApp(ui, server)
```

## Output sizing

Set explicit dimensions in
[`ggseg3dOutput()`](https://ggsegverse.github.io/ggseg3d/reference/ggseg3d-shiny.md):

``` r
ggseg3dOutput("brain", width = "100%", height = "600px")
```

Or use
[`set_dimensions()`](https://ggsegverse.github.io/ggseg3d/reference/set_dimensions.md)
in the render function:

``` r
renderGgseg3d({
  ggseg3d() |>
    set_dimensions(width = 800, height = 600)
})
```

## Reactive data

Update the brain plot when data changes:

``` r
server <- function(input, output, session) {
  brain_data <- reactive({
    tibble(
      region = c("precentral", "postcentral", "insula"),
      value = runif(3)
    )
  })

  output$brain <- renderGgseg3d({
    ggseg3d(
      .data = brain_data(),
      atlas = dk(), # nolint [object_usage_linter]
      colour_by = "value"
    ) |>
      pan_camera("left lateral")
  })
}
```

## Updating camera and background

Use
[`updateGgseg3dCamera()`](https://ggsegverse.github.io/ggseg3d/reference/updateGgseg3dCamera.md)
and
[`updateGgseg3dBackground()`](https://ggsegverse.github.io/ggseg3d/reference/updateGgseg3dBackground.md)
to modify an existing widget without re-rendering:

``` r
ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput(
        "view",
        "View",
        choices = c(
          "left lateral",
          "left medial",
          "right lateral",
          "right medial"
        )
      ),
      selectInput("bg", "Background", choices = c("white", "black", "grey"))
    ),
    mainPanel(
      ggseg3dOutput("brain")
    )
  )
)

server <- function(input, output, session) {
  output$brain <- renderGgseg3d({
    ggseg3d() |>
      pan_camera("left lateral")
  })

  observeEvent(input$view, {
    updateGgseg3dCamera("brain", input$view)
  })

  observeEvent(input$bg, {
    updateGgseg3dBackground("brain", input$bg)
  })
}
```

These updates are faster than re-rendering the entire widget.

## Complete example

Here’s a full app with data selection and dynamic updates:

``` r
library(shiny)
library(ggseg3d)
library(dplyr)

example_data <- tibble(
  region = c(
    "precentral",
    "postcentral",
    "insula",
    "superior parietal",
    "inferior parietal",
    "supramarginal",
    "cuneus",
    "pericalcarine"
  ),
  thickness = c(2.5, 2.3, 3.1, 2.2, 2.4, 2.6, 1.8, 1.9),
  volume = c(8500, 7200, 6800, 9100, 8800, 7500, 4200, 3800)
)

ui <- fluidPage(
  titlePanel("Brain Metrics Explorer"),
  sidebarLayout(
    sidebarPanel(
      selectInput("metric", "Metric", choices = c("thickness", "volume")),
      selectInput(
        "view",
        "Camera View",
        choices = c(
          "left lateral",
          "left medial",
          "right lateral",
          "right medial",
          "left superior",
          "left inferior"
        )
      ),
      checkboxInput("edges", "Show edges", value = FALSE),
      selectInput("bg", "Background", choices = c("white", "black", "grey90"))
    ),
    mainPanel(
      ggseg3dOutput("brain", height = "600px")
    )
  )
)

server <- function(input, output, session) {
  output$brain <- renderGgseg3d({
    p <- ggseg3d(
      .data = example_data,
      atlas = dk(), # nolint [object_usage_linter]
      colour_by = input$metric,
      text_by = input$metric
    ) |>
      pan_camera(input$view) |>
      set_background(input$bg)

    if (input$edges) {
      p <- p |> set_edges("black")
    }

    p
  })
}

shinyApp(ui, server)
```

## Performance tips

**Minimize re-renders**: Use
[`updateGgseg3dCamera()`](https://ggsegverse.github.io/ggseg3d/reference/updateGgseg3dCamera.md)
and
[`updateGgseg3dBackground()`](https://ggsegverse.github.io/ggseg3d/reference/updateGgseg3dBackground.md)
for camera and background changes instead of re-rendering.

**Debounce reactive data**: If data updates frequently, use
[`debounce()`](https://rdrr.io/pkg/shiny/man/debounce.html) to avoid
excessive re-renders.

**Pre-compute data**: Do data transformations outside the render
function when possible.

**Limit regions**: Showing fewer regions renders faster. Filter your
atlas if you only need specific structures.
