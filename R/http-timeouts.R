# All HTTP entry points use finite deadlines. A server-side wait (sync or
# federated key lookup) is additional to the ordinary network allowance.
mx_timeout_option <- function(name, default) {
    value <- getOption(name, default)
    if (!is.numeric(value) || length(value) != 1L || is.na(value) ||
        !is.finite(value) || value <= 0 ||
        value > .Machine$integer.max / 1000) {
        stop(name, " must be a finite positive number of seconds, at most ",
             .Machine$integer.max / 1000, ".", call. = FALSE)
    }
    value
}

mx_server_wait <- function(path, body, query) {
    wait <- 0
    if (identical(path, "/_matrix/client/v3/sync")) {
        wait <- query$timeout %||% 0
    } else if (path %in% c("/_matrix/client/v3/keys/query",
                           "/_matrix/client/v3/keys/claim")) {
        wait <- body$timeout %||% 0
    }
    if (!is.numeric(wait) || length(wait) != 1L || is.na(wait) ||
        !is.finite(wait) || wait < 0) {
        stop("Matrix server wait must be a finite non-negative number of milliseconds.",
             call. = FALSE)
    }
    wait
}

mx_http_handle <- function(wait = 0, media = FALSE) {
    connect <- mx_timeout_option("mx.api.connect_timeout", 10)
    if (media) {
        budget <- mx_timeout_option("mx.api.media_timeout", 300)
    } else {
        budget <- mx_timeout_option("mx.api.request_timeout", 60)
    }

    total_ms <- ceiling(budget * 1000 + wait)
    if (!is.finite(total_ms) || total_ms > .Machine$integer.max) {
        stop("Matrix request deadline is too large.", call. = FALSE)
    }
    curl::new_handle(
                     connecttimeout_ms = as.integer(min(ceiling(connect * 1000), total_ms)),
                     timeout_ms = as.integer(total_ms)
    )
}
