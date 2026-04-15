library(tinytest)

expect_true(is.function(mx.api::mx_upload))
expect_true(is.function(mx.api::mx_download))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live upload/download round-trip goes here
}
