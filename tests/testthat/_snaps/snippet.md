# snippet errors for non-character code

    Code
      snippet(123L, lang = "r")
    Condition
      Error in `snippet()`:
      ! Input must be a character vector or a path to a text file.

# snippet errors for missing theme file

    Code
      snippet("x <- 1", lang = "r", theme = "/nonexistent/theme.tmTheme")
    Condition
      Error in `path_to_connection()`:
      ! '/nonexistent/theme.tmTheme' does not exist.

