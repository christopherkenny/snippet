#' Render a code snippet using Typst
#'
#' This function renders a static code snippet using a Typst template and the
#' typr package. It is purely visual and does not evaluate code. Styling,
#' syntax highlighting, and window style are all configurable.
#'
#' @param code Character vector, string, or file path. Code to render. If
#' nothing is supplied, it defaults to reading your current clipboard contents.
#' @param lang Language name for syntax highlighting. Inferred from file
#' extension if `code` is a path, otherwise defaults to `'r'`.
#' @param title Optional title for the code snippet.
#' @param style Window style: one of `'mac'`, `'windows'`, or `'none'`.
#' @param background Background color as a hex string. If not provided,
#' defaults to the background color of the selected theme, or `'#CCCCCC'`.
#' @param theme Theme name from [snippet_themes()] or path to a `.tmTheme`
#' file. Use `'auto'` or `'none'` for Typst's built-in options.
#' @param width Width of the rendered output in inches. Defaults to `5`.
#' @param line_numbers Whether to show line numbers. Defaults to `FALSE`.
#' @param format Output format, one of `'pdf'`, `'png'`, or `'svg'`.
#' @param clip Whether to copy the rendered image to the system clipboard.
#' Only supported when `format = 'png'`. Clipboard support is best effort and
#' may depend on platform-specific tools, especially on Linux. Defaults to
#' `FALSE`.
#' @param output_file File path to write the rendered result. If `NULL`, a
#' temporary file is used.
#'
#' @return Invisibly, the path to the rendered file.
#' @export
#'
#' @examples
#' \dontrun{
#' snippet('x <- 1:10\nmean(x)')
#' }
snippet <- function(code,
                    lang = NULL,
                    title = '',
                    style = c('windows', 'mac', 'none'),
                    background,
                    theme = 'auto',
                    width = 5,
                    line_numbers = FALSE,
                    format = c('png', 'pdf', 'svg'),
                    clip = FALSE,
                    output_file = NULL) {
  style <- match.arg(style)
  format <- match.arg(format)
  code_is_path <- FALSE

  if (isTRUE(clip) && format != 'png') {
    cli::cli_warn('{.arg clip} is only supported for PNG format. Skipping.')
    clip <- FALSE
  }

  tmp_dir <- fs::dir_create(fs::file_temp(pattern = 'snippet-'))

  # handle potential template ----
  template_path <- fs::path_package(package = 'snippet', 'templates', 'main.typ')
  if (!fs::file_exists(template_path)) {
    cli::cli_abort('Missing Typst template at {.path {template_path}}.')
  }

  # handle code ----
  if (missing(code)) {
    code_lines <- clipr::read_clip()
    if (is.null(code_lines) || length(code_lines) == 0 || all(code_lines == '')) {
      cli::cli_abort('No code provided and clipboard is empty.')
    }
  } else if (!is.character(code)) {
    cli::cli_abort('Input must be a character vector or a path to a text file.')
  } else if (length(code) == 1 && fs::file_exists(code)) {
    code_is_path <- TRUE
    code_lines <- readr::read_lines(code)
  } else if (length(code) == 1 && grepl('\n', code)) {
    code_lines <- strsplit(code, '\r?\n')[[1]]
  } else {
    code_lines <- code
  }
  code_block <- paste(code_lines, collapse = '\n')

  # handle langs ----
  if (is.null(lang)) {
    if (isTRUE(code_is_path)) {
      lang <- fs::path_ext(code)
    }
    if (is.null(lang) || !nzchar(lang)) {
      lang <- 'r'
    }
  }

  theme <- resolve_theme(theme)

  # handle background and foreground ----
  if (missing(background)) {
    if (!theme %in% c('auto', 'none')) {
      background <- get_background_color(theme)
    }
  }
  if (missing(background) || is.null(background)) {
    background <- '#CCCCCC'
  }

  foreground <- '#000000'
  if (!theme %in% c('auto', 'none')) {
    fg <- get_foreground_color(theme)
    if (!is.null(fg)) foreground <- fg
  }

  # set up output ----
  user_output_file <- output_file
  tmp_output <- fs::path(tmp_dir, paste0('snippet.', format))

  # generate typ file ----
  typst_src <- glue::glue(
    readr::read_file(template_path),
    CODE = code_block,
    LANG = typst_string(lang),
    TITLE = typst_string(title),
    THEME = theme_path(theme, tmp_dir),
    STYLE = typst_string(style),
    BACKGROUND = typst_string(background),
    FOREGROUND = typst_string(foreground),
    WIDTH = width,
    LINE_NUMBERS = tolower(isTRUE(line_numbers)),
    .open = '{{', .close = '}}',
  )

  typ_path <- fs::path(tmp_dir, 'snippet.typ')
  readr::write_file(typst_src, typ_path)

  # render ----
  out <- typr_compile(input = typ_path, output_file = tmp_output, output_format = format)

  # copy rendered file to user-specified path ----
  if (!is.null(user_output_file)) {
    if (fs::file_exists(tmp_output)) {
      fs::dir_create(fs::path_dir(user_output_file))
      fs::file_copy(tmp_output, user_output_file, overwrite = TRUE)
    }
    out <- user_output_file
  }

  # copy to clipboard ----
  if (isTRUE(clip)) {
    copy_image_to_clipboard(out)
  }

  # open in viewer ----
  if (requireNamespace('rstudioapi', quietly = TRUE) && rstudioapi::isAvailable()) {
    rstudioapi::viewer(out)
  }

  invisible(out)
}

typr_compile <- function(input, output_file, output_format) {
  typr::typr_compile(input = input, output_file = output_file, output_format = output_format)
}
