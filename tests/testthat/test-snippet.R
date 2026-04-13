test_that('snippet errors for non-character code', {
  expect_snapshot(error = TRUE, snippet(123L, lang = 'r'))
})

test_that('snippet defaults lang to r', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  out <- snippet('x <- 1', output_file = tempfile(fileext = '.png'))
  expect_type(out, 'character')
})

test_that('snippet handles code with double quotes', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  out <- snippet('x <- "hello"', lang = 'r', output_file = tempfile(fileext = '.png'))
  expect_type(out, 'character')
})

test_that('snippet handles code with glue-like patterns', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  out <- snippet('f"{{value}}"', lang = 'python', output_file = tempfile(fileext = '.png'))
  expect_type(out, 'character')
})

test_that('snippet errors for missing theme file', {
  expect_snapshot(error = TRUE, {
    snippet('x <- 1', lang = 'r', theme = '/nonexistent/theme.tmTheme')
  })
})

test_that('snippet passes width to template', {
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )
  snippet('x <- 1', width = 8, output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(captured_path)
  expect_match(typ, '8in')
})

test_that('snippet enables line numbers in template', {
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )
  snippet('x <- 1', line_numbers = TRUE, output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(captured_path)
  expect_match(typ, 'line-numbers = true', fixed = TRUE)
})

test_that('snippet disables line numbers by default', {
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )
  snippet('x <- 1', output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(captured_path)
  expect_match(typ, 'line-numbers = false', fixed = TRUE)
})

test_that('snippet writes code inline into the typst source', {
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )
  snippet('my_code <- 42', lang = 'r', output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(captured_path)
  expect_match(typ, 'my_code <- 42', fixed = TRUE)
})

test_that('snippet escapes title and language strings for Typst', {
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )

  snippet(
    'x <- 1',
    lang = 'py"thon',
    title = 'bad " title',
    output_file = tempfile(fileext = '.png')
  )

  typ <- readr::read_file(captured_path)
  expect_match(typ, 'title: "bad \\" title"', fixed = TRUE)
  expect_match(typ, 'raw(lang: "py\\"thon"', fixed = TRUE)
})

test_that('snippet resolves installed theme names', {
  theme <- snippet_themes()[['Flexoki Dark']]
  captured_path <- tempfile(fileext = '.typ')
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) {
      fs::file_copy(input, captured_path, overwrite = TRUE)
      output_file
    }
  )

  snippet('x <- 1', theme = 'Flexoki Dark', output_file = tempfile(fileext = '.png'))

  typ <- readr::read_file(captured_path)
  expect_match(typ, fs::path_file(theme), fixed = TRUE)
})
