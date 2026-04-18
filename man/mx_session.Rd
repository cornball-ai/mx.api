% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_session}
\alias{mx_session}
\title{Reconstruct a session from saved credentials}
\usage{
mx_session(server, token, user_id, device_id)
}
\arguments{
\item{server}{Character. Homeserver base URL.}

\item{token}{Character. Access token from a prior login.}

\item{user_id}{Character. Full Matrix ID (e.g. "@troy:example.org").}

\item{device_id}{Character. Device id from the prior login.}
}
\value{
An object of class "mx_session".
}
\description{
Reconstruct a session from saved credentials
}
\examples{
s <- mx_session(
    server = "https://matrix.example",
    token = "syt_...",
    user_id = "@alice:matrix.example",
    device_id = "ABC123"
)
}
