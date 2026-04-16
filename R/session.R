# Auth and session handling

#' Log in to a Matrix homeserver
#'
#' Authenticates with a Matrix homeserver using password login and returns
#' a session object carrying the access token and device id.
#'
#' @param server Character. Homeserver base URL (e.g. "https://matrix.example").
#' @param user Character. User localpart or full Matrix ID.
#' @param password Character. Account password.
#' @param device_id Character or NULL. Reuse an existing device id.
#'
#' @return An object of class "mx_session".
#' @export
mx_login <- function(server, user, password, device_id = NULL) {
    identifier <- if (grepl("^@", user)) {
        list(type = "m.id.user", user = sub("^@", "", sub(":.*$", "", user)))
    } else {
        list(type = "m.id.user", user = user)
    }
    body <- list(
                 type = "m.login.password",
                 identifier = identifier,
                 password = password
    )
    if (!is.null(device_id)) {
        body$device_id <- device_id
    }

    resp <- mx_http(server, "POST", "/_matrix/client/v3/login", body = body)
    mx_session(
               server = server,
               token = resp$access_token,
               user_id = resp$user_id,
               device_id = resp$device_id
    )
}

#' Reconstruct a session from saved credentials
#'
#' @param server Character. Homeserver base URL.
#' @param token Character. Access token from a prior login.
#' @param user_id Character. Full Matrix ID (e.g. "@troy:example.org").
#' @param device_id Character. Device id from the prior login.
#'
#' @return An object of class "mx_session".
#' @export
mx_session <- function(server, token, user_id, device_id) {
    structure(
              list(
                   server = sub("/$", "", server),
                   token = token,
                   user_id = user_id,
                   device_id = device_id
        ),
              class = "mx_session"
    )
}

#' Log out of a Matrix session
#'
#' Invalidates the access token on the homeserver.
#'
#' @param session An "mx_session" object.
#'
#' @return Invisible NULL.
#' @export
mx_logout <- function(session) {
    mx_http(
            session$server, "POST", "/_matrix/client/v3/logout",
            body = list(), token = session$token
    )
    invisible(NULL)
}

#' Return the identity of the current session
#'
#' @param session An "mx_session" object.
#'
#' @return A list with user_id and device_id.
#' @export
mx_whoami <- function(session) {
    resp <- mx_http(
                    session$server, "GET", "/_matrix/client/v3/account/whoami",
                    token = session$token
    )
    list(user_id = resp$user_id, device_id = resp$device_id)
}

