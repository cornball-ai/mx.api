library(tinytest)

# Exercise the public entry points and capture the actual libcurl options.
# Transport fakes keep all requests local to this process.
local({
    old_options <- options(mx.api.connect_timeout = NULL,
                           mx.api.request_timeout = NULL,
                           mx.api.media_timeout = NULL)
    on.exit(options(old_options), add = TRUE)
    original_handle <- curl::new_handle
    original_fetch <- curl::curl_fetch_memory
    original_download <- curl::curl_download
    on.exit({
        assignInNamespace("new_handle", original_handle, "curl")
        assignInNamespace("curl_fetch_memory", original_fetch, "curl")
        assignInNamespace("curl_download", original_download, "curl")
    }, add = TRUE)
    handles <- list()
    requests <- 0L
    fail <- FALSE
    failure <- simpleError("fixture transport failure")
    assignInNamespace("new_handle", function(...) {
        handles[[length(handles) + 1L]] <<- list(...)
        original_handle(...)
    }, "curl")
    assignInNamespace("curl_fetch_memory", function(url, handle) {
        requests <<- requests + 1L
        if (fail) stop(failure)
        list(status_code = 200L, content = charToRaw(paste0(
                    '{"user_id":"@u:example","device_id":"DEV",',
                    '"access_token":"fixture","content_uri":"mxc://example/id"}'
                )))
    }, "curl")
    assignInNamespace("curl_download", function(url, destfile, handle) {
        requests <<- requests + 1L
        writeLines("fixture", destfile)
        invisible(destfile)
    }, "curl")
    check_deadline <- function(total, connect = 10000L) {
        h <- handles[[length(handles)]]
        expect_identical(h$timeout_ms, as.integer(total))
        expect_identical(h$connecttimeout_ms, as.integer(connect))
    }
    session <- mx.api::mx_session("https://example.invalid", "fixture",
                                  "@u:example", "DEV")
    src <- tempfile()
    dest <- tempfile()
    on.exit(unlink(c(src, dest)), add = TRUE)
    writeLines("fixture", src)

    expect_identical(mx.api::mx_whoami(session)$user_id, "@u:example")
    check_deadline(60000L)
    mx.api::mx_login(session$server, "u", "fixture")
    check_deadline(60000L)
    mx.api::mx_sync(session, timeout = 30000L)
    check_deadline(90000L)
    mx.api::mx_keys_query(session, list("@u:example" = character()))
    check_deadline(70000L)
    mx.api::mx_keys_claim(session, list("@u:example" = list(DEV = "key")))
    check_deadline(70000L)
    mx.api::mx_typing(session, "!room:example", timeout = 120000L)
    check_deadline(60000L) # Typing lifetime is not a server-side wait.
    expect_identical(mx.api::mx_upload(session, src), "mxc://example/id")
    check_deadline(300000L)
    mx.api::mx_download(session, "mxc://example/id", dest)
    check_deadline(300000L)
    expect_identical(readLines(dest), "fixture")
    expect_identical(requests, 8L)

    options(mx.api.connect_timeout = 0.25, mx.api.request_timeout = 0.1,
            mx.api.media_timeout = 0.5)
    mx.api::mx_whoami(session)
    check_deadline(100L, 100L)
    mx.api::mx_sync(session, timeout = 500L)
    check_deadline(600L, 250L)
    mx.api::mx_upload(session, src)
    check_deadline(500L, 250L)
    mx.api::mx_download(session, "mxc://example/id", dest)
    check_deadline(500L, 250L)
    options(mx.api.request_timeout = 0.0001)
    mx.api::mx_whoami(session)
    check_deadline(1L, 1L)

    # Bad configuration must fail before dispatch, never turn off the limit.
    before <- requests
    bad_values <- list(0, -1, NA_real_, Inf, "1", TRUE, c(1, 2),
                       numeric(), .Machine$integer.max)
    for (name in c("mx.api.connect_timeout", "mx.api.request_timeout",
                   "mx.api.media_timeout")) {
        for (value in bad_values) {
            options(mx.api.connect_timeout = 10, mx.api.request_timeout = 60,
                    mx.api.media_timeout = 300)
            options(stats::setNames(list(value), name))
            if (name == "mx.api.media_timeout") {
                expect_error(mx.api::mx_upload(session, src), "finite positive")
                expect_error(mx.api::mx_download(session, "mxc://example/id", dest),
                             "finite positive")
            } else {
                expect_error(mx.api::mx_whoami(session), "finite positive")
            }
        }
    }
    options(mx.api.connect_timeout = 10, mx.api.request_timeout = 60,
            mx.api.media_timeout = 300)
    expect_error(mx.api::mx_sync(session, timeout = -1L), "server wait")
    expect_error(mx.api::mx_sync(session, timeout = NA_integer_), "server wait")
    expect_error(mx.api::mx_sync(session, timeout = c(1L, 2L)), "server wait")
    expect_error(mx.api::mx_sync(session, timeout = .Machine$integer.max),
                 "deadline is too large")
    expect_error(mx.api::mx_keys_query(session, list("@u:example" = character()),
                                       timeout = -1L), "server wait")
    expect_identical(requests, before)

    # A failed write can already have reached the server: do not retry it.
    fail <- TRUE
    err <- tryCatch(mx.api::mx_upload(session, src), error = identity)
    expect_identical(err, failure)
    expect_identical(requests, before + 1L)
    err <- tryCatch(mx.api::mx_typing(session, "!room:example"), error = identity)
    expect_identical(err, failure)
    expect_identical(requests, before + 2L)
})
