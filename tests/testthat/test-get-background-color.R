test_that('get_background_color extracts hex color from Flexoki Dark', {
  theme <- unname(snippet_themes()[['Flexoki Dark']])
  bg <- get_background_color(theme)
  expect_type(bg, 'character')
  expect_match(bg, '^#[0-9A-Fa-f]{6}')
})

test_that('get_background_color extracts hex color from Flexoki Light', {
  theme <- unname(snippet_themes()[['Flexoki Light']])
  bg <- get_background_color(theme)
  expect_type(bg, 'character')
  expect_match(bg, '^#[0-9A-Fa-f]{6}')
})

test_that('get_foreground_color extracts hex color from Flexoki Dark', {
  theme <- unname(snippet_themes()[['Flexoki Dark']])
  fg <- get_foreground_color(theme)
  expect_type(fg, 'character')
  expect_match(fg, '^#[0-9A-Fa-f]{6}')
})

test_that('get_foreground_color returns NULL for theme without foreground', {
  tmp <- tempfile(fileext = '.tmTheme')
  xml2::write_xml(
    xml2::read_xml(
      '<plist><dict><key>settings</key><array>
        <dict><key>settings</key><dict></dict></dict>
      </array></dict></plist>'
    ),
    tmp
  )
  expect_null(get_foreground_color(tmp))
})

test_that('get_background_color returns NULL for theme without background', {
  tmp <- tempfile(fileext = '.tmTheme')
  xml2::write_xml(
    xml2::read_xml(
      '<plist><dict><key>settings</key><array>
        <dict><key>settings</key><dict></dict></dict>
      </array></dict></plist>'
    ),
    tmp
  )
  expect_null(get_background_color(tmp))
})
