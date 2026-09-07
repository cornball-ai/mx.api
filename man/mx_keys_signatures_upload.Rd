% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_keys_signatures_upload}
\alias{mx_keys_signatures_upload}
\title{Upload signatures over device or cross-signing keys}
\usage{
mx_keys_signatures_upload(session, signatures)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{signatures}{Named list mapping user ids to signed key objects.}
}
\value{
Parsed response, including any per-signature \code{failures}.
}
\description{
POST \code{/_matrix/client/v3/keys/signatures/upload}. The body maps a
user id to key ids and the complete signed key objects. mx.api transports
the objects unchanged and performs no signature validation itself.
}
\examples{
\dontrun{
mx_keys_signatures_upload(s, list(
    "@bot:example.org" = list(DEVICE = signed_device)))
}
}
