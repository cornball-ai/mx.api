## R CMD check results

0 errors | 0 warnings | 0 notes

## Test environments

* local Ubuntu 24.04, R 4.5.3
* GitHub Actions (ubuntu-latest, macos-latest) via r-ci
* win-builder R-devel and R-release (`tinypkgr::check_win_devel()`)

## What's new in 0.2.0

This is the first feature update after the 0.1.0 initial CRAN release.
The delta is additive: five new exports, no changes to the existing
0.1.0 surface.

* `mx_keys_upload()`, `mx_keys_query()`, `mx_keys_claim()`, and
  `mx_send_to_device()` cover the Matrix Client-Server endpoints used
  to coordinate end-to-end encryption. The package itself remains
  crypto-free; these endpoints carry payloads that an external signer
  produces.
* `mx_canonical_json()` is the byte-stable canonical JSON encoder
  Matrix's signing rules require. It is exercised by 107 tinytest
  assertions covering UTF-8 sort, integer-vs-float, NaN/Inf/NA
  rejection, control-char escaping, duplicate-key rejection, and the
  realistic `/keys/upload` payload shape.
* DESCRIPTION text expanded to mention the new transport surface and
  to add URLs for the named homeserver implementations ('Synapse',
  'Conduit') alongside the existing 'Matrix' specification link.

## Notes on examples

Examples that talk to a homeserver continue to use `\dontrun{}`: they
require valid credentials plus a running Matrix homeserver, so they
cannot execute under `R CMD check --as-cran`. `mx_session()` and
`mx_canonical_json()` are pure functions with runnable examples.

## Downstream dependencies

None on CRAN.
