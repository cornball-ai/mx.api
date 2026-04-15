library(tinytest)

expect_true(is.function(mx.api::mx_send))
expect_true(is.function(mx.api::mx_messages))
expect_true(is.function(mx.api::mx_sync))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live send / messages / sync round-trip goes here
}
