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

    path <- sprintf("/_matrix/client/v3/rooms/%s/send/m.room.message/%s",
                    mx_encode_id(room_id), mx_encode_id(mx_txn_id()))
    resp <- mx_http(
                    session$server, "PUT", path,
                    body = content, token = session$token
    )
    resp$event_id
}

#' Send an arbitrary room event
#'
#' Generic counterpart to \code{\link{mx_send}} for event types other than
#' \code{m.room.message}, such as \code{m.room.encrypted}. The content is
#' sent verbatim.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_type Character. The event type, e.g.
#'   \code{"m.room.encrypted"}.
#' @param content List. The event content, sent as-is.
#' @param txn_id Character or NULL. Transaction id (generated if NULL).
#' @return The event ID of the sent event.
#' @examples
#' \dontrun{
#' mx_send_event(s, "!abc:example", "m.room.encrypted", encrypted_content)
#' }
#' @export
mx_send_event <- function(session, room_id, event_type, content,
                          txn_id = NULL) {
    if (is.null(txn_id)) {
        txn_id <- mx_txn_id()
    }
    path <- sprintf("/_matrix/client/v3/rooms/%s/send/%s/%s",
                    mx_encode_id(room_id), mx_encode_id(event_type),
                    mx_encode_id(txn_id))
    resp <- mx_http(
                    session$server, "PUT", path,
                    body = content, token = session$token
    )
    resp$event_id
}

#' Set a room state event
#'
#' Generic state setter, e.g. to mark a room encrypted by putting an
#' \code{m.room.encryption} event.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_type Character. State event type, e.g.
#'   \code{"m.room.encryption"}.
#' @param content List. The state content, sent as-is.
#' @param state_key Character. State key (default empty string).
#' @return The event ID of the state event.
#' @examples
#' \dontrun{
#' mx_set_state(s, "!abc:example", "m.room.encryption",
#'              list(algorithm = "m.megolm.v1.aes-sha2"))
#' }
#' @export
mx_set_state <- function(session, room_id, event_type, content,
                         state_key = "") {
    path <- sprintf("/_matrix/client/v3/rooms/%s/state/%s/%s",
                    mx_encode_id(room_id), mx_encode_id(event_type),
                    mx_encode_id(state_key))
    resp <- mx_http(
                    session$server, "PUT", path,
                    body = content, token = session$token
    )
    resp$event_id
}

#' Get a room state event
#'
#' Read-side counterpart of \code{\link{mx_set_state}}, e.g. to check
#' whether a room is encrypted before joining the send path.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_type Character. State event type, e.g.
#'   \code{"m.room.encryption"}.
#' @param state_key Character. State key (default empty string).
#' @return The state event content as a list, or NULL when the state
#'   event is not set.
#' @examples
#' \dontrun{
#' enc <- mx_get_state(s, "!abc:example", "m.room.encryption")
#' is.null(enc)   # FALSE in an encrypted room
#' }
#' @export
mx_get_state <- function(session, room_id, event_type, state_key = "") {
    path <- sprintf("/_matrix/client/v3/rooms/%s/state/%s/%s",
                    mx_encode_id(room_id), mx_encode_id(event_type),
                    mx_encode_id(state_key))
    tryCatch(
             mx_http(session$server, "GET", path, token = session$token),
             mx_error_M_NOT_FOUND = function(e) NULL
    )
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

    path <- sprintf("/_matrix/client/v3/rooms/%s/messages",
                    mx_encode_id(room_id))
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
    path <- sprintf("/_matrix/client/v3/rooms/%s/receipt/%s/%s",
                    mx_encode_id(room_id), mx_encode_id(receipt_type),
                    mx_encode_id(event_id))
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
                    `m.relates_to` = list(rel_type = "m.annotation", event_id = event_id,
            key = key)
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

    mx_http(session$server, "GET", "/_matrix/client/v3/sync", query = query,
            token = session$token)
}

#' Redact an event
#'
#' Removes the content of a message, reaction, or other event. This is
#' how Matrix deletes things.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param event_id Character. The event to redact.
#' @param reason Character or NULL. Optional human-readable reason.
#' @param txn_id Character or NULL. Transaction id (generated if NULL).
#' @return The event ID of the redaction event.
#' @examples
#' \dontrun{
#' mx_redact(s, "!abc:example", "$someevent", reason = "typo")
#' }
#' @export
mx_redact <- function(session, room_id, event_id, reason = NULL,
                      txn_id = NULL) {
    if (is.null(txn_id)) {
        txn_id <- mx_txn_id()
    }
    body <- if (is.null(reason)) {
        mx_empty_body()
    } else {
        list(reason = reason)
    }
    path <- sprintf("/_matrix/client/v3/rooms/%s/redact/%s/%s",
                    mx_encode_id(room_id), mx_encode_id(event_id),
                    mx_encode_id(txn_id))
    resp <- mx_http(session$server, "PUT", path, body = body,
                    token = session$token)
    resp$event_id
}

#' Send a typing notification
#'
#' Shows (or clears) the session user's typing indicator in a room.
#' Useful bot polish while a slow reply is being generated.
#'
#' @param session An "mx_session" object.
#' @param room_id Character. The room ID.
#' @param typing Logical. TRUE to show typing, FALSE to clear it.
#' @param timeout Integer. How long the indicator lasts, in
#'   milliseconds (ignored when \code{typing = FALSE}).
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' mx_typing(s, "!abc:example", TRUE)
#' # ... generate the reply ...
#' mx_typing(s, "!abc:example", FALSE)
#' }
#' @export
mx_typing <- function(session, room_id, typing = TRUE, timeout = 30000L) {
    body <- list(typing = isTRUE(typing))
    if (isTRUE(typing)) {
        body$timeout <- as.integer(timeout)
    }
    path <- sprintf("/_matrix/client/v3/rooms/%s/typing/%s",
                    mx_encode_id(room_id), mx_encode_id(session$user_id))
    mx_http(session$server, "PUT", path, body = body, token = session$token)
    invisible(TRUE)
}
