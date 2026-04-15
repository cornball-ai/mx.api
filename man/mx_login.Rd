% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_login}
\alias{mx_login}
\title{Log in to a Matrix homeserver}
\usage{
mx_login(server, user, password, device_id = NULL)
}
\arguments{
\item{server}{Character. Homeserver base URL (e.g. "https://matrix.example").}

\item{user}{Character. User localpart or full Matrix ID.}

\item{password}{Character. Account password.}

\item{device_id}{Character or NULL. Reuse an existing device id.}
}
\value{
An object of class "mx_session".
}
\description{
Authenticates with a Matrix homeserver using password login and returns
a session object carrying the access token and device id.
}
