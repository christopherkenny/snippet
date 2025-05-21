#' Render a code snippet using Typst
#'
#' This function renders a static code snippet (and optionally, expected output)
#' using a Typst template and the typr package. It is purely visual and does not
#' evaluate code. Styling, syntax highlighting, and window style are all configurable.
#'
#' @param code Character vector, string, or file path. Code to render.
#' @param output Optional. Character vector, string, or file path with output to show.
#' @param lang Language name for syntax highlighting. Inferred from file if possible.
#' @param title Optional. Title for the code snippet.
#' @param style Window style: one of 'mac', 'windows', or 'none'.
#' @param background Background color (hex or CSS color).
#' @param theme Theme name or path to `.tmTheme` file. Use 'auto' or 'none' for built-ins.
#' @param format Output format: 'pdf', 'png', or 'svg'.
#' @param output_file File path to write the rendered result. If NULL, a temporary file is used.
#'
#' @return Invisibly, the path to the rendered file.
#' @export
#'
#' @examples
#' snippet('x <- 1:10\nmean(x)', lang = 'r')
snippet <- function(code,
                    output = NULL,
                    lang = NULL,
                    title = '',
                    style = c('windows', 'mac', 'none'),
                    background = '#CCCCCC',
                    theme = 'auto',
                    format = c('png', 'pdf', 'svg'),
                    output_file = NULL) {
  style <- match.arg(style)
  format <- match.arg(format)

  tmp_dir <- withr::local_tempdir()

  # handle potential template ----
  template_path <- fs::path_package(package = 'snippet', 'templates', 'main.typ')
  if (!fs::file_exists(template_path)) {
    cli::cli_abort('Missing Typst template at {.path {template_path}}.')
  }

  # handle langs ----
  if (length(code) == 1 && fs::file_exists(code)) {
    code_lines <- readr::read_lines(code)
  } else if (length(code) == 1 && grepl('\n', code)) {
    code_lines <- strsplit(code, '\r?\n')[[1]]
  } else if (is.character(code)) {
    code_lines <- code
  } else {
    cli::cli_abort('Input must be a character vector or a path to a text file.')
  }
  code_block <- paste(code_lines, collapse = '\n')

  if (is.null(lang)) {
    if (length(code) == 1 && fs::file_exists(code)) {
      lang <- fs::path_ext(code)
    }
  }
  if (!rlang::is_string(lang) || lang == '') {
    cli::cli_abort('Must supply a language name via {.arg lang}.')
  }

  # set up output ----
  typst_src <- glue::glue(
    readr::read_file(template_path),
    CODE = code_block,
    LANG = lang,
    TITLE = title,
    THEME = theme_path(theme, tmp_dir),
    STYLE = style,
    BACKGROUND = background,
    .open = '{{', .close = '}}',
  )

  typ_path <- fs::path(tmp_dir, 'snippet.typ')
  readr::write_file(typst_src, typ_path)

  if (is.null(output_file)) {
    output_file <- fs::file_temp(pattern = 'snippet-', ext = format)
  } else {
    fs::dir_create(fs::path_dir(output_file))
  }

  typr::typr_compile(input = typ_path, output_file = output_file, output_format = format)
}

theme_path <- function(theme, dir) {
  if (theme %in% c('auto', 'none')) {
    return(theme)
  }
  if (!fs::file_exists(theme)) {
    cli::cli_abort('Theme file {.path {theme}} not found.')
  }
  dest <- fs::path(dir, fs::path_file(theme))
  fs::file_copy(theme, dest)
  glue::glue('\"{fs::path_file(theme)}\"')
}
