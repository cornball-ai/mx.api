# Device-key and to-device transport endpoints.
#
# These four endpoints carry the raw JSON payloads that an end-to-end
# encryption layer (e.g. mx.crypto) needs to coordinate Olm sessions.
# mx.api itself does no cryptography: signing, OTK generation, and
# Olm / Megolm orchestration live in the caller. The bodies passed in
# must already be signed where the Matrix spec requires it.

#' Upload device identity and one-time keys
#'
#' POST \code{/_matrix/client/v3/keys/upload}. The \code{device_keys}
#' and \code{one_time_keys} arguments must be fully formed and signed
#' per the Matrix specification; mx.api will not canonicalise or sign
#' them. Use \code{\link{mx_canonical_json}} to produce the byte
#' sequence to sign.
#'
#' @param session An \code{mx_session}.
#' @param device_keys Named list. The \code{device_keys} object as
#'   defined in the Matrix spec, including \code{user_id},
#'   \code{device_id}, \code{algorithms}, \code{keys}, and the
#'   \code{signatures} block produced by the caller's signer. Pass
#'   NULL to upload only one-time keys.
#' @param one_time_keys Named list or NULL. Map from
#'   \code{"<algorithm>:<key_id>"} (e.g. \code{"signed_curve25519:AAAA"})
#'   to the signed key object. Pass NULL or an empty list to skip.
#' @param fallback_keys Named list or NULL. Same shape as
#'   \code{one_time_keys}; used to advertise a fallback key when the
#'   OTK pool is exhausted.
#'
#' @return The parsed homeserver response, including
#'   \code{one_time_key_counts}.
#'
#' @examples
#' \dontrun{
#' mx_keys_upload(s, device_keys = signed_dk, one_time_keys = signed_otks)
#' }
#' @export
mx_keys_upload <- function(session, device_keys = NULL, one_time_keys = NULL,
                           fallback_keys = NULL) {
    body <- list()
    if (!is.null(device_keys)) {
        body$device_keys <- device_keys
    }
    if (length(one_time_keys)) {
        body$one_time_keys <- one_time_keys
    }
    if (length(fallback_keys)) {
        body[["org.matrix.msc2732.fallback_keys"]] <- fallback_keys
        body$fallback_keys <- fallback_keys
    }
    if (length(body) == 0L) {
        stop("mx_keys_upload: nothing to upload", call. = FALSE)
    }
    mx_http(session$server, "POST", "/_matrix/client/v3/keys/upload",
            body = body, token = session$token)
}

#' Query device keys for one or more users
#'
#' POST \code{/_matrix/client/v3/keys/query}. Each entry in
#' \code{device_keys} maps a Matrix user id to a character vector of
#' device ids to request. An empty character vector requests all of
#' the user's devices.
#'
#' @param session An \code{mx_session}.
#' @param device_keys Named list. Names are Matrix user ids
#'   (e.g. \code{"@@alice:example.org"}); values are character vectors
#'   of device ids, or \code{character(0)} for "all devices".
#' @param timeout Integer milliseconds. Time the server should wait
#'   for remote homeservers before returning a partial result.
#' @param token Character or NULL. \code{since}-style sync token from
#'   the prior key-query, when iterating.
#'
#' @return Parsed response with a \code{device_keys} map of
#'   \code{user_id -> device_id -> device_keys_object}.
#'
#' @examples
#' \dontrun{
#' mx_keys_query(s, list("@alice:example.org" = character()))
#' }
#' @export
mx_keys_query <- function(session, device_keys, timeout = 10000L,
                          token = NULL) {
    if (!is.list(device_keys) || is.null(names(device_keys))) {
        stop("mx_keys_query: 'device_keys' must be a named list", call. = FALSE)
    }
    dk <- lapply(device_keys, function(v) {
        if (is.null(v)) {
            return(list())
        }
        as.list(as.character(v))
    })
    body <- list(device_keys = dk, timeout = as.integer(timeout))
    if (!is.null(token)) {
        body$token <- as.character(token)
    }
    mx_http(session$server, "POST", "/_matrix/client/v3/keys/query",
            body = body, token = session$token)
}

#' Claim one-time keys for an Olm handshake
#'
#' POST \code{/_matrix/client/v3/keys/claim}. The
#' \code{one_time_keys} argument selects which algorithm to claim for
#' each \code{(user_id, device_id)} pair.
#'
#' @param session An \code{mx_session}.
#' @param one_time_keys Named list. Names are user ids; values are
#'   named lists mapping device ids to the desired algorithm
#'   (typically \code{"signed_curve25519"}).
#' @param timeout Integer milliseconds. Server-side timeout when
#'   talking to remote homeservers.
#'
#' @return Parsed response with the claimed keys keyed by
#'   \code{user_id -> device_id -> "<algorithm>:<key_id>" -> key_object}.
#'
#' @examples
#' \dontrun{
#' mx_keys_claim(s, list(
#'   "@alice:example.org" = list(ABCD1234 = "signed_curve25519")
#' ))
#' }
#' @export
mx_keys_claim <- function(session, one_time_keys, timeout = 10000L) {
    if (!is.list(one_time_keys) || is.null(names(one_time_keys))) {
        stop("mx_keys_claim: 'one_time_keys' must be a named list",
             call. = FALSE)
    }
    body <- list(one_time_keys = one_time_keys, timeout = as.integer(timeout))
    mx_http(session$server, "POST", "/_matrix/client/v3/keys/claim",
            body = body, token = session$token)
}

#' Send a to-device event
#'
#' PUT \code{/_matrix/client/v3/sendToDevice/{eventType}/{txnId}}.
#' Used to ship encrypted Olm payloads (e.g. m.room_key carriers
#' wrapped as \code{m.room.encrypted}) to specific
#' \code{(user_id, device_id)} targets.
#'
#' @param session An \code{mx_session}.
#' @param event_type Character. The to-device event type, e.g.
#'   \code{"m.room.encrypted"}.
#' @param messages Named list. Outer names are user ids; values are
#'   named lists mapping device id (or the wildcard \code{"*"}) to
#'   the event content.
#' @param txn_id Character or NULL. Idempotency key; auto-generated
#'   when NULL.
#'
#' @return Invisible NULL (the server returns an empty body on success).
#'
#' @examples
#' \dontrun{
#' mx_send_to_device(s, "m.room.encrypted", list(
#'   "@bob:example.org" = list(BBBB = encrypted_content)
#' ))
#' }
#' @export
mx_send_to_device <- function(session, event_type, messages, txn_id = NULL) {
    if (!is.list(messages) || is.null(names(messages))) {
        stop("mx_send_to_device: 'messages' must be a named list",
             call. = FALSE)
    }
    if (is.null(txn_id)) {
        txn_id <- mx_txn_id()
    }
    path <- sprintf(
                    "/_matrix/client/v3/sendToDevice/%s/%s",
                    mx_encode_id(as.character(event_type)),
                    mx_encode_id(as.character(txn_id))
    )
    mx_http(session$server, "PUT", path,
            body = list(messages = messages), token = session$token)
    invisible(NULL)
}

