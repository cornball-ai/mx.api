% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_keys_claim}
\alias{mx_keys_claim}
\title{Claim one-time keys for an Olm handshake}
\usage{
mx_keys_claim(session, one_time_keys, timeout = 10000L)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{one_time_keys}{Named list. Names are user ids; values are
named lists mapping device ids to the desired algorithm
(typically \code{"signed_curve25519"}).}

\item{timeout}{Integer milliseconds. Server-side timeout when
talking to remote homeservers.}
}
\value{
Parsed response with the claimed keys keyed by
  \code{user_id -> device_id -> "<algorithm>:<key_id>" -> key_object}.
}
\description{
POST \code{/_matrix/client/v3/keys/claim}. The
\code{one_time_keys} argument selects which algorithm to claim for
each \code{(user_id, device_id)} pair.
}
\examples{
\dontrun{
mx_keys_claim(s, list(
  "@alice:example.org" = list(ABCD1234 = "signed_curve25519")
))
}
}
