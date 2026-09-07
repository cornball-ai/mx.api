library(tinytest)

# Smoke: functions exist with the expected signatures.
expect_true(is.function(mx.api::mx_keys_upload))
expect_true(is.function(mx.api::mx_keys_device_signing_upload))
expect_true(is.function(mx.api::mx_keys_signatures_upload))
expect_true(is.function(mx.api::mx_keys_query))
expect_true(is.function(mx.api::mx_keys_claim))
expect_true(is.function(mx.api::mx_send_to_device))
expect_equal(names(formals(mx.api::mx_keys_device_signing_upload)),
             c("session", "master_key", "self_signing_key", "user_signing_key", "auth"))
expect_equal(names(formals(mx.api::mx_keys_signatures_upload)), c("session", "signatures"))

expect_equal(
  names(formals(mx.api::mx_keys_upload)),
  c("session", "device_keys", "one_time_keys", "fallback_keys")
)
expect_equal(
  names(formals(mx.api::mx_keys_query)),
  c("session", "device_keys", "timeout")
)
expect_equal(
  names(formals(mx.api::mx_keys_claim)),
  c("session", "one_time_keys", "timeout")
)
expect_equal(
  names(formals(mx.api::mx_send_to_device)),
  c("session", "event_type", "messages", "txn_id")
)

# Input validation (no network)
fake <- mx.api::mx_session(
  server = "https://example",
  token = "tok",
  user_id = "@u:example",
  device_id = "DEV"
)
expect_error(mx.api::mx_keys_upload(fake))  # nothing to upload
expect_error(mx.api::mx_keys_device_signing_upload(fake))
expect_error(mx.api::mx_keys_device_signing_upload(
  fake, auth = list(type = "m.login.password")
))
expect_error(mx.api::mx_keys_signatures_upload(fake, list()))
expect_error(mx.api::mx_keys_query(fake, device_keys = "not a list"))
expect_error(mx.api::mx_keys_claim(fake, one_time_keys = list()))  # unnamed
expect_error(mx.api::mx_send_to_device(fake, "m.room.encrypted",
                                       messages = list()))  # unnamed

# Endpoint bodies are passed through exactly, including UIA on the retry.
local({
  ns <- asNamespace("mx.api")
  original <- get("mx_http", envir = ns, inherits = FALSE)
  calls <- list()
  assignInNamespace("mx_http", function(base_url, method, path, body = NULL,
                                         query = NULL, token = NULL) {
    calls[[length(calls) + 1L]] <<- list(base_url = base_url, method = method,
                                         path = path, body = body, token = token)
    list(failures = list())
  }, ns = "mx.api")
  on.exit(assignInNamespace("mx_http", original, ns = "mx.api"), add = TRUE)

  master <- list(user_id = "@u:example", usage = list("master"),
                 keys = list("ed25519:master" = "master"))
  auth <- list(type = "m.login.password", session = "uia-1",
               identifier = list(type = "m.id.user", user = "u"),
               password = "secret")
  mx_keys_device_signing_upload(fake, master_key = master, auth = auth)
  expect_identical(calls[[1]]$method, "POST")
  expect_identical(calls[[1]]$path,
                   "/_matrix/client/v3/keys/device_signing/upload")
  expect_identical(calls[[1]]$body$master_key, master)
  expect_identical(calls[[1]]$body$auth, auth)
  expect_identical(calls[[1]]$token, "tok")

  signed <- list("@u:example" = list(DEV = list(device_id = "DEV")))
  mx_keys_signatures_upload(fake, signed)
  expect_identical(calls[[2]]$method, "POST")
  expect_identical(calls[[2]]$path,
                   "/_matrix/client/v3/keys/signatures/upload")
  expect_identical(calls[[2]]$body, signed)
})

# Live round-trip gated on at_home() + env vars. Reuses mx.crypto if
# present so the upload payload is real (signed) — falls back to a
# format-only smoke test otherwise.
if (at_home() && nzchar(Sys.getenv("MX_TEST_SERVER"))) {
  s <- mx.api::mx_login(
    Sys.getenv("MX_TEST_SERVER"),
    Sys.getenv("MX_TEST_USER"),
    Sys.getenv("MX_TEST_PASS")
  )
  on.exit(try(mx.api::mx_logout(s), silent = TRUE), add = TRUE)

  if (requireNamespace("mx.crypto", quietly = TRUE)) {
    acct <- mx.crypto::mxc_account_new()
    ids <- mx.crypto::mxc_account_identity_keys(acct)
    did <- s$device_id

    dk_unsigned <- list(
      user_id = s$user_id,
      device_id = did,
      algorithms = list("m.olm.v1.curve25519-aes-sha2",
                        "m.megolm.v1.aes-sha2"),
      keys = setNames(
        list(ids$curve25519, ids$ed25519),
        c(paste0("curve25519:", did), paste0("ed25519:", did))
      )
    )
    sig <- mx.crypto::mxc_account_sign(
      acct, mx.api::mx_canonical_json(dk_unsigned)
    )
    dk <- dk_unsigned
    dk$signatures <- setNames(
      list(setNames(list(sig), paste0("ed25519:", did))),
      s$user_id
    )

    mx.crypto::mxc_account_generate_one_time_keys(acct, 3L)
    otks <- mx.crypto::mxc_account_one_time_keys(acct)
    signed_otks <- list()
    for (kid in names(otks)) {
      u <- list(key = otks[[kid]])
      ss <- mx.crypto::mxc_account_sign(acct, mx.api::mx_canonical_json(u))
      signed <- u
      signed$signatures <- setNames(
        list(setNames(list(ss), paste0("ed25519:", did))),
        s$user_id
      )
      signed_otks[[paste0("signed_curve25519:", kid)]] <- signed
    }

    resp <- mx.api::mx_keys_upload(
      s, device_keys = dk, one_time_keys = signed_otks
    )
    expect_true(!is.null(resp$one_time_key_counts))
    expect_true(resp$one_time_key_counts$signed_curve25519 >= 3L)

    q <- mx.api::mx_keys_query(s, setNames(list(did), s$user_id))
    expect_true(!is.null(q$device_keys[[s$user_id]][[did]]))

    # Self-claim: works on most homeservers and avoids needing a second user.
    cl <- mx.api::mx_keys_claim(
      s, setNames(list(setNames(list("signed_curve25519"), did)),
                  s$user_id)
    )
    expect_true(!is.null(cl$one_time_keys[[s$user_id]][[did]]))

    # send_to_device to self: harmless empty content.
    mx.api::mx_send_to_device(
      s, "m.test.noop",
      setNames(list(setNames(list(list(ping = "ok")), did)), s$user_id)
    )
  }
}
