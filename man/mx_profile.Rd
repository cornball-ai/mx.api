% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_profile}
\alias{mx_profile}
\title{Get a user's profile}
\usage{
mx_profile(session, user_id = session$user_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{user_id}{Character. Defaults to the session's own user.}
}
\value{
A list with \code{displayname} and \code{avatar_url} (either
  may be absent when unset).
}
\description{
Get a user's profile
}
\examples{
\dontrun{
mx_profile(s)$displayname
}
}
