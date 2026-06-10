# mx.api 0.3.0

* Generic room-event and state plumbing: `mx_send_event()` sends any
  event type (e.g. `m.room.encrypted`), `mx_set_state()` /
  `mx_get_state()` write and read state events (e.g.
  `m.room.encryption`). Together these are what an external
  end-to-end-encryption layer (such as 'mx.client') needs.
* Media messages: `mx_send_media()` uploads a file and posts the
  referencing `m.room.message`, deriving m.image/m.audio/m.video from
  the MIME type by default; `mx_send_file()`, `mx_send_image()`,
  `mx_send_audio()`, and `mx_send_video()` fix the msgtype explicitly.
  Metadata beyond mimetype and size is caller-supplied; mx.api does not
  inspect media files. `mx_guess_mime()` is now exported, and
  `mx_media_config()` reports the server's upload cap.
* `mx_upload()` streams files from disk instead of reading them into
  memory, and `mx_guess_mime()` falls back to octet-stream on unknown
  extensions as documented (was NA).
* HTTP failures signal classed conditions
  (`mx_error_<ERRCODE>` / `mx_error`) carrying `$errcode`, `$status`,
  and the parsed `$body`, so callers can react to specific failures
  without parsing message strings. Message text is unchanged.
* Bot lifecycle endpoints: `mx_room_invite()` (invite into an existing
  room), `mx_redact()` (Matrix deletion), `mx_typing()` (typing
  indicator), and profile helpers `mx_profile()`,
  `mx_set_displayname()`, `mx_set_avatar_url()`.
* Account data: `mx_get_account_data()` / `mx_set_account_data()`,
  kept generic (no DM-semantics helpers).
* Devices: `mx_devices()` lists; `mx_delete_device()` deletes, passing
  any user-interactive auth payload through verbatim.

# mx.api 0.2.0

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
