# Message send, history, and sync

#' Send a message to a room
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param body Character. The message body.
#' @param msgtype Character. Matrix msgtype, default "m.text".
#' @param extra List or NULL. Extra fields merged into the event content
#'   (e.g. formatted body, reply relation).
#'
#' @return The event ID of the sent message.
#' @export
mx_send <- function(
    session,
    room_id,
    body,
    msgtype = "m.text",
    extra = NULL
) {
  stop("not implemented")
}

#' Fetch historical messages from a room
#'
#' Thin wrapper over the /rooms/{id}/messages endpoint.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param from Character or NULL. Pagination token; NULL starts at the
#'   most recent message.
#' @param dir Character. "b" (backwards, default) or "f" (forwards).
#' @param limit Integer. Maximum events to return.
#'
#' @return A list with fields chunk, start, end.
#' @export
mx_messages <- function(
    session,
    room_id,
    from = NULL,
    dir = "b",
    limit = 50L
) {
  stop("not implemented")
}

#' One-shot sync against the homeserver
#'
#' Calls /sync once and returns immediately. For streaming behaviour,
#' the caller writes its own loop, passing the previous batch's
#' next_batch token as \code{since}.
#'
#' @param session An "mx_session" object.
#' @param since Character or NULL. Sync token from a prior sync.
#' @param timeout Integer. Long-poll timeout in milliseconds (0 returns
#'   immediately).
#' @param filter Character or NULL. Filter ID or inline JSON filter.
#'
#' @return The parsed sync response, including next_batch.
#' @export
mx_sync <- function(
    session,
    since = NULL,
    timeout = 0L,
    filter = NULL
) {
  stop("not implemented")
}
