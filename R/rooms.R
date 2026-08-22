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
#' @param creation_content Named list or NULL. Merged into the
#'   \code{m.room.create} event content. This is the only way to set
#'   properties that are fixed at creation and immutable afterwards --
#'   notably \code{type = "m.space"}, which makes the room a space rather
#'   than a conversation. A space cannot be converted from an ordinary
#'   room later, so it has to be requested here or not at all.
#'
#' @return The new room ID as a character string.
#' @examples
#' \dontrun{
#' room_id <- mx_room_create(s, name = "test", topic = "hello")
#'
#' # A space, which holds other rooms instead of messages
#' space_id <- mx_room_create(s, name = "Topics",
#'                            creation_content = list(type = "m.space"))
#' }
#' @export
mx_room_create <- function(session, name = NULL, topic = NULL,
                           visibility = "private", preset = NULL,
                           invite = character(), creation_content = NULL) {
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
    if (length(creation_content)) {
        if (!is.list(creation_content) ||
            is.null(names(creation_content)) ||
            !all(nzchar(names(creation_content)))) {
            stop("creation_content must be a fully named list", call. = FALSE)
        }
        # Sent as an object even with one entry: unnamed or auto-unboxed
        # here would serialize to a bare string and the server would
        # reject the create rather than quietly making a normal room.
        body$creation_content <- creation_content
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


#' Invite a user to a room
#'
#' Invitation at creation time is covered by \code{mx_room_create()};
#' this covers the other common lifecycle case, inviting into an
#' existing room.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param user_id Character. The Matrix ID to invite.
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' mx_room_invite(s, "!abc:example", "@friend:example.org")
#' }
#' @export
mx_room_invite <- function(session, room_id, user_id) {
    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/invite",
                    mx_encode_id(room_id)
    )
    mx_http(session$server, "POST", path,
            body = list(user_id = user_id), token = session$token)
    invisible(TRUE)
}
