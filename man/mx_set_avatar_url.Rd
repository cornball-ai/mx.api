% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_set_avatar_url}
\alias{mx_set_avatar_url}
\title{Set this user's avatar}
\usage{
mx_set_avatar_url(session, avatar_url)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{avatar_url}{Character. An \code{mxc://} URI, typically from
\code{\link{mx_upload}}.}
}
\value{
Invisibly TRUE on success.
}
\description{
Set this user's avatar
}
\examples{
\dontrun{
uri <- mx_upload(s, "avatar.png")
mx_set_avatar_url(s, uri)
}
}
