library(tinytest)

# Smoke: profile, invite, redact, typing signatures.
expect_true(is.function(mx.api::mx_profile))
expect_true(is.function(mx.api::mx_set_displayname))
expect_true(is.function(mx.api::mx_set_avatar_url))
expect_true(is.function(mx.api::mx_room_invite))
expect_true(is.function(mx.api::mx_redact))
expect_true(is.function(mx.api::mx_typing))

expect_equal(names(formals(mx.api::mx_profile)), c("session", "user_id"))
expect_equal(
  names(formals(mx.api::mx_redact)),
  c("session", "room_id", "event_id", "reason", "txn_id")
)
expect_equal(
  names(formals(mx.api::mx_typing)),
  c("session", "room_id", "typing", "timeout")
)
expect_equal(
  names(formals(mx.api::mx_room_invite)),
  c("session", "room_id", "user_id")
)
