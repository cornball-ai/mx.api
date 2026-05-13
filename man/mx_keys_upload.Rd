% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_keys_upload}
\alias{mx_keys_upload}
\title{Upload device identity and one-time keys}
\usage{
mx_keys_upload(session, device_keys = NULL, one_time_keys = NULL,
               fallback_keys = NULL)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{device_keys}{Named list. The \code{device_keys} object as
defined in the Matrix spec, including \code{user_id},
\code{device_id}, \code{algorithms}, \code{keys}, and the
\code{signatures} block produced by the caller's signer. Pass
NULL to upload only one-time keys.}

\item{one_time_keys}{Named list or NULL. Map from
\code{"<algorithm>:<key_id>"} (e.g. \code{"signed_curve25519:AAAA"})
to the signed key object. Pass NULL or an empty list to skip.}

\item{fallback_keys}{Named list or NULL. Same shape as
\code{one_time_keys}; used to advertise a fallback key when the
OTK pool is exhausted.}
}
\value{
The parsed homeserver response, including
  \code{one_time_key_counts}.
}
\description{
POST \code{/_matrix/client/v3/keys/upload}. The \code{device_keys}
and \code{one_time_keys} arguments must be fully formed and signed
per the Matrix specification; mx.api will not canonicalise or sign
them. Use \code{\link{mx_canonical_json}} to produce the byte
sequence to sign.
}
\examples{
\dontrun{
mx_keys_upload(s, device_keys = signed_dk, one_time_keys = signed_otks)
}
}
