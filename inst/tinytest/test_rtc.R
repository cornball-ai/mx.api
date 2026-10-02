library(tinytest)

# The RTC endpoints: request shapes and response handling, with mx_http
# replaced so no network is needed.

fake <- mx.api::mx_session(
  server = "https://example",
  token = "tok",
  user_id = "@u:example",
  device_id = "DEV"
)

with_http <- function(handler, code) {
  ns <- asNamespace("mx.api")
  original <- get("mx_http", envir = ns, inherits = FALSE)
  assignInNamespace("mx_http", handler, ns = "mx.api")
  on.exit(assignInNamespace("mx_http", original, ns = "mx.api"), add = TRUE)
  force(code)
}

# OpenID token: POST with an empty JSON object, response passed through whole
local({
  calls <- list()
  token <- list(access_token = "oid", token_type = "Bearer",
                matrix_server_name = "example", expires_in = 3600L)
  out <- with_http(function(base_url, method, path, body = NULL,
                            query = NULL, token = NULL) {
    calls[[length(calls) + 1L]] <<- list(method = method, path = path,
                                         body = body, token = token)
    list(access_token = "oid", token_type = "Bearer",
         matrix_server_name = "example", expires_in = 3600L)
  }, mx.api::mx_openid_token(fake))
  expect_identical(out, token)
  expect_identical(calls[[1]]$method, "POST")
  expect_identical(calls[[1]]$path,
                   "/_matrix/client/v3/user/%40u%3Aexample/openid/request_token")
  expect_identical(calls[[1]]$token, "tok")
  expect_true(is.list(calls[[1]]$body))
  expect_identical(length(calls[[1]]$body), 0L)
  expect_identical(jsonlite::toJSON(calls[[1]]$body, auto_unbox = TRUE),
                   structure("{}", class = "json"))
})

# RTC transports: the list when present, empty when the server lacks it
local({
  seen <- NULL
  out <- with_http(function(base_url, method, path, body = NULL,
                            query = NULL, token = NULL) {
    seen <<- list(method = method, path = path, token = token)
    list(rtc_transports = list(list(type = "livekit",
                                    livekit_service_url = "https://jwt.example")))
  }, mx.api::mx_rtc_transports(fake))
  expect_identical(seen$method, "GET")
  expect_identical(seen$path,
                   "/_matrix/client/unstable/org.matrix.msc4143/rtc/transports")
  expect_identical(seen$token, "tok")
  expect_identical(out[[1]]$livekit_service_url, "https://jwt.example")

  expect_identical(with_http(function(...) list(rtc_transports = list()),
                             mx.api::mx_rtc_transports(fake)), list())
  unrecognized <- function(...) {
    mx.api:::mx_raise("M_UNRECOGNIZED", "Not Found", status = 404L)
  }
  expect_identical(with_http(unrecognized, mx.api::mx_rtc_transports(fake)),
                   list())
  not_found <- function(...) mx.api:::mx_raise("M_NOT_FOUND", "no", status = 404L)
  expect_identical(with_http(not_found, mx.api::mx_rtc_transports(fake)),
                   list())
  forbidden <- function(...) mx.api:::mx_raise("M_FORBIDDEN", "no", status = 403L)
  expect_error(with_http(forbidden, mx.api::mx_rtc_transports(fake)),
               "M_FORBIDDEN")
})

# Full room state: GET on the room, events returned as a list
local({
  seen <- NULL
  events <- list(list(type = "m.room.member", state_key = "@u:example",
                      content = list(membership = "join")))
  out <- with_http(function(base_url, method, path, body = NULL,
                            query = NULL, token = NULL) {
    seen <<- list(method = method, path = path)
    events
  }, mx.api::mx_room_state(fake, "!abc:example"))
  expect_identical(seen$method, "GET")
  expect_identical(seen$path, "/_matrix/client/v3/rooms/%21abc%3Aexample/state")
  expect_identical(out, events)
  expect_identical(with_http(function(...) NULL,
                             mx.api::mx_room_state(fake, "!abc:example")),
                   list())
})

# Well-known: fetched from the server name over https, NULL when absent
local({
  seen <- NULL
  doc <- list("m.homeserver" = list(base_url = "https://hs.example"),
              "org.matrix.msc4143.rtc_foci" = list(list(
                type = "livekit", livekit_service_url = "https://jwt.example")))
  out <- with_http(function(base_url, method, path, body = NULL,
                            query = NULL, token = NULL) {
    seen <<- list(base_url = base_url, method = method, path = path,
                  token = token)
    doc
  }, mx.api::mx_well_known_client("example.org"))
  expect_identical(out, doc)
  expect_identical(seen$base_url, "https://example.org")
  expect_identical(seen$path, "/.well-known/matrix/client")
  expect_null(seen$token)

  with_http(function(base_url, ...) { seen <<- base_url; NULL },
            mx.api::mx_well_known_client("https://matrix.example.org/path"))
  expect_identical(seen, "https://matrix.example.org")

  not_found <- function(...) mx.api:::mx_raise("HTTP", "HTTP 404", status = 404L)
  expect_null(with_http(not_found, mx.api::mx_well_known_client("example.org")))
  expect_null(with_http(function(...) stop("Could not resolve host"),
                        mx.api::mx_well_known_client("nowhere.invalid")))
})
