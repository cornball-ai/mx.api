% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_sync}
\alias{mx_sync}
\title{One-shot sync against the homeserver}
\usage{
mx_sync(session, since = NULL, timeout = 0L, filter = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{since}{Character or NULL. Sync token from a prior sync.}

\item{timeout}{Integer. Long-poll timeout in milliseconds (0 returns
immediately).}

\item{filter}{Character or NULL. Filter ID or inline JSON filter.}
}
\value{
The parsed sync response, including next_batch.
}
\description{
Calls /sync once and returns immediately. For streaming behaviour,
the caller writes its own loop, passing the previous batch's
next_batch token as \code{since}.
}
