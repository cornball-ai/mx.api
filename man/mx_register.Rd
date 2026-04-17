% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_register}
\alias{mx_register}
\title{Register a new account on a Matrix homeserver}
\usage{
mx_register(server, username, password, device_id = NULL,
            initial_device_display_name = NULL, inhibit_login = FALSE)
}
\arguments{
\item{server}{Character. Homeserver base URL.}

\item{username}{Character. Desired localpart (e.g. "alice").}

\item{password}{Character. Account password.}

\item{device_id}{Character or NULL. Device id to assign; a server-
generated one is used if NULL.}

\item{initial_device_display_name}{Character or NULL. Human-readable
label for the device.}

\item{inhibit_login}{Logical. When TRUE, the server creates the
account but does not return a session; the call returns a list
with the new \code{user_id} instead of an \code{mx_session}.}
}
\value{
An \code{mx_session} object on login, or a list with
  \code{user_id} when \code{inhibit_login = TRUE}.
}
\description{
Creates a new user via POST \code{/_matrix/client/v3/register} using
the \code{m.login.dummy} auth flow. Most homeservers only accept this
when open registration is enabled (or a registration token is
supplied). On success returns a ready-to-use \code{mx_session} —
registration also logs the new user in.
}
