get_theme_color <- function(path, color) {
  doc <- xml2::read_xml(path)
  dicts <- xml2::xml_find_all(doc, './/dict')

  for (dict in dicts) {
    children <- xml2::xml_children(dict)
    child_names <- xml2::xml_name(children)

    settings_idx <- which(xml2::xml_text(children) == 'settings' & child_names == 'key')

    for (i in settings_idx) {
      if (i < length(children) && xml2::xml_name(children[[i + 1]]) == 'dict') {
        setting_dict <- xml2::xml_children(children[[i + 1]])

        if (length(setting_dict) >= 2) {
          for (j in seq(1, length(setting_dict) - 1, by = 2)) {
            key_node <- setting_dict[[j]]
            value_node <- setting_dict[[j + 1]]
            if (xml2::xml_name(key_node) == 'key' &&
              xml2::xml_text(key_node) == color &&
              xml2::xml_name(value_node) == 'string') {
              return(xml2::xml_text(value_node))
            }
          }
        }
      }
    }
  }
  NULL
}

get_background_color <- function(path) {
  get_theme_color(path, 'background')
}

get_foreground_color <- function(path) {
  get_theme_color(path, 'foreground')
}
