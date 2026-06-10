library(tinytest)

# Smoke: functions exist with the expected signatures.
expect_true(is.function(mx.api::mx_get_state))
expect_true(is.function(mx.api::mx_set_state))
expect_true(is.function(mx.api::mx_get_account_data))
expect_true(is.function(mx.api::mx_set_account_data))

expect_equal(
  names(formals(mx.api::mx_get_state)),
  c("session", "room_id", "event_type", "state_key")
)
expect_equal(
  names(formals(mx.api::mx_set_state)),
  c("session", "room_id", "event_type", "content", "state_key")
)
expect_equal(
  names(formals(mx.api::mx_get_account_data)),
  c("session", "type", "user_id")
)
expect_equal(
  names(formals(mx.api::mx_set_account_data)),
  c("session", "type", "content", "user_id")
)

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live get/set round-trips go here
}
