## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.

## Test environments

* local Ubuntu 24.04, R 4.5.3
* GitHub Actions (ubuntu-latest, macos-latest) via r-ci

## Notes on examples

Every exported function that talks to a homeserver uses `\dontrun{}` rather
than `\donttest{}`. These functions require valid credentials and a running
Matrix homeserver, so they cannot execute under `R CMD check --as-cran`
(which enables `--run-donttest`). `mx_session()` is a pure constructor and
has a runnable example.

## Downstream dependencies

None (new package).
