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
        tryCatch(
                 jsonlite::fromJSON(raw, simplifyVector = FALSE),
                 error = function(e) list(raw = raw)
        )
    } else {
        list()
    }

    if (resp$status_code >= 400) {
        errcode <- parsed$errcode %||% "HTTP"
        msg <- parsed$error %||% paste("HTTP", resp$status_code)
        stop(sprintf("Matrix error [%s]: %s", errcode, msg), call. = FALSE)
    }

    parsed
}

`%||%` <- function(a, b) if (is.null(a)) b else a

mx_txn_id <- function() {
    paste0("mx-", as.integer(Sys.time()), "-",
           sample.int(.Machine$integer.max, 1))
}

mx_encode_id <- function(x) utils::URLencode(x, reserved = TRUE)

