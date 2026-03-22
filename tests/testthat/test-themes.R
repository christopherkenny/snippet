test_that('snippet_themes returns named character vector', {
  themes <- snippet_themes()
  expect_type(themes, 'character')
  expect_named(themes)
  expect_match(themes, '\\.tmTheme$')
})

test_that('snippet_themes names have no hyphens or file extensions', {
  nms <- names(snippet_themes())
  expect_false(any(grepl('-', nms)))
  expect_false(any(grepl('\\.tmTheme', nms)))
})

test_that('snippet_themes includes themes from cache dir', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(snippet_cache_dir = \() tmp)
  theme <- unname(snippet_themes()[[1]])
  fs::file_copy(theme, fs::path(tmp, 'Test-Cache.tmTheme'))
  expect_true('Test Cache' %in% names(snippet_themes()))
})

test_that('snippet_known_themes returns named character vector of URLs', {
  known <- snippet_known_themes()
  expect_type(known, 'character')
  expect_named(known)
  expect_match(known, '^https?://')
})

test_that('snippet_install_theme copies a local file to cache', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(snippet_cache_dir = \() tmp)
  theme <- unname(snippet_themes()[[1]])
  dest <- snippet_install_theme(theme)
  expect_true(fs::file_exists(dest))
  expect_match(dest, '\\.tmTheme$')
})

test_that('snippet_install_theme skips if already installed and overwrite = FALSE', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(snippet_cache_dir = \() tmp)
  theme <- unname(snippet_themes()[[1]])
  snippet_install_theme(theme)
  expect_snapshot(snippet_install_theme(theme))
})

test_that('snippet_install_theme reinstalls when overwrite = TRUE', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(snippet_cache_dir = \() tmp)
  theme <- unname(snippet_themes()[[1]])
  snippet_install_theme(theme)
  dest <- snippet_install_theme(theme, overwrite = TRUE)
  expect_true(fs::file_exists(dest))
})

test_that('snippet_install_theme downloads known theme by name', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(
    snippet_cache_dir = \() tmp,
    download_theme = \(url, dest, overwrite) {
      file.create(dest)
      invisible(as.character(dest))
    }
  )
  dest <- snippet_install_theme('Dracula')
  expect_match(dest, 'Dracula\\.tmTheme$')
})

test_that('snippet_install_theme downloads from a URL', {
  tmp <- tempfile()
  dir.create(tmp)
  local_mocked_bindings(
    snippet_cache_dir = \() tmp,
    download_theme = \(url, dest, overwrite) {
      file.create(dest)
      invisible(as.character(dest))
    }
  )
  dest <- snippet_install_theme('https://example.com/my-theme.tmTheme')
  expect_match(dest, 'my-theme\\.tmTheme$')
})

test_that('snippet_install_theme errors for URL without .tmTheme extension', {
  expect_snapshot(
    error = TRUE,
    snippet_install_theme('https://example.com/theme.json')
  )
})

test_that('snippet_install_theme errors for local file without .tmTheme extension', {
  tmp <- tempfile(fileext = '.json')
  file.create(tmp)
  expect_snapshot(error = TRUE, snippet_install_theme(tmp))
})

test_that('snippet_install_theme errors for unknown theme name', {
  expect_snapshot(error = TRUE, snippet_install_theme('Unknown Theme XYZ'))
})

test_that('theme_path returns auto unchanged', {
  expect_equal(theme_path('auto'), 'auto')
})

test_that('theme_path returns none unchanged', {
  expect_equal(theme_path('none'), 'none')
})

test_that('theme_path errors for missing file', {
  expect_snapshot(error = TRUE, theme_path('/nonexistent/theme.tmTheme'))
})

test_that('theme_path returns quoted absolute path', {
  theme <- unname(snippet_themes()[[1]])
  dir <- tempdir()
  result <- theme_path(theme, dir)
  expect_match(result, '^\\".*\\.tmTheme\\"$')
  expect_match(result, normalizePath(theme, winslash = '/', mustWork = TRUE), fixed = TRUE)
})

test_that('theme_path handles repeated calls without error', {
  theme <- unname(snippet_themes()[[1]])
  dir <- tempdir()
  theme_path(theme, dir)
  expect_no_error(theme_path(theme, dir))
})

test_that('resolve_theme maps known theme names to installed paths', {
  resolved <- resolve_theme('Flexoki Dark')
  expect_match(resolved, '\\.tmTheme$')
  expect_true(fs::file_exists(resolved))
})

test_that('resolve_theme leaves custom values unchanged', {
  expect_equal(resolve_theme('auto'), 'auto')
  expect_equal(resolve_theme('custom-theme.tmTheme'), 'custom-theme.tmTheme')
})
