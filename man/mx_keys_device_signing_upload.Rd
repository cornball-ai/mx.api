% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_keys_device_signing_upload}
\alias{mx_keys_device_signing_upload}
\title{Upload cross-signing public keys}
\usage{
mx_keys_device_signing_upload(
  session,
  master_key = NULL,
  self_signing_key = NULL,
  user_signing_key = NULL,
  auth = NULL
)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{master_key}{A signed Matrix CrossSigningKey object or NULL.}

\item{self_signing_key}{A CrossSigningKey signed by the master key, or NULL.}

\item{user_signing_key}{A CrossSigningKey signed by the master key, or NULL.}

\item{auth}{Completed UIA authentication object or NULL.}
}
\value{
Parsed homeserver response.
}
\description{
POST \code{/_matrix/client/v3/keys/device_signing/upload}. The key
objects must already carry the signatures required by the Matrix
cross-signing specification. Homeservers normally require user-interactive
authentication (UIA); the initial 401 response contains a session id which
the caller supplies in a completed \code{auth} object on retry.
}
\examples{
\dontrun{
mx_keys_device_signing_upload(s, master_key = master,
    self_signing_key = self, user_signing_key = user,
    auth = list(type = "m.login.password", session = uia_session,
                identifier = list(type = "m.id.user", user = "bot"),
                password = "secret"))
}
}
