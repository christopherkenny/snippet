# snippet_install_theme skips if already installed and overwrite = FALSE

    Code
      snippet_install_theme(theme)
    Message
      Theme 'Flexoki-Dark.tmTheme' is already installed. Use `overwrite = TRUE` to reinstall.

# snippet_install_theme errors for URL without .tmTheme extension

    Code
      snippet_install_theme("https://example.com/theme.json")
    Condition
      Error in `snippet_install_theme()`:
      ! URL must point to a '.tmTheme' file.

# snippet_install_theme errors for local file without .tmTheme extension

    Code
      snippet_install_theme(tmp)
    Condition
      Error in `snippet_install_theme()`:
      ! File must have a '.tmTheme' extension.

# snippet_install_theme errors for unknown theme name

    Code
      snippet_install_theme("Unknown Theme XYZ")
    Condition
      Error in `snippet_install_theme()`:
      ! Cannot find theme "Unknown Theme XYZ".
      i Known themes: "All Hallows Eve", "Blackboard", "Cobalt", "Dawn", "Dracula", "Espresso Libre", "GitHub", "IR Black", "Mac Classic", "Material Dark", "Material Darker", "Material Light", "Monokai", "Pastels on Dark", "Railscasts", "Solarized Dark", "Solarized Light", "Sunburst", ..., "Tomorrow Night Bright", and "Twilight".
      i Or provide a URL or file path to a '.tmTheme' file.

# theme_path errors for missing file

    Code
      theme_path("/nonexistent/theme.tmTheme")
    Condition
      Error in `theme_path()`:
      ! Theme file '/nonexistent/theme.tmTheme' not found.

