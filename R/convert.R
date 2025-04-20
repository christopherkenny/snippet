json_to_tmtheme <- function(json_path, output_path = NULL) {
  # Load required libraries
  if (!requireNamespace('jsonlite', quietly = TRUE)) {
    stop("Package 'jsonlite' is required. Please install it with install.packages('jsonlite')")
  }
  if (!requireNamespace('xml2', quietly = TRUE)) {
    stop("Package 'xml2' is required. Please install it with install.packages('xml2')")
  }

  # Read JSON theme file
  theme_json <- jsonlite::fromJSON(json_path)

  # Extract theme name and basic info
  theme_name <- theme_json$name
  if (is.null(theme_name)) {
    theme_name <- gsub('\\.json$', '', basename(json_path))
  }

  # Set default output path if not provided
  if (is.null(output_path)) {
    output_path <- file.path(dirname(json_path), paste0(theme_name, '.tmTheme'))
    output_path <- gsub(' ', '_', output_path)
  }

  # Create the basic structure of a tmTheme file
  plist_doc <- xml2::xml_new_document()
  doctype <- xml2::xml_dtd(
    name = 'plist',
    external_id = 'PUBLIC',
    system_id = '-//Apple Computer//DTD PLIST 1.0//EN',
    internal_subset = 'http://www.apple.com/DTDs/PropertyList-1.0.dtd'
  )
  xml2::xml_add_dtd(plist_doc, doctype)

  # Create root element
  root <- xml2::xml_add_child(plist_doc, 'plist', version = '1.0')
  dict <- xml2::xml_add_child(root, 'dict')

  # Add theme name
  xml2::xml_add_child(dict, 'key', 'name')
  xml2::xml_add_child(dict, 'string', theme_name)

  # Add settings array
  xml2::xml_add_child(dict, 'key', 'settings')
  settings_array <- xml2::xml_add_child(dict, 'array')

  # First, add global settings
  global_dict <- xml2::xml_add_child(settings_array, 'dict')
  xml2::xml_add_child(global_dict, 'key', 'settings')
  settings_dict <- xml2::xml_add_child(global_dict, 'dict')

  # Map the global colors
  color_map <- list(
    'editor.background' = 'background',
    'editor.foreground' = 'foreground',
    'editor.selectionBackground' = 'selection',
    'editor.lineHighlightBackground' = 'lineHighlight',
    'editorCursor.foreground' = 'caret',
    'editor.findMatchBackground' = 'findHighlight',
    'editorWhitespace.foreground' = 'invisibles'
  )

  # Add global colors if they exist in the JSON theme
  if (!is.null(theme_json$colors)) {
    for (vscode_key in names(color_map)) {
      if (!is.null(theme_json$colors[[vscode_key]])) {
        xml2::xml_add_child(settings_dict, 'key', color_map[[vscode_key]])
        xml2::xml_add_child(settings_dict, 'string', theme_json$colors[[vscode_key]])
      }
    }
  }

  # Process token colors
  if (!is.null(theme_json$tokenColors)) {
    token_colors <- theme_json$tokenColors
  } else {
    # Try alternative structure
    token_colors <- list()
    if (!is.null(theme_json$tokenColorsCustomizations)) {
      token_colors <- theme_json$tokenColorsCustomizations
    }
  }

  # Process each token color definition
  for (token in token_colors) {
    scope <- token$scope
    settings <- token$settings

    # Skip tokens without settings or scope
    if (is.null(settings) || is.null(scope)) {
      next
    }

    # Create dictionary for this token
    token_dict <- xml2::xml_add_child(settings_array, 'dict')

    # Handle scopes (can be string or array)
    xml2::xml_add_child(token_dict, 'key', 'scope')
    if (is.character(scope) && length(scope) == 1) {
      xml2::xml_add_child(token_dict, 'string', scope)
    } else {
      # Join multiple scopes with comma
      xml2::xml_add_child(token_dict, 'string', paste(scope, collapse = ', '))
    }

    # Add name if available
    if (!is.null(token$name)) {
      xml2::xml_add_child(token_dict, 'key', 'name')
      xml2::xml_add_child(token_dict, 'string', token$name)
    }

    # Add settings
    xml2::xml_add_child(token_dict, 'key', 'settings')
    settings_dict <- xml2::xml_add_child(token_dict, 'dict')

    # Add foreground color
    if (!is.null(settings$foreground)) {
      xml2::xml_add_child(settings_dict, 'key', 'foreground')
      xml2::xml_add_child(settings_dict, 'string', settings$foreground)
    }

    # Add background color if available
    if (!is.null(settings$background)) {
      xml2::xml_add_child(settings_dict, 'key', 'background')
      xml2::xml_add_child(settings_dict, 'string', settings$background)
    }

    # Add fontStyle if available
    if (!is.null(settings$fontStyle)) {
      xml2::xml_add_child(settings_dict, 'key', 'fontStyle')
      xml2::xml_add_child(settings_dict, 'string', settings$fontStyle)
    }
  }

  # Write to file
  xml2::write_xml(plist_doc, output_path)

  message('Theme converted successfully: ', output_path)
  output_path
}
