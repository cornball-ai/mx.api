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
#' @examples
#' \dontrun{
#' uri <- mx_upload(s, "photo.png")
#' }
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

    url <- paste0(sub("/$", "", session$server),
                  "/_matrix/media/v3/upload?filename=",
                  utils::URLencode(filename, reserved = TRUE))

    # Stream from disk rather than reading the whole file into RAM:
    # upload mode + a readfunction lets curl pull chunks as it sends,
    # which keeps multi-GB videos out of memory. customrequest keeps
    # the method POST (upload mode alone would PUT).
    con <- file(path, "rb")
    on.exit(close(con), add = TRUE)

    h <- curl::new_handle()
    curl::handle_setopt(
                        h,
                        upload = TRUE,
                        customrequest = "POST",
                        readfunction = function(n) readBin(con, "raw", n),
                        infilesize_large = file.size(path)
    )
    curl::handle_setheaders(
                            h,
                            Authorization = paste("Bearer", session$token),
                            `Content-Type` = content_type,
                            Accept = "application/json"
    )
    resp <- curl::curl_fetch_memory(url, handle = h)
    # A proxy or misconfigured server can answer non-JSON (HTML, plain
    # text); don't let the parse error mask the real failure -- fall
    # through to mx_raise with whatever body came back.
    parsed <- tryCatch(
                       jsonlite::fromJSON(rawToChar(resp$content), simplifyVector = FALSE),
                       error = function(e) list(raw = rawToChar(resp$content))
    )

    if (resp$status_code >= 400) {
        mx_raise(parsed$errcode %||% "HTTP",
                 parsed$error %||% paste("HTTP", resp$status_code),
                 status = resp$status_code, body = parsed)
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
#' @examples
#' \dontrun{
#' mx_download(s, "mxc://matrix.example/abc123", tempfile())
#' }
#' @export
mx_download <- function(session, mxc_url, dest) {
    m <- regmatches(mxc_url, regexec("^mxc://([^/]+)/(.+)$", mxc_url))[[1]]
    if (length(m) != 3L) {
        stop(sprintf("Not an mxc URI: %s", mxc_url), call. = FALSE)
    }
    server_name <- m[2]
    media_id <- m[3]

    url <- paste0(sub("/$", "", session$server),
                  "/_matrix/client/v1/media/download/",
                  utils::URLencode(server_name, reserved = TRUE), "/",
                  utils::URLencode(media_id, reserved = TRUE))

    h <- curl::new_handle()
    curl::handle_setheaders(h, Authorization = paste("Bearer", session$token))
    curl::curl_download(url, dest, handle = h)
    invisible(dest)
}

#' Guess a MIME type from a file extension
#'
#' The extension table mx.api uses for uploads, exported so callers do
#' not maintain their own. Unknown extensions fall back to
#' \code{"application/octet-stream"}.
#'
#' @param path Character. File path or name.
#' @return Character MIME type.
#' @examples
#' mx_guess_mime("clip.mp4")
#' mx_guess_mime("notes.txt")
#' @export
mx_guess_mime <- function(path) {
    ext <- tolower(tools::file_ext(path))
    table <- c(txt = "text/plain", md = "text/markdown", csv = "text/csv",
               json = "application/json", pdf = "application/pdf",
               html = "text/html", xml = "application/xml",
               png = "image/png", jpg = "image/jpeg", jpeg = "image/jpeg",
               gif = "image/gif", webp = "image/webp", svg = "image/svg+xml",
               mp3 = "audio/mpeg", wav = "audio/wav", ogg = "audio/ogg",
               mp4 = "video/mp4", webm = "video/webm",
               mov = "video/quicktime", zip = "application/zip",
               gz = "application/gzip", tar = "application/x-tar")
    hit <- unname(table[ext])
    # A named-vector miss is NA, not NULL, so %||% alone won't catch it.
    if (length(hit) != 1L || is.na(hit)) {
        return("application/octet-stream")
    }
    hit
}

#' Send a media file to a room
#'
#' Uploads \code{path} to the media repository and posts an
#' \code{m.room.message} referencing it. The default \code{info} carries
#' \code{mimetype} and \code{size}; pass richer metadata (width, height,
#' duration) yourself -- mx.api deliberately does not inspect media files.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param path Character. Path to the file to upload.
#' @param body Character. Message body / filename shown by clients.
#' @param msgtype Character or NULL. One of \code{"m.file"},
#'   \code{"m.image"}, \code{"m.audio"}, \code{"m.video"}. NULL (the
#'   default) derives it from the MIME type, so a .mp4 posts as m.video
#'   without being told.
#' @param content_type Character or NULL. MIME type (guessed from the
#'   extension when NULL).
#' @param info List. Extra fields merged into the \code{info} object.
#' @return The event ID of the sent message.
#' @examples
#' \dontrun{
#' mx_send_media(s, "!abc:example", "clip.mp4", msgtype = "m.video")
#' }
#' @export
mx_send_media <- function(session, room_id, path, body = basename(path),
                          msgtype = NULL, content_type = NULL, info = list()) {
    if (is.null(content_type)) {
        content_type <- mx_guess_mime(path)
    }
    if (is.null(msgtype)) {
        msgtype <- mx_msgtype_for_mime(content_type)
    }
    uri <- mx_upload(session, path, content_type = content_type,
                     filename = basename(path))
    base_info <- list(mimetype = content_type, size = file.size(path))
    if (length(info)) {
        base_info <- utils::modifyList(base_info, info)
    }
    mx_send(session, room_id, body, msgtype = msgtype,
            extra = list(url = uri, info = base_info))
}

#' @rdname mx_send_media
#' @export
mx_send_file <- function(session, room_id, path, body = basename(path),
                         content_type = NULL, info = list()) {
    mx_send_media(session, room_id, path, body = body, msgtype = "m.file",
                  content_type = content_type, info = info)
}

#' @rdname mx_send_media
#' @export
mx_send_image <- function(session, room_id, path, body = basename(path),
                          content_type = NULL, info = list()) {
    mx_send_media(session, room_id, path, body = body, msgtype = "m.image",
                  content_type = content_type, info = info)
}

#' @rdname mx_send_media
#' @export
mx_send_audio <- function(session, room_id, path, body = basename(path),
                          content_type = NULL, info = list()) {
    mx_send_media(session, room_id, path, body = body, msgtype = "m.audio",
                  content_type = content_type, info = info)
}

#' @rdname mx_send_media
#' @export
mx_send_video <- function(session, room_id, path, body = basename(path),
                          content_type = NULL, info = list()) {
    mx_send_media(session, room_id, path, body = body, msgtype = "m.video",
                  content_type = content_type, info = info)
}

# m.image / m.audio / m.video from the MIME family; m.file otherwise.
mx_msgtype_for_mime <- function(content_type) {
    if (startsWith(content_type, "image/")) {
        return("m.image")
    }
    if (startsWith(content_type, "audio/")) {
        return("m.audio")
    }
    if (startsWith(content_type, "video/")) {
        return("m.video")
    }
    "m.file"
}

#' Query the homeserver's media configuration
#'
#' Asks the server for its media limits, chiefly \code{m.upload.size}
#' (maximum upload bytes), so callers can check a file fits before
#' uploading. Tries the v1 endpoint and falls back to the legacy
#' location for older homeservers.
#'
#' @param session An "mx_session" object.
#' @return A list; \code{$`m.upload.size`} is the upload cap in bytes
#'   (may be absent if the server does not advertise one).
#' @examples
#' \dontrun{
#' cap <- mx_media_config(s)$`m.upload.size`
#' file.size("clip.mp4") <= cap
#' }
#' @export
mx_media_config <- function(session) {
    tryCatch(
             mx_http(session$server, "GET", "/_matrix/client/v1/media/config",
                     token = session$token),
             error = function(e) {
        mx_http(session$server, "GET", "/_matrix/media/v3/config",
                token = session$token)
    }
    )
}
