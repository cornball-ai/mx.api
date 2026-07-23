library(tinytest)

# All live-server tests are gated on at_home() so R CMD check sees no
# network. Locally, set MX_TEST_SERVER / MX_TEST_USER / MX_TEST_PASS to
# run against a real Synapse.

expect_true(is.function(mx.api::mx_login))
expect_true(is.function(mx.api::mx_session))
expect_true(is.function(mx.api::mx_logout))
expect_true(is.function(mx.api::mx_whoami))
expect_true(is.function(mx.api::mx_register))

s <- mx.api::mx_session(
  server = "https://example/",
  token = "tok",
  user_id = "@u:example",
  device_id = "DEV"
)
expect_inherits(s, "mx_session")
expect_equal(s$server, "https://example")
expect_equal(s$token, "tok")

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  s <- mx.api::mx_login(
    Sys.getenv("MX_TEST_SERVER"),
    Sys.getenv("MX_TEST_USER"),
    Sys.getenv("MX_TEST_PASS")
  )
  expect_inherits(s, "mx_session")
  wid <- mx.api::mx_whoami(s)
  expect_equal(wid$user_id, s$user_id)
  mx.api::mx_logout(s)
}

# --- print.mx_session masks the access token ---

sess <- mx.api::mx_session("https://matrix.example", "syt_supersecret",
                           "@alice:matrix.example", "ABC123")
out <- paste(capture.output(print(sess)), collapse = "\n")
expect_false(grepl("syt_supersecret", out, fixed = TRUE))
expect_true(grepl("token:\\s+<hidden>", out))
# everything else stays readable
expect_true(grepl("@alice:matrix.example", out, fixed = TRUE))
expect_true(grepl("ABC123", out, fixed = TRUE))
expect_true(grepl("https://matrix.example", out, fixed = TRUE))
# an empty token reads as unset, so "is my token loaded?" stays answerable
empty <- mx.api::mx_session("https://matrix.example", "",
                            "@alice:matrix.example", "ABC123")
expect_true(grepl("token:\\s+<unset>", paste(capture.output(print(empty)),
                                             collapse = "\n")))
# returns the session unchanged, and invisibly
capture.output(vis <- withVisible(print(sess)))
expect_false(vis$visible)
expect_identical(vis$value, sess)
