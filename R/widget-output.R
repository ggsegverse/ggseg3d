#' Shiny bindings for ggseg3d
#'
#' Output and render functions for using ggseg3d within Shiny
#' applications and interactive R Markdown documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a ggseg3d
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @return `ggseg3dOutput` returns an HTML widget output element for use in
#'   a Shiny UI. `renderGgseg3d` returns a render function for use in a
#'   Shiny server.
#'
#' @name ggseg3d-shiny
#'
#' @importFrom htmlwidgets shinyWidgetOutput shinyRenderWidget
#'
#' @examplesIf rlang::is_installed("shiny") && interactive()
#' library(shiny)
#' ui <- fluidPage(ggseg3dOutput("brain"))
#' server <- function(input, output) {
#'   output$brain <- renderGgseg3d(ggseg3d())
#' }
#'
#' @export
# nolint start: object_name_linter
ggseg3dOutput <- function(outputId, width = "100%", height = "400px") {
  htmlwidgets::shinyWidgetOutput(
    outputId,
    "ggseg3d",
    width,
    height,
    package = "ggseg3d"
  )
}

#' @rdname ggseg3d-shiny
#' @export
renderGgseg3d <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) {
    expr <- substitute(expr)
  }
  htmlwidgets::shinyRenderWidget(expr, ggseg3dOutput, env, quoted = TRUE)
}


#' Update camera in Shiny
#'
#' Sends a message to update the camera position of a ggseg3d widget
#' in a Shiny app.
#'
#' @param session The Shiny session object
#' @param outputId The output ID of the ggseg3d widget
#' @param camera Camera position preset or custom position
#'
#' @return None, called for side effects (sends message to client)
#'
#' @examplesIf rlang::is_installed("shiny") && interactive()
#' \dontrun{
#' updateGgseg3dCamera(session, "brain", "left lateral")
#' }
#'
#' @export
updateGgseg3dCamera <- function(session, outputId, camera) {
  session$sendCustomMessage(paste0("ggseg3d-camera-", outputId), camera)
}


#' Update background in Shiny
#'
#' Sends a message to update the background color of a ggseg3d widget
#' in a Shiny app.
#'
#' @param session The Shiny session object
#' @param outputId The output ID of the ggseg3d widget
#' @param colour Background color (hex or named color)
#'
#' @return None, called for side effects (sends message to client)
#'
#' @examplesIf rlang::is_installed("shiny") && interactive()
#' \dontrun{
#' updateGgseg3dBackground(session, "brain", "black")
#' }
#'
#' @export
updateGgseg3dBackground <- function(session, outputId, colour) {
  if (!grepl("^#", colour)) {
    colour <- col2hex(colour)
  }
  session$sendCustomMessage(paste0("ggseg3d-background-", outputId), colour)
}
# nolint end
