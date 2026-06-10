## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local Ubuntu 24.04, R 4.6.0
* local Windows 10, R 4.5.1 (1 NOTE: "unable to verify current time",
  an environmental artifact of the offline world-clock check)
* GitHub Actions (ubuntu-latest, macos-latest) via r-ci

## What's new in 0.3.0

Additive only; no changes to the existing 0.2.0 surface.

* Generic room-event and state plumbing: `mx_send_event()`,
  `mx_set_state()`, `mx_get_state()` (what an external
  end-to-end-encryption layer needs to send `m.room.encrypted` events
  and read `m.room.encryption` state).
* Media messages: `mx_send_media()` uploads a file and posts the
  referencing message, deriving the msgtype from the MIME type;
  `mx_send_file()` / `mx_send_image()` / `mx_send_audio()` /
  `mx_send_video()` fix it explicitly. `mx_guess_mime()` is exported;
  `mx_media_config()` reports the server's upload cap. `mx_upload()`
  now streams from disk instead of reading files into memory.
* Bot lifecycle endpoints: `mx_room_invite()`, `mx_redact()`,
  `mx_typing()`, `mx_profile()`, `mx_set_displayname()`,
  `mx_set_avatar_url()`.
* Account data: `mx_get_account_data()` / `mx_set_account_data()`.
* Devices: `mx_devices()`, `mx_delete_device()` (user-interactive auth
  payloads pass through verbatim).
* HTTP failures now signal classed conditions (`mx_error_<ERRCODE>`)
  carrying the Matrix errcode, HTTP status, and parsed body; message
  text is unchanged from previous releases.

## Notes on examples

Examples that talk to a homeserver continue to use `\dontrun{}`: they
require valid credentials plus a running Matrix homeserver, so they
cannot execute under `R CMD check --as-cran`. Pure functions
(`mx_session()`, `mx_canonical_json()`, `mx_guess_mime()`) have
runnable examples.

## Downstream dependencies

None on CRAN.
