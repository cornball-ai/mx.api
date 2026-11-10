#' mx.api: Minimal Matrix Client-Server API
#'
#' Base-R bindings for the Matrix Client-Server HTTP API, suitable for
#' talking to a Synapse homeserver. Two dependencies: curl and jsonlite.
#' End-to-end encryption is out of scope; use unencrypted rooms or a
#' separate crypto package.
#'
#' @section Network deadlines:
#' Every HTTP request has a connection timeout and a total deadline, including
#' login, sync, key exchange and media transfers. Options
#' \code{mx.api.connect_timeout}, \code{mx.api.request_timeout} and
#' \code{mx.api.media_timeout} set these limits in seconds; defaults are
#' 10, 60 and 300 respectively. Values must be finite and positive.
#' Sync and federated key lookups add their requested server-side wait to the
#' request deadline, so a 30-second sync has a 90-second total deadline.
#' Connection setup remains limited to 10 seconds by default.
#'
#' Timeouts propagate as curl errors for the caller's retry loop. Requests are
#' not automatically replayed: a timed-out write may already have succeeded
#' on the server. A failed download may leave a partial destination file.
#'
#' @name mx.api-package
#' @aliases mx.api
"_PACKAGE"

