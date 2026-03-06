#' Convert a VS Code JSON theme to tmTheme format
#'
#' Converts a VS Code JSON-formatted color theme to a tmTheme file (Apple
#' property list XML), suitable for use with [snippet()].
#'
#' @param json_path Path to a VS Code JSON theme file.
#' @param output_path Path for the output `.tmTheme` file. If `NULL`, the
#' file is saved next to `json_path` using the theme name.
#'
#' @return Invisibly, the path to the output `.tmTheme` file.
#' @export
#'
#' @examples
#' \dontrun{
#' convert_theme('my-vscode-theme.json')
#' }
convert_theme <- function(json_path, output_path = NULL) {
  if (!requireNamespace('jsonlite', quietly = TRUE)) {
    cli::cli_abort(
      'Package {.pkg jsonlite} is required. Install it with
      {.code install.packages("jsonlite")}.'
    )
  }

  theme_json <- jsonlite::fromJSON(json_path)

  theme_name <- theme_json$name
  if (is.null(theme_name)) {
    theme_name <- gsub('\\.json$', '', basename(json_path))
  }

  if (is.null(output_path)) {
    output_path <- file.path(dirname(json_path), paste0(theme_name, '.tmTheme'))
    output_path <- gsub(' ', '_', output_path)
  }

  plist_doc <- xml2::xml_new_document()
  root <- xml2::xml_add_child(plist_doc, 'plist', version = '1.0')
  dict <- xml2::xml_add_child(root, 'dict')

  xml2::xml_add_child(dict, 'key', 'name')
  xml2::xml_add_child(dict, 'string', theme_name)

  xml2::xml_add_child(dict, 'key', 'settings')
  settings_array <- xml2::xml_add_child(dict, 'array')

  global_dict <- xml2::xml_add_child(settings_array, 'dict')
  xml2::xml_add_child(global_dict, 'key', 'settings')
  settings_dict <- xml2::xml_add_child(global_dict, 'dict')

  color_map <- list(
    'editor.background' = 'background',
    'editor.foreground' = 'foreground',
    'editor.selectionBackground' = 'selection',
    'editor.lineHighlightBackground' = 'lineHighlight',
    'editorCursor.foreground' = 'caret',
    'editor.findMatchBackground' = 'findHighlight',
    'editorWhitespace.foreground' = 'invisibles'
  )

  if (!is.null(theme_json$colors)) {
    for (vscode_key in names(color_map)) {
      if (!is.null(theme_json$colors[[vscode_key]])) {
        xml2::xml_add_child(settings_dict, 'key', color_map[[vscode_key]])
        xml2::xml_add_child(settings_dict, 'string', theme_json$colors[[vscode_key]])
      }
    }
  }

  if (!is.null(theme_json$tokenColors)) {
    token_colors <- theme_json$tokenColors
  } else {
    token_colors <- list()
    if (!is.null(theme_json$tokenColorsCustomizations)) {
      token_colors <- theme_json$tokenColorsCustomizations
    }
  }

  for (token in token_colors) {
    scope <- token$scope
    settings <- token$settings

    if (is.null(settings) || is.null(scope)) {
      next
    }

    token_dict <- xml2::xml_add_child(settings_array, 'dict')

    xml2::xml_add_child(token_dict, 'key', 'scope')
    if (is.character(scope) && length(scope) == 1) {
      xml2::xml_add_child(token_dict, 'string', scope)
    } else {
      xml2::xml_add_child(token_dict, 'string', paste(scope, collapse = ', '))
    }

    if (!is.null(token$name)) {
      xml2::xml_add_child(token_dict, 'key', 'name')
      xml2::xml_add_child(token_dict, 'string', token$name)
    }

    xml2::xml_add_child(token_dict, 'key', 'settings')
    settings_dict <- xml2::xml_add_child(token_dict, 'dict')

    if (!is.null(settings$foreground)) {
      xml2::xml_add_child(settings_dict, 'key', 'foreground')
      xml2::xml_add_child(settings_dict, 'string', settings$foreground)
    }

    if (!is.null(settings$background)) {
      xml2::xml_add_child(settings_dict, 'key', 'background')
      xml2::xml_add_child(settings_dict, 'string', settings$background)
    }

    if (!is.null(settings$fontStyle)) {
      xml2::xml_add_child(settings_dict, 'key', 'fontStyle')
      xml2::xml_add_child(settings_dict, 'string', settings$fontStyle)
    }
  }

  xml2::write_xml(plist_doc, output_path)

  invisible(output_path)
}
