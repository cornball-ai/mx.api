library(tinytest)

expect_true(is.function(mx.api::mx_rooms))
expect_true(is.function(mx.api::mx_room_create))
expect_true(is.function(mx.api::mx_room_join))
expect_true(is.function(mx.api::mx_room_leave))
expect_true(is.function(mx.api::mx_room_members))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live room create/join/leave round-trip goes here
}
