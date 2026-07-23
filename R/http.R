# Internal HTTP helper. Not exported.

mx_http <- function(base_url, method, path, body = NULL, query = NULL,
                    token = NULL) {
    url <- paste0(sub("/$", "", base_url), path)
    if (length(query)) {
        pairs <- mapply(
                        function(k, v) paste0(utils::URLencode(k, reserved = TRUE), "=",
                utils::URLencode(as.character(v), reserved = TRUE)),
                        names(query), query, SIMPLIFY = TRUE, USE.NAMES = FALSE
        )
        url <- paste0(url, "?", paste(pairs, collapse = "&"))
    }

    h <- curl::new_handle()
    curl::handle_setopt(h, customrequest = method)
    headers <- c(Accept = "application/json")
    if (!is.null(token)) {
        headers <- c(headers, Authorization = paste("Bearer", token))
    }
    if (!is.null(body)) {
        payload <- jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")
        curl::handle_setopt(h, postfields = payload)
        headers <- c(headers, `Content-Type` = "application/json")
    }
    curl::handle_setheaders(h, .list = as.list(headers))

    resp <- curl::curl_fetch_memory(url, handle = h)
    raw <- rawToChar(resp$content)
    parsed <- if (nzchar(raw)) {
        tryCatch(jsonlite::fromJSON(raw, simplifyVector = FALSE),
                 error = function(e) list(raw = raw))
    } else {
        list()
    }

    if (resp$status_code >= 400) {
        mx_raise(parsed$errcode %||% "HTTP",
                 parsed$error %||% paste("HTTP", resp$status_code),
                 status = resp$status_code, body = parsed)
    }

    parsed
}

# Raise a classed Matrix error. Code can catch specific failures by
# class -- e.g. tryCatch(..., mx_error_M_NOT_FOUND = function(e) NULL)
# or test inherits(e, "mx_error_M_UNKNOWN_TOKEN") to re-login -- instead
# of grepl()ing the message. The message text keeps the historical
# "Matrix error [CODE]: msg" shape, and $errcode, $status, and $body
# carry the structured details.
mx_raise <- function(errcode, msg, status = NULL, body = NULL) {
    cond <- structure(
                      class = c(paste0("mx_error_", errcode), "mx_error", "error",
                                "condition"),
                      list(
                           message = sprintf("Matrix error [%s]: %s", errcode, msg),
                           call = NULL,
                           errcode = errcode,
                           status = status,
                           body = body
        )
    )
    stop(cond)
}

`%||%` <- function(a, b) if (is.null(a)) b else a

mx_txn_id <- function() {
    paste0("mx-", as.integer(Sys.time()), "-",
           sample.int(.Machine$integer.max, 1))
}

mx_encode_id <- function(x) utils::URLencode(x, reserved = TRUE)

mx_empty_body <- function() stats::setNames(list(), character())
