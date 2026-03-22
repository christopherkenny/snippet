# Internal registry of curated downloadable themes
# Sources:
#   textmate/themes.tmbundle  — official TextMate themes
#   chriskempson/textmate-tomorrow-theme — Tomorrow family (MIT)
#   dracula/textmate — Dracula (MIT)
#   textmate/monokai.tmbundle — original Monokai
#   filmgirl/TextMate-Themes — community TextMate collection
#   microsoft/vscode-themes — Material themes (MIT)
.snippet_known_themes <- c(
  'All Hallows Eve' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/All%20Hallow%27s%20Eve.tmTheme',
  'Blackboard' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Blackboard.tmTheme',
  'Cobalt' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Cobalt.tmTheme',
  'Dawn' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Dawn.tmTheme',
  'Dracula' = 'https://raw.githubusercontent.com/dracula/textmate/master/Dracula.tmTheme',
  'Espresso Libre' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Espresso%20Libre.tmTheme',
  'GitHub' = 'https://raw.githubusercontent.com/filmgirl/TextMate-Themes/master/GitHub.tmTheme',
  'IR Black' = 'https://raw.githubusercontent.com/filmgirl/TextMate-Themes/master/IR_Black.tmTheme',
  'Mac Classic' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Mac%20Classic.tmTheme',
  'Material Dark' = 'https://raw.githubusercontent.com/microsoft/vscode-themes/main/material/themes/Material-Theme.tmTheme',
  'Material Darker' = 'https://raw.githubusercontent.com/microsoft/vscode-themes/main/material/themes/Material-Theme-Darker.tmTheme',
  'Material Light' = 'https://raw.githubusercontent.com/microsoft/vscode-themes/main/material/themes/Material-Theme-Lighter.tmTheme',
  'Monokai' = 'https://raw.githubusercontent.com/textmate/monokai.tmbundle/master/Themes/Monokai.tmTheme',
  'Pastels on Dark' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Pastels%20on%20Dark.tmTheme',
  'Railscasts' = 'https://raw.githubusercontent.com/filmgirl/TextMate-Themes/master/Railscasts.tmTheme',
  'Solarized Dark' = 'https://raw.githubusercontent.com/filmgirl/TextMate-Themes/master/Solarized%20(dark).tmTheme',
  'Solarized Light' = 'https://raw.githubusercontent.com/filmgirl/TextMate-Themes/master/Solarized%20(light).tmTheme',
  'Sunburst' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Sunburst.tmTheme',
  'Tomorrow' = 'https://raw.githubusercontent.com/chriskempson/textmate-tomorrow-theme/master/Tomorrow.tmTheme',
  'Tomorrow Night' = 'https://raw.githubusercontent.com/chriskempson/textmate-tomorrow-theme/master/Tomorrow-Night.tmTheme',
  'Tomorrow Night Bright' = 'https://raw.githubusercontent.com/chriskempson/textmate-tomorrow-theme/master/Tomorrow-Night-Bright.tmTheme',
  'Twilight' = 'https://raw.githubusercontent.com/textmate/themes.tmbundle/master/Themes/Twilight.tmTheme'
)

snippet_cache_dir <- function() {
  tools::R_user_dir('snippet', 'cache')
}

#' Return paths to themes available in snippet
#'
#' Returns paths to both bundled themes and any themes previously installed
#' with [snippet_install_theme()].
#'
#' @returns A named character vector of file paths to available themes.
#' Names are human-readable theme names derived from file names.
#' @export
#'
#' @examples
#' snippet_themes()
snippet_themes <- function() {
  pkg_paths <- fs::dir_ls(
    path = fs::path_package('snippet', 'tmTheme'),
    glob = '*.tmTheme'
  )

  cache_dir <- snippet_cache_dir()
  cache_paths <- if (fs::dir_exists(cache_dir)) {
    fs::dir_ls(path = cache_dir, glob = '*.tmTheme')
  } else {
    character(0)
  }

  paths <- c(pkg_paths, cache_paths)
  names(paths) <- gsub('[-_]', ' ', fs::path_ext_remove(fs::path_file(paths)))
  paths
}

#' List curated themes available to install by name
#'
#' Returns a named character vector of URLs for themes that can be installed
#' by name via [snippet_install_theme()].
#'
#' @returns A named character vector where names are theme names and values
#' are download URLs.
#' @export
#'
#' @examples
#' snippet_known_themes()
snippet_known_themes <- function() {
  .snippet_known_themes
}

