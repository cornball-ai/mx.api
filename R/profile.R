# User profile: displayname and avatar.

#' Get a user's profile
#'
#' @param session An "mx_session" object.
#' @param user_id Character. Defaults to the session's own user.
#' @return A list with \code{displayname} and \code{avatar_url} (either
#'   may be absent when unset).
#' @examples
#' \dontrun{
#' mx_profile(s)$displayname
#' }
#' @export
mx_profile <- function(session, user_id = session$user_id) {
    path <- sprintf("/_matrix/client/v3/profile/%s", mx_encode_id(user_id))
    mx_http(session$server, "GET", path, token = session$token)
}

#' Set this user's display name
#'
#' @param session An "mx_session" object.
#' @param displayname Character. The new display name.
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' mx_set_displayname(s, "cornelius")
#' }
#' @export
mx_set_displayname <- function(session, displayname) {
    path <- sprintf(
                    "/_matrix/client/v3/profile/%s/displayname",
                    mx_encode_id(session$user_id)
    )
    mx_http(session$server, "PUT", path,
            body = list(displayname = displayname), token = session$token)
    invisible(TRUE)
}

#' Set this user's avatar
#'
#' @param session An "mx_session" object.
#' @param avatar_url Character. An \code{mxc://} URI, typically from
#'   \code{\link{mx_upload}}.
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' uri <- mx_upload(s, "avatar.png")
#' mx_set_avatar_url(s, uri)
#' }
#' @export
mx_set_avatar_url <- function(session, avatar_url) {
    path <- sprintf(
                    "/_matrix/client/v3/profile/%s/avatar_url",
                    mx_encode_id(session$user_id)
    )
    mx_http(session$server, "PUT", path,
            body = list(avatar_url = avatar_url), token = session$token)
    invisible(TRUE)
}
