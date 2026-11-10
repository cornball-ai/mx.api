library(tinytest)

# Real libcurl requests against a delayed loopback server. The fixture answers
# after two seconds even without the fix, so a regression cannot hang the suite.
if (.Platform$OS.type != "unix" || !exists("serverSocket", baseenv())) {
    exit_file("Local socket fixture requires Unix and serverSocket")
}

local({
    old_options <- options(mx.api.connect_timeout = 0.1,
                           mx.api.request_timeout = 0.2,
                           mx.api.media_timeout = 0.2)
    on.exit(options(old_options), add = TRUE)
    # A proxy must not redirect synthetic requests out of the loopback fixture.
    proxy_names <- c("http_proxy", "https_proxy", "HTTP_PROXY", "HTTPS_PROXY",
                     "ALL_PROXY", "all_proxy", "NO_PROXY", "no_proxy")
    old_env <- Sys.getenv(proxy_names, unset = NA_character_)
    on.exit({
        Sys.unsetenv(names(old_env)[is.na(old_env)])
        present <- old_env[!is.na(old_env)]
        if (length(present)) {
            do.call(Sys.setenv, as.list(present))
        }
    }, add = TRUE)
    Sys.unsetenv(proxy_names)
    src <- tempfile()
    dest <- tempfile()
    on.exit(unlink(c(src, dest)), add = TRUE)
    writeLines("fixture", src)

    probe <- function(request, delay = 2, tls = FALSE) {
        listener <- NULL
        for (port in sample(20000:50000, 20L)) {
            listener <- tryCatch(serverSocket(port), error = function(e) NULL)
            if (!is.null(listener)) break
        }
        if (is.null(listener)) stop("Could not bind loopback fixture")
        on.exit(close(listener), add = TRUE)
        accepted <- tempfile()
        on.exit(unlink(accepted), add = TRUE)
        child <- parallel::mcparallel({
            con <- socketAccept(listener, blocking = TRUE, open = "a+b",
                                timeout = 5)
            writeLines("accepted", accepted)
            Sys.sleep(delay)
            body <- '{"user_id":"@u:example","next_batch":"next"}'
            response <- paste0("HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n",
                               "Content-Length: ", nchar(body, type = "bytes"),
                               "\r\nConnection: close\r\n\r\n", body)
            writeBin(charToRaw(response), con)
            close(con)
            TRUE
        }, silent = TRUE)
        on.exit({
            # Terminate only this fixture's child, before it can write to a
            # timed-out socket. Reaping it also prevents PID reuse races.
            tools::pskill(child$pid)
            suppressWarnings(parallel::mccollect(child))
        }, add = TRUE)
        scheme <- if (tls) "https" else "http"
        session <- mx.api::mx_session(paste0(scheme, "://127.0.0.1:", port),
                                      "fixture", "@u:example", "DEV")
        start <- proc.time()[["elapsed"]]
        value <- tryCatch(request(session), error = identity)
        elapsed <- proc.time()[["elapsed"]] - start
        expect_true(file.exists(accepted), info = "Fixture accepted the connection")
        list(value = value, elapsed = elapsed)
    }
    timed_out <- function(result) {
        expect_inherits(result$value, "curl_error_operation_timedout")
        expect_true(result$elapsed < 1.5,
                    info = paste("Deadline elapsed seconds:", result$elapsed))
    }

    # Healthy control and a delayed but legitimate long poll both complete.
    ok <- probe(mx.api::mx_whoami, delay = 0)
    expect_identical(ok$value$user_id, "@u:example")
    ok <- probe(function(s) mx.api::mx_sync(s, timeout = 1000L), delay = 0.4)
    expect_identical(ok$value$next_batch, "next")

    timed_out(probe(mx.api::mx_whoami))
    timed_out(probe(function(s) mx.api::mx_sync(s, timeout = 200L)))
    timed_out(probe(function(s) mx.api::mx_upload(s, src)))
    timed_out(probe(function(s) mx.api::mx_download(s, "mxc://example/id", dest)))

    # TCP accepts immediately; a silent TLS handshake must hit the connection
    # deadline even when the overall request allowance is much longer.
    options(mx.api.request_timeout = 10)
    timed_out(probe(mx.api::mx_whoami, tls = TRUE))

    # A failed request must not poison the next poll in the same process.
    ok <- probe(function(s) mx.api::mx_sync(s, since = "old"), delay = 0)
    expect_identical(ok$value$next_batch, "next")
})
