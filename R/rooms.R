# Room operations

#' List rooms the user has joined
#'
#' @param session An "mx_session" object.
#'
#' @return Character vector of room IDs.
#' @export
mx_rooms <- function(session) {
  stop("not implemented")
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
#' @export
mx_room_create <- function(
    session,
    name = NULL,
    topic = NULL,
    visibility = "private",
    preset = NULL,
    invite = character()
) {
  stop("not implemented")
}

#' Join a room by ID or alias
#'
#' @param session An "mx_session" object.
#' @param room Character. Room ID (!abc:server) or alias (#name:server).
#'
#' @return The joined room ID.
#' @export
mx_room_join <- function(session, room) {
  stop("not implemented")
}

#' Leave a room
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Invisible NULL.
#' @export
mx_room_leave <- function(session, room_id) {
  stop("not implemented")
}

#' List the members of a room
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#'
#' @return Character vector of Matrix user IDs.
#' @export
mx_room_members <- function(session, room_id) {
  stop("not implemented")
}
