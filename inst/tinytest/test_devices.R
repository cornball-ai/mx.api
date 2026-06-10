library(tinytest)

expect_true(is.function(mx.api::mx_devices))
expect_true(is.function(mx.api::mx_delete_device))
expect_equal(names(formals(mx.api::mx_devices)), "session")
expect_equal(
  names(formals(mx.api::mx_delete_device)),
  c("session", "device_id", "auth")
)
