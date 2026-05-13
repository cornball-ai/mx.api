# mx.api 0.1.0.1

* New transport endpoints for end-to-end-encryption coordination:
  `mx_keys_upload()`, `mx_keys_query()`, `mx_keys_claim()`, and
  `mx_send_to_device()`. The package itself remains crypto-free; these
  carry already-signed payloads built by an external signer (e.g.
  `mx.crypto`).
* `mx_canonical_json()` produces Matrix-spec canonical JSON, the byte
  sequence callers feed to their signer for `/keys/upload`.

# mx.api 0.1.0

* Initial CRAN release.
* 19 exported functions covering the Matrix Client-Server API:
  login, register, logout, whoami, session reconstruction, room list,
  room create/join/leave, room members, room name/topic, message send
  and history, read receipts, reactions, sync, and media upload/download.
* End-to-end encryption is out of scope.
