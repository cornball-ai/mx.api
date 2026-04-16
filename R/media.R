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
    if (!file.exists(path)) {
        stop(sprintf("File not found: %s", path), call. = FALSE)
    }
    if (is.null(content_type)) {
        content_type <- mx_guess_mime(path)
    }
    if (is.null(filename)) {
        filename <- basename(path)
    }

    url <- paste0(
                  sub("/$", "", session$server),
                  "/_matrix/media/v3/upload?filename=",
                  utils::URLencode(filename, reserved = TRUE)
    )

    payload <- readBin(path, "raw", n = file.info(path)$size)

    h <- curl::new_handle()
    curl::handle_setopt(h, customrequest = "POST", postfields = payload)
    curl::handle_setheaders(
                            h,
                            Authorization = paste("Bearer", session$token),
                            `Content-Type` = content_type,
                            Accept = "application/json"
    )
    resp <- curl::curl_fetch_memory(url, handle = h)
    parsed <- jsonlite::fromJSON(rawToChar(resp$content),
                                 simplifyVector = FALSE)

    if (resp$status_code >= 400) {
        errcode <- parsed$errcode %||% "HTTP"
        msg <- parsed$error %||% paste("HTTP", resp$status_code)
        stop(sprintf("Matrix error [%s]: %s", errcode, msg), call. = FALSE)
    }

    parsed$content_uri
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
    m <- regmatches(mxc_url, regexec("^mxc://([^/]+)/(.+)$", mxc_url))[[1]]
    if (length(m) != 3L) {
        stop(sprintf("Not an mxc URI: %s", mxc_url), call. = FALSE)
    }
    server_name <- m[2]
    media_id <- m[3]

    url <- paste0(
                  sub("/$", "", session$server),
                  "/_matrix/client/v1/media/download/",
                  utils::URLencode(server_name, reserved = TRUE), "/",
                  utils::URLencode(media_id, reserved = TRUE)
    )

    h <- curl::new_handle()
    curl::handle_setheaders(h, Authorization = paste("Bearer", session$token))
    curl::curl_download(url, dest, handle = h)
    invisible(dest)
}

mx_guess_mime <- function(path) {
    ext <- tolower(tools::file_ext(path))
    table <- c(
               txt = "text/plain", md = "text/markdown", csv = "text/csv",
               json = "application/json", pdf = "application/pdf",
               html = "text/html", xml = "application/xml",
               png = "image/png", jpg = "image/jpeg", jpeg = "image/jpeg",
               gif = "image/gif", webp = "image/webp", svg = "image/svg+xml",
               mp3 = "audio/mpeg", wav = "audio/wav", ogg = "audio/ogg",
               mp4 = "video/mp4", webm = "video/webm", mov = "video/quicktime",
               zip = "application/zip", gz = "application/gzip",
               tar = "application/x-tar"
    )
    unname(table[ext] %||% "application/octet-stream")
}

