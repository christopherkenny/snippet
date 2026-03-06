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
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  snippet('x <- 1', width = 8, output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(fs::path(tempdir(), 'snippet.typ'))
  expect_match(typ, '8in')
})

test_that('snippet enables line numbers in template', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  snippet('x <- 1', line_numbers = TRUE, output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(fs::path(tempdir(), 'snippet.typ'))
  expect_match(typ, 'numbering: "1"')
})

test_that('snippet disables line numbers by default', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  snippet('x <- 1', output_file = tempfile(fileext = '.png'))
  typ <- readr::read_file(fs::path(tempdir(), 'snippet.typ'))
  expect_match(typ, 'numbering: none')
})

test_that('snippet warns when clip = TRUE and format is not png', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  expect_snapshot({
    snippet('x <- 1', format = 'pdf', clip = TRUE, output_file = tempfile(fileext = '.pdf'))
  })
})

test_that('snippet calls copy_image_to_clipboard when clip = TRUE', {
  local_mocked_bindings(
    typr_compile = \(input, output_file, output_format) output_file,
    copy_image_to_clipboard = \(path) path
  )
  expect_no_error(snippet('x <- 1', format = 'png', clip = TRUE, output_file = tempfile(fileext = '.png')))
})

test_that('snippet writes code to snippet-code.txt', {
  local_mocked_bindings(typr_compile = \(input, output_file, output_format) output_file)
  snippet('my_code <- 42', lang = 'r', output_file = tempfile(fileext = '.png'))
  code_file <- fs::path(tempdir(), 'snippet-code.txt')
  expect_true(fs::file_exists(code_file))
  expect_equal(readr::read_file(code_file), 'my_code <- 42')
})
