#' Return paths to themes included in the snippet package
#'
#' @returns A character vector of file paths to the themes
#' @export
#'
#' @examples
#' snippet_themes()
snippet_themes <- function() {
  fs::dir_ls(
    path = fs::path_package('snippet', 'tmTheme')
  )
}
