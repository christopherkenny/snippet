test_that('convert_theme produces valid plist XML', {
  skip_if_not_installed('jsonlite')

  json <- tempfile(fileext = '.json')
  output <- tempfile(fileext = '.tmTheme')

  writeLines(
    '{
      "name": "Test Theme",
      "colors": {
        "editor.background": "#1E1E1E",
        "editor.foreground": "#D4D4D4"
      },
      "tokenColors": []
    }',
    json
  )

  result <- convert_theme(json, output)
  expect_equal(result, output)
  expect_true(fs::file_exists(output))
  doc <- xml2::read_xml(output)
  expect_equal(xml2::xml_name(xml2::xml_root(doc)), 'plist')
})

test_that('convert_theme infers output path from json path', {
  skip_if_not_installed('jsonlite')

  dir <- tempdir()
  json <- fs::path(dir, 'My_Theme.json')

  writeLines(
    '{
      "colors": {},
      "tokenColors": []
    }',
    json
  )

  result <- convert_theme(json)
  expect_match(result, '\\.tmTheme$')
  expect_true(fs::file_exists(result))
})
