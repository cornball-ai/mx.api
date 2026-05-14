# mx.api

A minimal-dependency client for the
[Matrix Client-Server HTTP API](https://spec.matrix.org/), suitable for
talking to a Synapse or Conduit homeserver from R. Two Imports: `curl`
and `jsonlite`. No tidyverse.

Pairs with [`mx.crypto`](https://github.com/cornball-ai/mx.crypto),
which handles Olm + Megolm; mx.api itself does no cryptography.

## Install

```r
# CRAN
install.packages("mx.api")

# GitHub (development version, 0.1.0.1)
remotes::install_github("cornball-ai/mx.api")
```

## Quick start: log in, send, sync

```r
library(mx.api)

s <- mx_login(
    server   = "https://matrix.example",
    user     = "alice",
    password = "hunter2"
)

room <- mx_room_join(s, "#general:matrix.example")
mx_send(s, room, "hello from R")

batch <- mx_sync(s, timeout = 0)
str(batch$rooms$join)

mx_logout(s)
```

## Create a private room with invites

```r
room <- mx_room_create(
    s,
    name   = "project sync",
    topic  = "weekly check-in",
    preset = "private_chat",
    invite = c("@bob:matrix.example", "@carol:matrix.example")
)
mx_send(s, room, "kickoff in 5")
```

`mx_room_create` returns the new room id as a character string.
Presets: `"private_chat"`, `"trusted_private_chat"`, `"public_chat"`.

## What's covered

| Area | Functions |
|---|---|
| Session | `mx_register`, `mx_login`, `mx_logout`, `mx_whoami`, `mx_session` |
| Rooms | `mx_rooms`, `mx_room_create`, `mx_room_join`, `mx_room_leave`, `mx_room_members`, `mx_room_name`, `mx_room_topic` |
| Messages | `mx_send`, `mx_messages`, `mx_sync`, `mx_react`, `mx_read_receipt` |
| Media | `mx_upload`, `mx_download` |
| E2EE transport | `mx_keys_upload`, `mx_keys_query`, `mx_keys_claim`, `mx_send_to_device` |
| E2EE signing helper | `mx_canonical_json` |

End-to-end **cryptography** is out of scope; pair with `mx.crypto`
(or another crypto library) to sign and verify the payloads these
endpoints carry. Helpful framing:

- mx.api speaks Matrix HTTP. It does no signing, no key management,
  no key validation.
- mx.crypto speaks Olm + Megolm. It does no HTTP.
- An integration script that wants encrypted rooms uses both. The
  current reference is `mx.crypto/inst/integration/e2e_demo.R`.

## Canonical JSON

`mx_canonical_json()` is the byte-stable encoder Matrix's signing rules
require. It is hand-rolled (not a jsonlite wrapper) so the
spec-sensitive choices — key ordering by UTF-8 byte sequence, integer
range, NaN/Inf/NA rejection, duplicate-key rejection, control-char
escaping — are visible and unit-tested rather than hidden in another
package's defaults.

```r
mx_canonical_json(list(b = 2, a = 1))
#> [1] "{\"a\":1,\"b\":2}"

mx_canonical_json(1.5)
#> Error: mx_canonical_json: non-integer number 1.5 disallowed
```

97 assertions exercise the encoder (see `inst/tinytest/test_canonical_json.R`).

## Status

**0.1.0.1** dev marker on `main` (2026-05-13). The 0.1.0 release is on
CRAN. The 0.1.0.1 delta is additive:

- New transport endpoints for E2EE coordination:
  `mx_keys_upload`, `mx_keys_query`, `mx_keys_claim`,
  `mx_send_to_device`.
- New `mx_canonical_json` for signature payload encoding.

See `NEWS.md` for the full changelog.

## CI

GitHub Actions via [r-ci](https://github.com/eddelbuettel/r-ci); macOS
and Ubuntu runners cover every commit + PR.

## License

MIT. See `LICENSE`.
