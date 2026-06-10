% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_set_account_data}
\alias{mx_set_account_data}
\title{Set account data}
\usage{
mx_set_account_data(session, type, content, user_id = session$user_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{type}{Character. Event type, e.g. \code{"m.direct"}.}

\item{content}{List. The content, sent as-is.}

\item{user_id}{Character. Defaults to the session's own user.}
}
\value{
Invisibly TRUE on success.
}
\description{
Writes a global account-data event for a user. The content replaces
whatever was stored under \code{type}.
}
\examples{
\dontrun{
mx_set_account_data(s, "ai.cornball.notes", list(theme = "dark"))
}
}
