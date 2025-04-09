snippet <- function(x = NULL) {

  # try clip if interactive
  if (is.null(x)) {
    if (interactive()) {
      x <- clipr::read_clip()
    }
  }

  # # escape ----
  # , escape = TRUE
  # if (escape) {
  #   x <- paste0('```', x, '```')
  # }

  x
}
