library(tinytest)

expect_true(is.function(mx.api::mx_send))
expect_true(is.function(mx.api::mx_messages))
expect_true(is.function(mx.api::mx_sync))
expect_true(is.function(mx.api::mx_react))
expect_true(is.function(mx.api::mx_read_receipt))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER")) &&
    nzchar(Sys.getenv("MX_TEST_ROOM"))) {
  s <- mx.api::mx_login(
    Sys.getenv("MX_TEST_SERVER"),
    Sys.getenv("MX_TEST_USER"),
    Sys.getenv("MX_TEST_PASS")
  )
  room <- Sys.getenv("MX_TEST_ROOM")

  eid <- mx.api::mx_send(s, room, "mx.api test")
  expect_true(is.character(eid) && nchar(eid) > 0)

  sync <- mx.api::mx_sync(s, timeout = 0)
  expect_true(!is.null(sync$next_batch))

  mx.api::mx_logout(s)
}
