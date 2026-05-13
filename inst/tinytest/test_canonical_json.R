library(tinytest)

cj <- mx.api::mx_canonical_json

# scalars
expect_equal(cj(NULL), "null")
expect_equal(cj(TRUE), "true")
expect_equal(cj(FALSE), "false")
expect_equal(cj("hi"), "\"hi\"")
expect_equal(cj(0L), "0")
expect_equal(cj(42L), "42")
expect_equal(cj(-7L), "-7")

# string escapes
expect_equal(cj("a\"b"), "\"a\\\"b\"")
expect_equal(cj("a\\b"), "\"a\\\\b\"")
expect_equal(cj("line1\nline2"), "\"line1\\nline2\"")
expect_equal(cj("tab\there"), "\"tab\\there\"")
expect_equal(cj(intToUtf8(1L)), "\"\\u0001\"")

# arrays
expect_equal(cj(list()), "[]")
expect_equal(cj(list(1L, 2L, 3L)), "[1,2,3]")
expect_equal(cj(list("a", "b")), "[\"a\",\"b\"]")
expect_equal(cj(c(1L, 2L)), "[1,2]")
expect_equal(cj(c("a", "b")), "[\"a\",\"b\"]")

# object key sorting
expect_equal(
  cj(list(b = 2L, a = 1L)),
  "{\"a\":1,\"b\":2}"
)
expect_equal(
  cj(list(z = "z", a = "a", m = "m")),
  "{\"a\":\"a\",\"m\":\"m\",\"z\":\"z\"}"
)

# nested objects
expect_equal(
  cj(list(outer = list(b = 2L, a = 1L), c = 3L)),
  "{\"c\":3,\"outer\":{\"a\":1,\"b\":2}}"
)

# empty object
expect_equal(cj(structure(list(), names = character(0))), "{}")

# matrix /keys/upload signing target shape
dk <- list(
  user_id = "@alice:example.org",
  device_id = "ABCD",
  algorithms = list("m.olm.v1.curve25519-aes-sha2",
                    "m.megolm.v1.aes-sha2"),
  keys = list(
    `ed25519:ABCD` = "EEEE",
    `curve25519:ABCD` = "CCCC"
  )
)
out <- cj(dk)
# keys sorted: algorithms, device_id, keys, user_id; inside keys: c before e
expect_equal(
  out,
  paste0(
    "{",
    "\"algorithms\":[\"m.olm.v1.curve25519-aes-sha2\",",
    "\"m.megolm.v1.aes-sha2\"],",
    "\"device_id\":\"ABCD\",",
    "\"keys\":{\"curve25519:ABCD\":\"CCCC\",\"ed25519:ABCD\":\"EEEE\"},",
    "\"user_id\":\"@alice:example.org\"",
    "}"
  )
)

# rejects NA / NaN / Inf
expect_error(cj(NA))
expect_error(cj(NA_character_))
expect_error(cj(NA_integer_))
expect_error(cj(NaN))
expect_error(cj(Inf))
