% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_openid_token}
\alias{mx_openid_token}
\title{Request an OpenID token for this user}
\usage{
mx_openid_token(session)
}
\arguments{
\item{session}{An "mx_session" object.}
}
\value{
A list with \code{access_token}, \code{token_type},
  \code{matrix_server_name} and \code{expires_in} (seconds), exactly as
  the server returned them: a relying party expects the object whole.
}
\description{
An OpenID token lets a third-party service confirm this user's
identity with the homeserver (via the federation
\code{openid/userinfo} endpoint) without seeing the access token.
MatrixRTC clients hand it to the LiveKit JWT service in exchange for a
room-scoped media token.
}
\examples{
\dontrun{
tok <- mx_openid_token(s)
tok$matrix_server_name
}
}
