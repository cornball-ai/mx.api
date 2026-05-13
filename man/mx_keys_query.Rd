% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_keys_query}
\alias{mx_keys_query}
\title{Query device keys for one or more users}
\usage{
mx_keys_query(session, device_keys, timeout = 10000L, token = NULL)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{device_keys}{Named list. Names are Matrix user ids
(e.g. \code{"@@alice:example.org"}); values are character vectors
of device ids, or \code{character(0)} for "all devices".}

\item{timeout}{Integer milliseconds. Time the server should wait
for remote homeservers before returning a partial result.}

\item{token}{Character or NULL. \code{since}-style sync token from
the prior key-query, when iterating.}
}
\value{
Parsed response with a \code{device_keys} map of
  \code{user_id -> device_id -> device_keys_object}.
}
\description{
POST \code{/_matrix/client/v3/keys/query}. Each entry in
\code{device_keys} maps a Matrix user id to a character vector of
device ids to request. An empty character vector requests all of
the user's devices.
}
\examples{
\dontrun{
mx_keys_query(s, list("@alice:example.org" = character()))
}
}
