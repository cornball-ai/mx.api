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
#' @examples
#' \dontrun{
#' mx_send(s, "!abc:matrix.example", "hello world")
#' }
#' @export
mx_send <- function(session, room_id, body, msgtype = "m.text", extra = NULL) {
    content <- list(msgtype = msgtype, body = body)
    if (length(extra)) {
        content <- utils::modifyList(content, extra)
    }

    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/send/m.room.message/%s",
                    mx_encode_id(room_id), mx_encode_id(mx_txn_id())
    )
    resp <- mx_http(
                    session$server, "PUT", path,
                    body = content, token = session$token
    )
    resp$event_id
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
#' @examples
#' \dontrun{
#' mx_messages(s, "!abc:matrix.example", limit = 20L)
#' }
#' @export
mx_messages <- function(session, room_id, from = NULL, dir = "b", limit = 50L) {
    query <- list(dir = dir, limit = as.integer(limit))
    if (!is.null(from)) {
        query$from <- from
    }

    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/messages",
                    mx_encode_id(room_id)
    )
    mx_http(session$server, "GET", path, query = query, token = session$token)
}

#' Send a read receipt for a room event
#'
#' Public receipt (\code{m.read}) advances the "seen" marker in other
#' clients; private receipt (\code{m.read.private}) only advances the
#' bot's own view. Defaults to public so user clients show
#' "seen by @bot".
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_id Character. The event to mark as read.
#' @param receipt_type Character. "m.read" (default) or "m.read.private".
#'
#' @return Invisible NULL.
#' @examples
#' \dontrun{
#' mx_read_receipt(s, "!abc:matrix.example", "$eventid")
#' }
#' @export
mx_read_receipt <- function(session, room_id, event_id,
                            receipt_type = c("m.read", "m.read.private")) {
    receipt_type <- match.arg(receipt_type)
    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/receipt/%s/%s",
                    mx_encode_id(room_id),
                    mx_encode_id(receipt_type),
                    mx_encode_id(event_id)
    )
    mx_http(
            session$server, "POST", path,
            body = mx_empty_body(), token = session$token
    )
    invisible(NULL)
}

#' Send a reaction (annotation) to a room event
#'
#' Posts an m.reaction event tying \code{key} (usually a thumbs-up or
#' other emoji) to \code{event_id}. Matrix reactions are plain events
#' under the hood; they relate to the target via \code{m.annotation}.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_id Character. The event being reacted to.
#' @param key Character. The reaction key (usually an emoji).
#'
#' @return The event ID of the sent reaction.
#' @examples
#' \dontrun{
#' mx_react(s, "!abc:matrix.example", "$eventid", "thumbs-up")
#' }
#' @export
mx_react <- function(session, room_id, event_id, key) {
    content <- list(
                    `m.relates_to` = list(
            rel_type = "m.annotation",
            event_id = event_id,
            key = key
        )
    )
    path <- sprintf(
                    "/_matrix/client/v3/rooms/%s/send/m.reaction/%s",
                    mx_encode_id(room_id), mx_encode_id(mx_txn_id())
    )
    resp <- mx_http(
                    session$server, "PUT", path,
                    body = content, token = session$token
    )
    resp$event_id
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
#' @examples
#' \dontrun{
#' batch <- mx_sync(s)
#' next_batch <- batch$next_batch
#' }
#' @export
mx_sync <- function(session, since = NULL, timeout = 0L, filter = NULL) {
    query <- list(timeout = as.integer(timeout))
    if (!is.null(since)) {
        query$since <- since
    }
    if (!is.null(filter)) {
        query$filter <- filter
    }

    mx_http(
            session$server, "GET", "/_matrix/client/v3/sync",
            query = query, token = session$token
    )
}

