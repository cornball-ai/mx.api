# Endpoints a MatrixRTC client needs: the OpenID token it trades for a
# media-server credential, the server's list of RTC transports, a room's
# full state (to find call memberships), and the client well-known file.

#' Request an OpenID token for this user
#'
#' An OpenID token lets a third-party service confirm this user's
#' identity with the homeserver (via the federation
#' \code{openid/userinfo} endpoint) without seeing the access token.
#' MatrixRTC clients hand it to the LiveKit JWT service in exchange for a
#' room-scoped media token.
#'
#' @param session An "mx_session" object.
#' @return A list with \code{access_token}, \code{token_type},
#'   \code{matrix_server_name} and \code{expires_in} (seconds), exactly as
#'   the server returned them: a relying party expects the object whole.
#' @examples
#' \dontrun{
#' tok <- mx_openid_token(s)
#' tok$matrix_server_name
#' }
#' @export
mx_openid_token <- function(session) {
    path <- sprintf("/_matrix/client/v3/user/%s/openid/request_token",
                    mx_encode_id(session$user_id))
    mx_http(session$server, "POST", path, body = mx_empty_body(),
            token = session$token)
}

#' List the homeserver's RTC transports
#'
#' Reads \code{GET /_matrix/client/unstable/org.matrix.msc4143/rtc/transports}
#' (MSC4143), where a homeserver advertises the media back ends its calls
#' use. For LiveKit each entry has \code{type} \code{"livekit"} and a
#' \code{livekit_service_url}, the JWT service that issues media tokens.
#'
#' @param session An "mx_session" object.
#' @return A list of transports, each a list, or an empty list when the
#'   server advertises none or does not implement the endpoint.
#' @examples
#' \dontrun{
#' urls <- vapply(mx_rtc_transports(s), `[[`, "", "livekit_service_url")
#' }
#' @export
mx_rtc_transports <- function(session) {
    resp <- tryCatch(
        mx_http(session$server, "GET",
                "/_matrix/client/unstable/org.matrix.msc4143/rtc/transports",
                token = session$token),
        mx_error_M_UNRECOGNIZED = function(e) NULL,
        mx_error_M_NOT_FOUND = function(e) NULL)
    resp$rtc_transports %||% list()
}

#' Exchange an OpenID token for a LiveKit media token
#'
#' Calls a LiveKit JWT service (\code{lk-jwt-service}) the way Element
#' Call and FluffyChat do: \code{POST <service_url>/sfu/get} with the
#' Matrix room, this user's OpenID token and device id. The service
#' verifies the token with the homeserver and answers with the SFU's
#' WebSocket URL and a room-scoped JWT whose LiveKit identity is
#' \code{"<user_id>:<device_id>"}.
#'
#' @param service_url Character. Base URL of the JWT service, from
#'   \code{\link{mx_rtc_transports}} or a call member's
#'   \code{foci_preferred}.
#' @param room_id Character. The Matrix room of the call.
#' @param openid_token The list returned by \code{\link{mx_openid_token}}.
#' @param device_id Character. This device's id.
#' @return A list with \code{url} (the LiveKit server) and \code{jwt}.
#' @examples
#' \dontrun{
#' tok <- mx_rtc_livekit_token("https://jwt.example", "!abc:example",
#'                             mx_openid_token(s), s$device_id)
#' tok$url
#' }
#' @export
mx_rtc_livekit_token <- function(service_url, room_id, openid_token,
                                 device_id) {
    resp <- mx_http(sub("/+$", "", service_url), "POST", "/sfu/get",
                    body = list(room = room_id, openid_token = openid_token,
                                device_id = device_id))
    if (!is.character(resp$url) || !is.character(resp$jwt)) {
        stop("the LiveKit JWT service at ", service_url,
             " did not return url and jwt", call. = FALSE)
    }
    list(url = resp$url, jwt = resp$jwt)
}

#' Get the full current state of a room
#'
#' Returns every current state event of a room, one list per event with
#' \code{type}, \code{state_key}, \code{sender}, \code{content},
#' \code{origin_server_ts} and \code{event_id}. Unlike
#' \code{\link{mx_get_state}} this covers all state keys of a type, which
#' is how per-device state such as call memberships is found.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @return A list of state events.
#' @examples
#' \dontrun{
#' state <- mx_room_state(s, "!abc:example")
#' Filter(function(ev) ev$type == "m.room.member", state)
#' }
#' @export
mx_room_state <- function(session, room_id) {
    path <- sprintf("/_matrix/client/v3/rooms/%s/state", mx_encode_id(room_id))
    resp <- mx_http(session$server, "GET", path, token = session$token)
    if (is.null(resp)) list() else resp
}

#' Read a server's client well-known file
#'
#' Fetches \code{https://<server_name>/.well-known/matrix/client}, the
#' discovery document that names the homeserver's base URL and, for some
#' deployments, its RTC foci (\code{org.matrix.msc4143.rtc_foci}).
#'
#' @param server_name Character. The server name part of a Matrix ID,
#'   e.g. \code{"example.org"}, or a URL whose host is used.
#' @return The parsed document as a list, or NULL when there is none.
#' @examples
#' \dontrun{
#' mx_well_known_client("example.org")$`m.homeserver`$base_url
#' }
#' @export
mx_well_known_client <- function(server_name) {
    host <- sub("^[a-z]+://", "", server_name)
    host <- sub("/.*$", "", host)
    tryCatch(
        mx_http(paste0("https://", host), "GET", "/.well-known/matrix/client"),
        mx_error = function(e) NULL,
        error = function(e) NULL)
}
