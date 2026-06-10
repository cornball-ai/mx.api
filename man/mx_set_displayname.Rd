% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_set_displayname}
\alias{mx_set_displayname}
\title{Set this user's display name}
\usage{
mx_set_displayname(session, displayname)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{displayname}{Character. The new display name.}
}
\value{
Invisibly TRUE on success.
}
\description{
Set this user's display name
}
\examples{
\dontrun{
mx_set_displayname(s, "cornelius")
}
}
