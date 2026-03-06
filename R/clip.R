copy_image_to_clipboard <- function(path) {
  sysname <- Sys.info()[['sysname']]
  if (sysname == 'Darwin') {
    system2(
      'osascript',
      c('-e', sprintf(
        'set the clipboard to (read (POSIX file "%s") as \u00abclass PNGf\u00bb)',
        normalizePath(path)
      ))
    )
  } else if (sysname == 'Windows') {
    ps_cmd <- sprintf(
      '[Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms"); [System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Image]::FromFile("%s"))',
      normalizePath(path, winslash = '\\')
    )
    system2('powershell', c('-Command', ps_cmd))
  } else {
    if (nzchar(Sys.which('xclip'))) {
      system2('xclip', c('-selection', 'clipboard', '-t', 'image/png', '-i', path))
    } else {
      cli::cli_warn('Could not copy image to clipboard: {.code xclip} not found.')
    }
  }
  invisible(path)
}
