#' Render a code snippet using Typst
#'
#' This function renders a static code snippet (and optionally, expected output)
#' using a Typst template and the typr package. It is purely visual and does not
#' evaluate code. Styling, syntax highlighting, and window style are all configurable.
#'
#' @param code Character vector, string, or file path. Code to render.
#' @param output Optional. Character vector, string, or file path with output to show.
#' @param lang Language name for syntax highlighting. Inferred from file if possible.
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
                    style = c('none', 'mac', 'windows'),
                    background = '#ffffff',
                    theme = 'auto',
                    format = c('png', 'pdf', 'svg'),
                    output_file = NULL) {
  style <- match.arg(style)
  format <- match.arg(format)

  tmp_dir <- withr::local_tempdir()
  template_path <- fs::path_package(package = 'snippet', 'templates', 'main.typ')

  if (!fs::file_exists(template_path)) {
    cli::cli_abort('Missing Typst template at {.path {template_path}}.')
  }

  code_lines <- read_lines(code)
  if (is.null(lang)) {
    lang <- infer_lang(code)
  }
  if (!rlang::is_string(lang) || lang == '') {
    cli::cli_abort('Must supply a language name via {.arg lang}.')
  }
  if (!is.null(output)) {
    output_lines <-  read_lines(output)
  } else {
    output_lines <-  character()
  }
  output_lines <- comment_lines(output_lines, lang)
  all_lines <- c(code_lines, output_lines)
  code_block <- paste(all_lines, collapse = '\n')

  typst_src <- glue::glue(
    readr::read_file(template_path),
    .open = '{{', .close = '}}',
    CODE = code_block,
    LANG = lang,
    THEME = theme_path(theme, tmp_dir),
    STYLE = style,
    BG = background
  )

  #return(typst_src)

  typ_path <- fs::path(tmp_dir, 'snippet.typ')
  readr::write_file(typst_src, typ_path)

  if (is.null(output_file)) {
    output_file <- fs::file_temp('snippet-', ext = format)
  } else {
    fs::dir_create(fs::path_dir(output_file))
  }

  typr::typr_compile(input = typ_path, output_file = output_file, output_format = format)
}

read_lines <- function(x) {
  if (length(x) == 1 && fs::file_exists(x)) {
    readr::read_lines(x)
  } else if (length(x) == 1 && grepl('\n', x)) {
    strsplit(x, '\r?\n')[[1]]
  } else if (is.character(x)) {
    x
  } else {
    cli::cli_abort('Input must be a character vector or a path to a text file.')
  }
}

infer_lang <- function(code) {
  if (length(code) == 1 && fs::file_exists(code)) {
    fs::path_ext(code)
  } else {
    NULL
  }
}

comment_lines <- function(lines, lang) {
  prefix <- switch(tolower(lang),
                   'r' = '#> ',
                   'python' = '# ',
                   'js' = '// ',
                   'cpp' = '// ',
                   'c' = '// ',
                   'html' = '<!-- ',
                   'css' = '/* ',
                   '#> ' # fallback
  )
  paste0(prefix, lines)
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
