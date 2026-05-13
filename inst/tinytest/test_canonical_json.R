library(tinytest)

cj <- mx.api::mx_canonical_json

# =========================================================================
# Scalars
# =========================================================================

expect_equal(cj(NULL), "null")
expect_equal(cj(TRUE), "true")
expect_equal(cj(FALSE), "false")
expect_equal(cj(""), "\"\"")
expect_equal(cj("hi"), "\"hi\"")

# =========================================================================
# Numbers — Matrix canonical JSON allows only integers in
# [-(2^53)+1, (2^53)-1]. Float values are explicitly forbidden by the
# spec, so the encoder must REJECT any non-integer numeric input rather
# than serialise it as a decimal.
# =========================================================================

# integer L
expect_equal(cj(0L), "0")
expect_equal(cj(42L), "42")
expect_equal(cj(-7L), "-7")

# numeric (double) that happens to be integer-valued must serialise
# without a decimal place — "1" not "1.0"
expect_equal(cj(0), "0")
expect_equal(cj(1), "1")
expect_equal(cj(1.0), "1")
expect_equal(cj(-1), "-1")
expect_equal(cj(-0), "0")        # spec: "-0 MUST NOT appear" in output

# Non-integer doubles MUST error (spec: "Float values are not permitted
# by this encoding"). Previously these silently produced "1.5", which
# would have signed a non-canonical payload.
expect_error(cj(1.5),  pattern = "non-integer")
expect_error(cj(-1.5), pattern = "non-integer")
expect_error(cj(0.5),  pattern = "non-integer")
expect_error(cj(0.1),  pattern = "non-integer")
expect_error(cj(0.1 + 0.2), pattern = "non-integer")
expect_error(cj(c(1, 1.5)), pattern = "non-integer")  # one bad value in a vector

# Integers within the safe range succeed; values past it must error.
expect_equal(cj(2^53 - 1), "9007199254740991")
expect_equal(cj(-(2^53 - 1)), "-9007199254740991")
expect_error(cj(2^53),    pattern = "out of")
expect_error(cj(-(2^53)), pattern = "out of")
expect_error(cj(1e16),    pattern = "out of")  # 10^16 > 2^53-1

# Integers below 2^53 still must not use scientific notation
expect_false(grepl("e", cj(1e10), fixed = TRUE))
expect_false(grepl("E", cj(1e10), fixed = TRUE))
expect_equal(cj(1e10), "10000000000")
expect_equal(cj(1e15), "1000000000000000")

# rejected number sentinels
expect_error(cj(NA))
expect_error(cj(NA_real_))
expect_error(cj(NA_integer_))
expect_error(cj(NaN))
expect_error(cj(Inf))
expect_error(cj(-Inf))
expect_error(cj(c(1, NaN)))
expect_error(cj(c(1, Inf)))

# rejected character / logical sentinels
expect_error(cj(NA_character_))
expect_error(cj(c("a", NA_character_)))

# =========================================================================
# String escaping
# =========================================================================

# Required JSON escapes
expect_equal(cj("a\"b"), "\"a\\\"b\"")        # quote
expect_equal(cj("a\\b"), "\"a\\\\b\"")        # backslash
expect_equal(cj("a\bb"), "\"a\\bb\"")         # \b (backspace, 0x08)
expect_equal(cj("a\fb"), "\"a\\fb\"")         # \f (form feed, 0x0C)
expect_equal(cj("a\nb"), "\"a\\nb\"")         # \n
expect_equal(cj("a\rb"), "\"a\\rb\"")         # \r
expect_equal(cj("a\tb"), "\"a\\tb\"")         # \t

# Backslash + quote together — easy to break with the wrong gsub order
expect_equal(cj("\\\""), "\"\\\\\\\"\"")      # input: \ "    output: " \ \ \ " "

# Forward slash MUST NOT be escaped (RFC 8259 allows but doesn't require;
# Matrix spec follows the unescaped form, and signers care about exact bytes)
expect_equal(cj("a/b"), "\"a/b\"")
expect_equal(cj("https://matrix.example/path"),
             "\"https://matrix.example/path\"")

# DEL (0x7F) is NOT a JSON control char and must NOT be escaped
expect_equal(cj(intToUtf8(0x7F)),
             paste0("\"", intToUtf8(0x7F), "\""))

