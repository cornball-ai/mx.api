library(tinytest)

# All live-server tests are gated on at_home() so R CMD check sees no
# network. Locally, set MX_TEST_SERVER / MX_TEST_USER / MX_TEST_PASS to
# run against a real Synapse.

expect_true(is.function(mx.api::mx_login))
expect_true(is.function(mx.api::mx_session))
expect_true(is.function(mx.api::mx_logout))
expect_true(is.function(mx.api::mx_whoami))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live login/logout round-trip goes here
}
