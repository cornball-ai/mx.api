% tinyrox says don't edit this manually, but it can't stop you!
\docType{package}
\name{mx.api-package}
\alias{mx.api}
\alias{mx.api-package}
\title{\packageTitle{mx.api}}
\description{\packageDescription{mx.api}}
\section{Network deadlines}{
Every HTTP request has a connection timeout and a total deadline, including
login, sync, key exchange and media transfers. Options
\code{mx.api.connect_timeout}, \code{mx.api.request_timeout} and
\code{mx.api.media_timeout} set these limits in seconds; defaults are
10, 60 and 300 respectively. Values must be finite and positive.
Sync and federated key lookups add their requested server-side wait to the
request deadline, so a 30-second sync has a 90-second total deadline.
Connection setup remains limited to 10 seconds by default.

Timeouts propagate as curl errors for the caller's retry loop. Requests are
not automatically replayed: a timed-out write may already have succeeded
on the server. A failed download may leave a partial destination file.

}
\section{Package Content}{\packageIndices{mx.api}}
\author{\packageAuthor{mx.api}}
\section{Maintainer}{\packageMaintainer{mx.api}}