# All low control chars 0x01-0x1F escape correctly
expect_equal(cj(intToUtf8(0x01)), "\"\\u0001\"")        # SOH
expect_equal(cj(intToUtf8(0x07)), "\"\\u0007\"")        # BEL
expect_equal(cj(intToUtf8(0x08)), "\"\\b\"")            # BS (named)
expect_equal(cj(intToUtf8(0x09)), "\"\\t\"")            # HT (named)
expect_equal(cj(intToUtf8(0x0A)), "\"\\n\"")            # LF (named)
expect_equal(cj(intToUtf8(0x0B)), "\"\\u000b\"")        # VT
expect_equal(cj(intToUtf8(0x0C)), "\"\\f\"")            # FF (named)
expect_equal(cj(intToUtf8(0x0D)), "\"\\r\"")            # CR (named)
expect_equal(cj(intToUtf8(0x0E)), "\"\\u000e\"")        # SO
expect_equal(cj(intToUtf8(0x1F)), "\"\\u001f\"")        # US

# Multiple control chars in one string, mixed with text
expect_equal(
  cj(paste0("x", intToUtf8(0x01), "y", intToUtf8(0x02), "z")),
  "\"x\\u0001y\\u0002z\""
)

# =========================================================================
# Unicode — non-ASCII passes through as raw UTF-8, no \u escapes
# =========================================================================

# BMP (two-byte UTF-8): "café" with composed é = U+00E9 (UTF-8: C3 A9)
cafe <- "café"
expect_equal(charToRaw(cj(cafe)),
             as.raw(c(0x22, charToRaw(enc2utf8(cafe)), 0x22)))

# BMP (three-byte UTF-8): U+20AC EURO SIGN = E2 82 AC
euro <- intToUtf8(0x20AC)
expect_equal(charToRaw(cj(euro)),
             as.raw(c(0x22, 0xE2, 0x82, 0xAC, 0x22)))

# Supplementary plane (four-byte UTF-8): U+1F980 CRAB = F0 9F A6 80
crab <- intToUtf8(0x1F980)
expect_equal(charToRaw(cj(crab)),
             as.raw(c(0x22, 0xF0, 0x9F, 0xA6, 0x80, 0x22)))

# Combining sequence: "e" + U+0301 COMBINING ACUTE ACCENT (decomposed é)
# Both codepoints must round-trip; we do not normalize (Matrix spec does
# not require NFC).
decomp <- intToUtf8(c(0x65, 0x0301))
expect_equal(charToRaw(cj(decomp)),
             as.raw(c(0x22, charToRaw(enc2utf8(decomp)), 0x22)))

# Mixed ASCII + supplementary in one string
expect_equal(charToRaw(cj(paste0("hi ", crab, "!"))),
             as.raw(c(0x22, charToRaw(enc2utf8("hi ")),
                      0xF0, 0x9F, 0xA6, 0x80,
                      charToRaw(enc2utf8("!")), 0x22)))

# =========================================================================
# Arrays
# =========================================================================

# unnamed lists are arrays
expect_equal(cj(list()), "[]")
expect_equal(cj(list(1L)), "[1]")
expect_equal(cj(list(1L, 2L, 3L)), "[1,2,3]")
expect_equal(cj(list("a", "b")), "[\"a\",\"b\"]")
expect_equal(cj(list(TRUE, FALSE, NULL)), "[true,false,null]")

# length>1 atomic vectors are arrays
expect_equal(cj(c(1L, 2L)), "[1,2]")
expect_equal(cj(c("a", "b")), "[\"a\",\"b\"]")
expect_equal(cj(c(TRUE, FALSE)), "[true,false]")

# length-1 list forces an array (the documented escape hatch)
expect_equal(cj(list(1L)), "[1]")
expect_equal(cj(list("a")), "[\"a\"]")
# vs. length-1 atomic, which is a scalar
expect_equal(cj(1L), "1")
expect_equal(cj("a"), "\"a\"")

# mixed-type array
expect_equal(
  cj(list(1L, "two", TRUE, NULL, FALSE)),
  "[1,\"two\",true,null,false]"
)

# array of objects with their own keys to sort
expect_equal(
  cj(list(list(b = 2L, a = 1L), list(d = 4L, c = 3L))),
  "[{\"a\":1,\"b\":2},{\"c\":3,\"d\":4}]"
)

# I() (AsIs) forces array encoding regardless of underlying length,
# matching jsonlite. Names on the underlying value are dropped.
expect_equal(cj(I(1L)), "[1]")
expect_equal(cj(I("a")), "[\"a\"]")
expect_equal(cj(I(TRUE)), "[true]")
expect_equal(cj(I(c(1L, 2L, 3L))), "[1,2,3]")
expect_equal(cj(I(c("x", "y"))), "[\"x\",\"y\"]")
expect_equal(cj(I(list(a = 1L, b = 2L))), "[1,2]")   # names dropped
expect_equal(cj(I(list())), "[]")
# Per-element validation still applies under I().
expect_error(cj(I(NA)),         pattern = "NA disallowed")
expect_error(cj(I(c(1, NaN))),  pattern = "NA/NaN/Inf disallowed")
expect_error(cj(I(c(1, 1.5))),  pattern = "non-integer")

