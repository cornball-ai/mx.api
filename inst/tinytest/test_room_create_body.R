# What mx_room_create() actually puts on the wire.
#
# The existence checks in test_rooms.R cannot see this, and a live server
# is not needed to: the request body is built entirely in R. `mx_http` is
# stubbed and the body captured, which is the only way to assert the shape
# of a field whose wrong shape the server accepts.

library(tinytest)

ns <- asNamespace("mx.api")
capture_body <- function(expr) {
    seen <- NULL
    orig <- get("mx_http", envir = ns, inherits = FALSE)
    assignInNamespace("mx_http", function(base_url, method, path, body = NULL,
                                          query = NULL, token = NULL) {
        seen <<- body
        list(room_id = "!captured:example.org")
    }, ns = "mx.api")
    on.exit(assignInNamespace("mx_http", orig, ns = "mx.api"), add = TRUE)
    force(expr)
    seen
}

s <- mx.api::mx_session("https://example.org", "tok", "@bot:example.org", "DEV")

# ---- the default body is unchanged ----------------------------------
# creation_content is absent, not empty. An empty object in m.room.create
# is a different request from no object at all.
b <- capture_body(mx.api::mx_room_create(s, name = "plain"))
expect_equal(b$name, "plain")
expect_equal(b$visibility, "private")
expect_null(b$creation_content)

# ---- a space carries type through -----------------------------------
b <- capture_body(mx.api::mx_room_create(s, name = "Topics",
                                         creation_content = list(type = "m.space")))
expect_equal(b$creation_content, list(type = "m.space"))

# THE SHAPE, not just the value. `type = "m.space"` has to serialize as
# an object; mx_http auto-unboxes, and an unnamed list(...) of one string
# goes out as a bare "m.space" instead. The server's response to that is
# an ordinary room, so the failure is a working space-less space rather
# than an error. Asserted on the JSON because that is where it goes wrong.
json <- jsonlite::toJSON(b, auto_unbox = TRUE, null = "null")
expect_true(grepl('"creation_content":\\{"type":"m.space"\\}', json))

# ---- an unnamed list is refused rather than sent ---------------------
# This is the mistake the assertion above describes, caught at the call
# instead of becoming a room that looks fine and holds nothing.
expect_error(mx.api::mx_room_create(s, creation_content = list("m.space")),
             "fully named")
expect_error(mx.api::mx_room_create(s, creation_content = list(type = "m.space", "x")),
             "fully named")

# ---- an empty creation_content is treated as absent ------------------
b <- capture_body(mx.api::mx_room_create(s, creation_content = list()))
expect_null(b$creation_content)

# ---- invite and creation_content coexist ----------------------------
b <- capture_body(mx.api::mx_room_create(s, name = "Topics",
                                         invite = c("@troy:example.org"),
                                         creation_content = list(type = "m.space")))
expect_equal(b$invite, list("@troy:example.org"))
expect_equal(b$creation_content, list(type = "m.space"))
