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

# snippet warns when clip = TRUE and format is not png

    Code
      snippet("x <- 1", format = "pdf", clip = TRUE, output_file = tempfile(fileext = ".pdf"))
    Condition
      Warning:
      `clip` is only supported for PNG format. Skipping.

