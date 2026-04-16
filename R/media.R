# Media upload and download

#' Upload a file to the homeserver media repository
#'
#' @param session An "mx_session" object.
#' @param path Character. Local file path.
#' @param content_type Character or NULL. MIME type; guessed from the
#'   file extension if NULL.
#' @param filename Character or NULL. Filename advertised to the server.
#'
#' @return An "mxc://" URI as a character string.
#' @export
mx_upload <- function(session, path, content_type = NULL, filename = NULL) {
    stop("not implemented")
}

#' Download a media file by mxc URI
#'
#' @param session An "mx_session" object.
#' @param mxc_url Character. An "mxc://server/id" URI.
#' @param dest Character. Destination file path.
#'
#' @return The destination path, invisibly.
#' @export
mx_download <- function(session, mxc_url, dest) {
    stop("not implemented")
}

