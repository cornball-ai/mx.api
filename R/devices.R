# Device management.

#' List this account's devices
#'
#' @param session An "mx_session" object.
#' @return A list of devices, each with \code{device_id},
#'   \code{display_name}, \code{last_seen_ip}, and \code{last_seen_ts}.
#' @examples
#' \dontrun{
#' vapply(mx_devices(s), function(d) d$device_id, character(1))
#' }
#' @export
mx_devices <- function(session) {
    resp <- mx_http(session$server, "GET", "/_matrix/client/v3/devices",
                    token = session$token)
    resp$devices %||% list()
}

#' Delete a device
#'
#' Removes a device and invalidates its access token. Most homeservers
#' protect this with user-interactive authentication: the first call
#' fails with M_FORBIDDEN or a 401 carrying a \code{flows} object, and
#' the caller retries with a completed \code{auth} payload, e.g.
#' \code{list(type = "m.login.password", identifier = list(type =
#' "m.id.user", user = "bot"), password = "...", session = "<from the
#' 401>")}. mx.api deliberately does not automate that exchange.
#'
#' @param session An "mx_session" object.
#' @param device_id Character. The device to delete.
#' @param auth List or NULL. Completed user-interactive auth payload.
#' @return Invisibly TRUE on success.
#' @examples
#' \dontrun{
#' mx_delete_device(s, "OLDDEVICE", auth = list(
#'     type = "m.login.password",
#'     identifier = list(type = "m.id.user", user = "bot"),
#'     password = "secret"
#' ))
#' }
#' @export
mx_delete_device <- function(session, device_id, auth = NULL) {
    body <- if (is.null(auth)) {
        mx_empty_body()
    } else {
        list(auth = auth)
    }
    path <- sprintf(
                    "/_matrix/client/v3/devices/%s",
                    mx_encode_id(device_id)
    )
    mx_http(session$server, "DELETE", path, body = body,
            token = session$token)
    invisible(TRUE)
}
