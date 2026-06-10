# Account data: per-user key-value storage on the homeserver.

#' Get account data
#'
#' Reads a global account-data event for a user, e.g. \code{"m.direct"}
#' (the DM room map) or any custom namespaced type.
#'
#' @param session An "mx_session" object.
#' @param type Character. Event type, e.g. \code{"m.direct"}.
#' @param user_id Character. Defaults to the session's own user.
#' @return The account-data content as a list, or NULL when the type has
#'   never been set.
#' @examples
#' \dontrun{
#' direct <- mx_get_account_data(s, "m.direct")
#' }
#' @export
mx_get_account_data <- function(session, type, user_id = session$user_id) {
    path <- sprintf(
                    "/_matrix/client/v3/user/%s/account_data/%s",
                    mx_encode_id(user_id), mx_encode_id(type)
    )
    tryCatch(
             mx_http(session$server, "GET", path, token = session$token),
             mx_error_M_NOT_FOUND = function(e) NULL
    )
}

#' Set account data
#'
#' Writes a global account-data event for a user. The content replaces
#' whatever was stored under \code{type}.
#'
#' @param session An "mx_session" object.
#' @param type Character. Event type, e.g. \code{"m.direct"}.
#' @param content List. The content, sent as-is.
#' @param user_id Character. Defaults to the session's own user.
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' mx_set_account_data(s, "ai.cornball.notes", list(theme = "dark"))
#' }
#' @export
mx_set_account_data <- function(session, type, content,
                                user_id = session$user_id) {
    path <- sprintf(
                    "/_matrix/client/v3/user/%s/account_data/%s",
                    mx_encode_id(user_id), mx_encode_id(type)
    )
    mx_http(session$server, "PUT", path, body = content,
            token = session$token)
    invisible(TRUE)
}
