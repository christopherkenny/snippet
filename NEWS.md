# snippet 0.0.1

* `convert_theme()` is a new exported function (previously internal `json_to_tmtheme()`) for converting VS Code JSON themes to tmTheme format.
* `snippet()` code containing double quotes or `{{`/`}}` patterns now renders correctly.
* `snippet()` now correctly applies the selected theme to syntax highlighting via `#set raw(theme: ...)` in the Typst template. Previously the theme was resolved but never passed to the renderer. The theme's foreground color is also applied via `#set text(fill: ...)` so dark themes no longer show black text.
* `snippet()` no longer errors for non-RStudio users. The `rstudioapi` dependency is now correctly listed under `Suggests`.
* `snippet()` now defaults `lang` to `'r'` when no language can be inferred, rather than erroring.
* `snippet()` gains a `clip` argument. When `TRUE`, it attempts to copy the rendered PNG to the system clipboard immediately after rendering.
* `snippet()` gains a `line_numbers` argument to display line numbers in the code block.
* `snippet()` removed the unused `output` parameter. Use `output_file` instead.
* `snippet()` gains a `width` argument to control the output width in inches (default `5`).
* `snippet()` now accepts theme names returned by `snippet_themes()` directly, so bundled and installed themes no longer need to be passed by file path.
* `snippet()` now escapes `title` and `lang` inputs safely, so quotes in those values no longer break rendering.
* `snippet_install_theme()` is a new function for installing themes from a URL, file path, or by name from a curated list of popular themes. Installed themes are stored in the user's cache directory and discovered automatically by `snippet_themes()`.
* `snippet_known_themes()` is a new function that lists curated themes available for installation by name via `snippet_install_theme()`.
* `snippet_themes()` now returns a named character vector where names are human-readable (e.g., `"Flexoki Dark"` instead of a file path). It also includes any themes installed via `snippet_install_theme()`.
