# Room operations

#' List rooms the user has joined
#'
#' @param session An "mx_session" object.
#'
#' @return Character vector of room IDs.
#' @examples
#' \dontrun{
#' mx_rooms(s)
#' }
#' @export
mx_rooms <- function(session) {
    resp <- mx_http(
                    session$server, "GET", "/_matrix/client/v3/joined_rooms",
                    token = session$token
    )
    unlist(resp$joined_rooms, use.names = FALSE)
}

#' Create a room
#'
#' @param session An "mx_session" object.
#' @param name Character or NULL. Human-readable room name.
#' @param topic Character or NULL. Room topic.
#' @param visibility Character. "private" (default) or "public".
#' @param preset Character or NULL. A Matrix room preset
#'   ("private_chat", "trusted_private_chat", "public_chat").
#' @param invite Character vector. Matrix IDs to invite.
#'
#' @return The new room ID as a character string.
#' @examples
#' \dontrun{
#' room_id <- mx_room_create(s, name = "test", topic = "hello")
#' }
#' @export
mx_room_create <- function(session, name = NULL, topic = NULL,
                           visibility = "private", preset = NULL,
                           invite = character()) {
    body <- list(visibility = visibility)
    if (!is.null(name)) {
        body$name <- name
    }
    if (!is.null(topic)) {
        body$topic <- topic
    }
    if (!is.null(preset)) {
        body$preset <- preset
    }
    if (length(invite)) {
        body$invite <- as.list(invite)
    }

    resp <- mx_http(
                    session$server, "POST", "/_matrix/client/v3/createRoom",
                    body = body, token = session$token
    )
    resp$room_id
}

#' Join a room by ID or alias
#'
#' @param session An "mx_session" object.
#' @param room Character. Room ID (!abc:server) or alias (#name:server).
#'
#' @return The joined room ID.
#' @examples
#' \dontrun{
#' mx_room_join(s, "#general:matrix.example")
#' }
#' @export
mx_room_join <- function(session, room) {
    path <- sprintf("/_matrix/client/v3/join/%s", mx_encode_id(room))
    resp <- mx_http(
                    session$server, "POST", path,
                    body = mx_empty_body(), token = session$token
    )
    resp$room_id
}

#' Leave a room
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Invisible NULL.
#' @examples
#' \dontrun{
#' mx_room_leave(s, "!abc:matrix.example")
#' }
#' @export
mx_room_leave <- function(session, room_id) {
    path <- sprintf("/_matrix/client/v3/rooms/%s/leave", mx_encode_id(room_id))
    mx_http(session$server, "POST", path, body = mx_empty_body(),
            token = session$token)
    invisible(NULL)
}

#' List the members of a room
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Character vector of Matrix user IDs currently joined.
#' @examples
#' \dontrun{
#' mx_room_members(s, "!abc:matrix.example")
#' }
#' @export
mx_room_members <- function(session, room_id) {
    path <- sprintf("/_matrix/client/v3/rooms/%s/joined_members",
                    mx_encode_id(room_id))
    resp <- mx_http(session$server, "GET", path, token = session$token)
    names(resp$joined)
}

#' Get a room's human-readable name
#'
#' Reads the \code{m.room.name} state event. Returns NULL if the room
#' has no name set or the state event is inaccessible.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Character scalar or NULL.
#' @examples
#' \dontrun{
#' mx_room_name(s, "!abc:matrix.example")
#' }
#' @export
mx_room_name <- function(session, room_id) {
    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/state/m.room.name",
                    mx_encode_id(room_id)
    )
    resp <- tryCatch(
                     mx_http(session$server, "GET", path, token = session$token),
                     error = function(e) NULL
    )
    if (is.null(resp) || is.null(resp$name) || !nzchar(resp$name)) {
        return(NULL)
    }
    resp$name
}

#' Get a room's topic
#'
#' Reads the \code{m.room.topic} state event. Returns NULL if the room
#' has no topic set or the state event is inaccessible.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Character scalar or NULL.
#' @examples
#' \dontrun{
#' mx_room_topic(s, "!abc:matrix.example")
#' }
#' @export
mx_room_topic <- function(session, room_id) {
    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/state/m.room.topic",
                    mx_encode_id(room_id)
    )
    resp <- tryCatch(
                     mx_http(session$server, "GET", path, token = session$token),
                     error = function(e) NULL
    )
    if (is.null(resp) || is.null(resp$topic) || !nzchar(resp$topic)) {
        return(NULL)
    }
    resp$topic
}

