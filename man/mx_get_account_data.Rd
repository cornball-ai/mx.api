% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_get_account_data}
\alias{mx_get_account_data}
\title{Get account data}
\usage{
mx_get_account_data(session, type, user_id = session$user_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{type}{Character. Event type, e.g. \code{"m.direct"}.}

\item{user_id}{Character. Defaults to the session's own user.}
}
\value{
The account-data content as a list, or NULL when the type has
  never been set.
}
\description{
Reads a global account-data event for a user, e.g. \code{"m.direct"}
(the DM room map) or any custom namespaced type.
}
\examples{
\dontrun{
direct <- mx_get_account_data(s, "m.direct")
}
}
