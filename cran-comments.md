## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local Ubuntu 24.04, R 4.6.1, `R CMD check --as-cran --run-donttest`
* GitHub Actions (ubuntu-latest, macos-latest) via r-ci

## What's new in 0.4.0

This is an update to 0.3.1. It is additive only: no exported function
was removed or renamed, and no exported signature changed.

* New endpoints for 'MatrixRTC' clients: `mx_openid_token()`,
  `mx_rtc_transports()`, `mx_rtc_livekit_token()`, `mx_room_state()`,
  and `mx_well_known_client()`.
* HTTP requests now carry finite deadlines, so a stalled connection
  cannot hold a polling loop indefinitely. Three options set them, in
  seconds: `mx.api.connect_timeout` (default 10),
  `mx.api.request_timeout` (default 60), and `mx.api.media_timeout`
  (default 300). Long-poll requests add their server-side wait to the
  deadline.

## Notes on tests

The timeout tests listen on the loopback interface and connect to that
listener from the test process. They contact no external host and need
no credentials. They run on Unix-alikes and skip elsewhere.

## Notes on examples

Examples that talk to a homeserver continue to use `\dontrun{}`: they
require valid credentials plus a running Matrix homeserver, so they
cannot execute under `R CMD check --as-cran`. Pure functions
(`mx_session()`, `mx_canonical_json()`, `mx_guess_mime()`) have
runnable examples.

## Reverse dependencies

Four on CRAN: mx.client 0.2.1 and chat.api 0.1.0 import this package;
mx.crypto 0.2.2 and corteza 0.7.1 suggest it. I checked the CRAN source
of each against this version with `R CMD check`; all four finish with
Status: OK.
