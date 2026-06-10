library(tinytest)

expect_true(is.function(mx.api::mx_upload))
expect_true(is.function(mx.api::mx_download))

if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  # live upload/download round-trip goes here
}

# Media message helpers: signatures + msgtype routing.
expect_true(is.function(mx.api::mx_send_media))
expect_equal(
  names(formals(mx.api::mx_send_media)),
  c("session", "room_id", "path", "body", "msgtype", "content_type", "info")
)
for (fn in c("mx_send_file", "mx_send_image", "mx_send_audio",
             "mx_send_video")) {
  expect_true(is.function(getExportedValue("mx.api", fn)))
}
