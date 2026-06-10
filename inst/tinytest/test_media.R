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

# msgtype auto-detection + public mime guesser + media config.
expect_equal(mx.api:::mx_msgtype_for_mime("video/mp4"), "m.video")
expect_equal(mx.api:::mx_msgtype_for_mime("audio/ogg"), "m.audio")
expect_equal(mx.api:::mx_msgtype_for_mime("image/png"), "m.image")
expect_equal(mx.api:::mx_msgtype_for_mime("application/pdf"), "m.file")
expect_equal(mx.api::mx_guess_mime("clip.MP4"), "video/mp4")
expect_equal(mx.api::mx_guess_mime("unknown.xyz"), "application/octet-stream")
expect_true(is.function(mx.api::mx_media_config))
