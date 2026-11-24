#' Apply colour palette
#'
#' Processes colour mapping for ggseg_atlas objects using
#' vertex-based colouring.
#'
#' @param colour Column name for colour values
#'
#' @return List with data, fill column name, palette, and colour metadata
#' @inheritParams apply_colours_and_legend
#' @keywords internal
#' @noRd
apply_colour_palette <- function(
  atlas_data,
  colour,
  palette,
  na_colour,
  na_alpha = 1
) {
  check_na_alpha(na_alpha)

  # three.js knows the CSS keywords only, and 453 of R's 657 colour names are
  # not among them: it warns and draws white, which on a white page is
  # invisible.
  na_colour <- col2hex(na_colour)

  pal_colours <- get_palette(palette)
  is_numeric <- colour %in%
    names(atlas_data) &&
    is.numeric(atlas_data[[colour]])
  data_min <- NA
  data_max <- NA

  if (is_numeric && all(is.na(atlas_data[[colour]]))) {
    # No region matched, so there is no range to map and nothing to legend.
    atlas_data$new_col <- NA_character_
    fill <- "new_col"
  } else if (is_numeric) {
    data_min <- min(atlas_data[[colour]], na.rm = TRUE)
    data_max <- max(atlas_data[[colour]], na.rm = TRUE)

    if (data_min == data_max) {
      atlas_data$new_col <- ifelse(
        is.na(atlas_data[[colour]]),
        NA_character_,
        pal_colours$orig[1]
      )
    } else {
      if (is.null(names(palette))) {
        pal_colours$values <- seq(
          data_min,
          data_max,
          length.out = nrow(pal_colours)
        )
      }
      atlas_data$new_col <- scales::gradient_n_pal(
        pal_colours$orig,
        pal_colours$values,
        "Lab"
      )(atlas_data[[colour]])
      warn_outside_palette(
        atlas_data[[colour]],
        atlas_data$new_col,
        pal_colours$values
      )
    }
    fill <- "new_col"
  } else {
    fill <- colour
  }

  atlas_data$alpha <- ifelse(is.na(atlas_data[[fill]]), na_alpha, 1)

  atlas_data$colour <- vapply(
    atlas_data[[fill]],
    function(c) {
      if (is.na(c)) {
        na_colour
      } else if (grepl("^#", c)) {
        c
      } else {
        col2hex(c)
      }
    },
    character(1)
  )

  list(
    data = atlas_data,
    fill = fill,
    palette = pal_colours,
    is_numeric = is_numeric,
    data_min = data_min,
    data_max = data_max
  )
}


# na_alpha reaches the renderer as a material opacity or a vertex alpha, both
# of which clamp silently, so a nonsense value would be invisible.
check_na_alpha <- function(na_alpha, call = rlang::caller_env()) {
  valid <- is.numeric(na_alpha) &&
    length(na_alpha) == 1 &&
    !is.na(na_alpha) &&
    na_alpha >= 0 &&
    na_alpha <= 1

  if (!valid) {
    cli::cli_abort(
      "{.arg na_alpha} must be a single number between 0 and 1.",
      call = call
    )
  }
}


# A named palette narrower than the data maps the values outside it to NA,
# which reaches the renderer as na_colour -- the same drawing as a region
# with no data at all.
warn_outside_palette <- function(values, colours, pal_values) {
  outside <- sum(!is.na(values) & is.na(colours))
  if (outside == 0) {
    return(invisible(NULL))
  }

  cli::cli_warn(c(
    "{outside} value{?s} fall{?s/} outside the palette range
     {.val {range(pal_values)}}.",
    "i" = "Those regions are drawn in {.arg na_colour}, like a region with
           no data."
  ))
}
