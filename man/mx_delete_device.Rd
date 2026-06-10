% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_delete_device}
\alias{mx_delete_device}
\title{Delete a device}
\usage{
mx_delete_device(session, device_id, auth = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{device_id}{Character. The device to delete.}

\item{auth}{List or NULL. Completed user-interactive auth payload.}
}
\value{
Invisibly TRUE on success.
}
\description{
Removes a device and invalidates its access token. Most homeservers
protect this with user-interactive authentication: the first call
fails with M_FORBIDDEN or a 401 carrying a \code{flows} object, and
the caller retries with a completed \code{auth} payload, e.g.
\code{list(type = "m.login.password", identifier = list(type =
"m.id.user", user = "bot"), password = "...", session = "<from the
401>")}. mx.api deliberately does not automate that exchange.
}
\examples{
\dontrun{
mx_delete_device(s, "OLDDEVICE", auth = list(
    type = "m.login.password",
    identifier = list(type = "m.id.user", user = "bot"),
    password = "secret"
))
}
}