#' Install a theme for use with snippet
#'
#' Downloads or copies a `.tmTheme` file to the user's snippet cache directory,
#' making it available to [snippet()] and [snippet_themes()].
#'
#' @param theme One of:
#' - A theme name from [snippet_known_themes()] to download a curated theme
#' - A URL pointing to a `.tmTheme` file to download
#' - A file path to a local `.tmTheme` file to copy
#' @param overwrite Whether to overwrite an existing installed theme.
#' Defaults to `FALSE`.
#'
#' @returns Invisibly, the path to the installed theme file.
#' @export
#'
#' @examples
#' \dontrun{
#' snippet_install_theme('Dracula')
#' snippet_install_theme('https://example.com/my-theme.tmTheme')
#' snippet_install_theme('/path/to/my-theme.tmTheme')
#' }
snippet_install_theme <- function(theme, overwrite = FALSE) {
  cache_dir <- snippet_cache_dir()
  fs::dir_create(cache_dir)

  if (theme %in% names(.snippet_known_themes)) {
    url <- .snippet_known_themes[[theme]]
    dest_name <- paste0(gsub(' ', '-', theme), '.tmTheme')
    dest <- fs::path(cache_dir, dest_name)
    download_theme(url, dest, overwrite = overwrite)
  } else if (grepl('^https?://', theme)) {
    fname <- fs::path_file(utils::URLdecode(theme))
    if (!grepl('\\.tmTheme$', fname, ignore.case = TRUE)) {
      cli::cli_abort('URL must point to a {.file .tmTheme} file.')
    }
    dest <- fs::path(cache_dir, fname)
    download_theme(theme, dest, overwrite = overwrite)
  } else if (fs::file_exists(theme)) {
    if (!grepl('\\.tmTheme$', theme, ignore.case = TRUE)) {
      cli::cli_abort('File must have a {.file .tmTheme} extension.')
    }
    dest <- fs::path(cache_dir, fs::path_file(theme))
    if (!overwrite && fs::file_exists(dest)) {
      cli::cli_inform(
        'Theme {.path {fs::path_file(dest)}} is already installed. Use {.code overwrite = TRUE} to reinstall.'
      )
      return(invisible(as.character(dest)))
    }
    fs::file_copy(theme, dest, overwrite = TRUE)
    cli::cli_inform('Theme installed to {.path {dest}}.')
  } else {
    cli::cli_abort(c(
      'Cannot find theme {.val {theme}}.',
      'i' = 'Known themes: {.val {names(.snippet_known_themes)}}.',
      'i' = 'Or provide a URL or file path to a {.file .tmTheme} file.'
    ))
  }

  invisible(as.character(dest))
}

download_theme <- function(url, dest, overwrite = FALSE) {
  if (!overwrite && fs::file_exists(dest)) {
    cli::cli_inform(
      'Theme {.path {fs::path_file(dest)}} is already installed. Use {.code overwrite = TRUE} to reinstall.'
    )
    return(invisible(as.character(dest)))
  }
  tryCatch(
    utils::download.file(url, destfile = as.character(dest), quiet = TRUE, mode = 'wb'),
    error = \(e) cli::cli_abort(
      'Failed to download theme from {.url {url}}: {conditionMessage(e)}'
    )
  )
  cli::cli_inform('Theme installed to {.path {dest}}.')
  invisible(as.character(dest))
}

resolve_theme <- function(theme) {
  if (theme %in% c('auto', 'none')) {
    return(theme)
  }

  available_themes <- snippet_themes()
  if (theme %in% names(available_themes)) {
    return(unname(available_themes[[theme]]))
  }

  theme
}

typst_escape_string <- function(x) {
  x <- gsub('\\\\', '\\\\\\\\', x)
  x <- gsub('"', '\\"', x, fixed = TRUE)
  x
}

typst_string <- function(x) {
  glue::glue('"{typst_escape_string(x)}"')
}

typst_path <- function(path) {
  normalizePath(path, winslash = '/', mustWork = TRUE)
}

theme_path <- function(theme, dir = tempdir()) {
  if (theme %in% c('auto', 'none')) {
    return(theme)
  }
  if (!fs::file_exists(theme)) {
    cli::cli_abort('Theme file {.path {theme}} not found.')
  }
  typst_string(typst_path(theme))
}