# =========================================================================
# Objects and key sorting
# =========================================================================

# empty named list — character(0) names means "{}", NULL names means "[]"
expect_equal(cj(structure(list(), names = character(0))), "{}")
expect_equal(cj(list()), "[]")

# basic sorting
expect_equal(cj(list(b = 2L, a = 1L)), "{\"a\":1,\"b\":2}")
expect_equal(
  cj(list(z = "z", a = "a", m = "m")),
  "{\"a\":\"a\",\"m\":\"m\",\"z\":\"z\"}"
)

# mixed-length keys (lexicographic, not by length)
expect_equal(
  cj(list(b = 1L, aaa = 2L, aa = 3L)),
  "{\"aa\":3,\"aaa\":2,\"b\":1}"
)

# Sorting is locale-independent (UTF-8 byte order). Uppercase letters
# (0x41-0x5A) sort BEFORE lowercase (0x61-0x7A) in codepoint order; a
# locale-aware sort can interleave them. Test the failure mode directly.
expect_equal(
  cj(list(b = 1L, A = 2L, a = 3L, B = 4L)),
  "{\"A\":2,\"B\":4,\"a\":3,\"b\":1}"
)

# Special characters in keys, with codepoint ordering verified by hand:
# '!' = 0x21, '.' = 0x2E, '0' = 0x30, '@' = 0x40, '_' = 0x5F, 'a' = 0x61
expect_equal(
  cj(list(`a` = 1L, `_id` = 2L, `@user` = 3L, `0n` = 4L,
          `.dot` = 5L, `!bang` = 6L)),
  paste0("{",
         "\"!bang\":6,",
         "\".dot\":5,",
         "\"0n\":4,",
         "\"@user\":3,",
         "\"_id\":2,",
         "\"a\":1",
         "}")
)

# Unicode keys: 'z' (0x7A) < 'à' (U+00E0) by both codepoint and UTF-8
zlist <- list(1L, 2L)
names(zlist) <- c("z", "à")
expect_equal(cj(zlist), "{\"z\":1,\"à\":2}")

# Deeply nested sorted objects
expect_equal(
  cj(list(
    z = list(b = 1L, a = 2L),
    a = list(y = 3L, x = list(p = list(q = 4L, r = 5L), o = 6L))
  )),
  paste0("{",
         "\"a\":{\"x\":{\"o\":6,\"p\":{\"q\":4,\"r\":5}},\"y\":3},",
         "\"z\":{\"a\":2,\"b\":1}",
         "}")
)

# Object containing arrays of objects, both ends needing sort
expect_equal(
  cj(list(b = list(list(d = 1L, c = 2L)), a = "x")),
  "{\"a\":\"x\",\"b\":[{\"c\":2,\"d\":1}]}"
)

# NULL field in a named list emits "key":null (not dropped)
expect_equal(
  cj(list(a = NULL, b = 1L)),
  "{\"a\":null,\"b\":1}"
)

# NA object keys must be rejected (would silently coerce to the literal
# string "NA" otherwise).
l <- list(1L, 2L)
names(l) <- c("a", NA_character_)
expect_error(cj(l), pattern = "NA in object keys")

# Duplicate object keys must be rejected (RFC 8259 leaves duplicate
# behavior undefined; signing two values under the same key is a recipe
# for ambiguity).
expect_error(cj(list(a = 1L, a = 2L)), pattern = "duplicate object key")
expect_error(
  cj(list(a = 1L, b = 2L, a = 3L)),
  pattern = "duplicate object key"
)
# Duplicate detection runs after UTF-8 normalisation, so byte-identical
# keys with different R encodings still collide.
dup <- list(1L, 2L)
names(dup) <- enc2utf8(c("café", "café"))
expect_error(cj(dup), pattern = "duplicate object key")

# =========================================================================
# Matrix /keys/upload signing payload — full realistic shape
# =========================================================================

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

# Same payload with a signatures block already attached: signing happens
# on the object minus signatures/unsigned, but cj() itself just emits
# what it's handed — verify the user_id key's '@' sorts before letters.
signed <- dk
signed$signatures <- list(
  `@alice:example.org` = list(`ed25519:ABCD` = "SIGSIGSIG")
)
out2 <- cj(signed)
expect_true(grepl("\"signatures\":\\{", out2))
# '@' (0x40) < lowercase letters, so signatures comes before user_id
expect_true(
  regexpr("\"signatures\"", out2, fixed = TRUE) <
  regexpr("\"user_id\"", out2, fixed = TRUE)
)
