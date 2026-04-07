copy_image_to_clipboard <- function(path) {
  if (!fs::file_exists(path)) {
    cli::cli_abort('Cannot copy missing file to clipboard: {.path {path}}.')
  }

  sysname <- Sys.info()[['sysname']]
  if (sysname == 'Darwin') {
    copy_image_to_clipboard_macos(path)
  } else if (sysname == 'Windows') {
    copy_image_to_clipboard_windows(path)
  } else {
    copy_image_to_clipboard_linux(path)
  }
  invisible(path)
}

run_clipboard_command <- function(command, args, failure_message) {
  status <- suppressWarnings(
    system2(command, args = args, stdout = NULL, stderr = NULL)
  )

  if (!identical(status, 0L)) {
    cli::cli_warn(failure_message)
  }

  invisible(status)
}

copy_image_to_clipboard_macos <- function(path) {
  escaped_path <- gsub('"', '\\"', normalizePath(path, winslash = '/', mustWork = TRUE), fixed = TRUE)
  run_clipboard_command(
    'osascript',
    c('-e', sprintf(
      'set the clipboard to (read (POSIX file "%s") as \u00abclass PNGf\u00bb)',
      escaped_path
    )),
    'Could not copy image to clipboard via {.cmd osascript}.'
  )
}

copy_image_to_clipboard_windows <- function(path) {
  escaped_path <- gsub("'", "''", normalizePath(path, winslash = '\\', mustWork = TRUE), fixed = TRUE)
  ps_cmd <- paste0(
    'Add-Type -AssemblyName System.Windows.Forms; ',
    'Add-Type -AssemblyName System.Drawing; ',
    "$img = [System.Drawing.Image]::FromFile('", escaped_path, "'); ",
    '[System.Windows.Forms.Clipboard]::SetImage($img); ',
    '$img.Dispose()'
  )

  run_clipboard_command(
    'powershell',
    c('-NoProfile', '-Command', ps_cmd),
    'Could not copy image to clipboard via PowerShell.'
  )
}

copy_image_to_clipboard_linux <- function(path) {
  linux_clipboards <- list(
    c('wl-copy', '--type', 'image/png'),
    c('xclip', '-selection', 'clipboard', '-t', 'image/png', '-i'),
    c('xsel', '--clipboard', '--input')
  )

  for (cmd in linux_clipboards) {
    bin <- cmd[[1]]
    if (!nzchar(Sys.which(bin))) {
      next
    }

    status <- suppressWarnings(
      system2(bin,
        args = c(cmd[-1], normalizePath(path, winslash = '/', mustWork = TRUE)),
        stdout = NULL, stderr = NULL
      )
    )
    if (identical(status, 0L)) {
      return(invisible(status))
    }
  }

  cli::cli_warn(
    'Could not copy image to clipboard: install one of {.cmd wl-copy}, {.cmd xclip}, or {.cmd xsel}.'
  )
  invisible(1L)
}
