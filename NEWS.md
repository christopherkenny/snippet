# snippet 0.0.1

* `snippet()` renders typeset code snippets using Typst with syntax highlighting. Key arguments include:
  * `lang`: defaults to `'r'` when no language can be inferred.
  * `line_numbers`: displays line numbers in the code block.
  * `width`: controls the output width in inches (default `5`).
* `snippet()` accepts theme names returned by `snippet_themes()` directly, so bundled and installed themes can be passed by name rather than file path.
* `snippet_install_theme()` installs themes from a URL, file path, or by name from a curated list of popular themes. Installed themes are stored in the user's cache directory and discovered automatically by `snippet_themes()`.
* `snippet_known_themes()` lists curated themes available for installation by name via `snippet_install_theme()`.
* `snippet_themes()` returns a named character vector where names are human-readable (e.g., `"Flexoki Dark"`). It includes both bundled themes and any themes installed via `snippet_install_theme()`.
