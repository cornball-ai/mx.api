% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_typing}
\alias{mx_typing}
\title{Send a typing notification}
\usage{
mx_typing(session, room_id, typing = TRUE, timeout = 30000L)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{typing}{Logical. TRUE to show typing, FALSE to clear it.}

\item{timeout}{Integer. How long the indicator lasts, in
milliseconds (ignored when \code{typing = FALSE}).}
}
\value{
Invisibly TRUE on success.
}
\description{
Shows (or clears) the session user's typing indicator in a room.
Useful bot polish while a slow reply is being generated.
}
\examples{
\dontrun{
mx_typing(s, "!abc:example", TRUE)
# ... generate the reply ...
mx_typing(s, "!abc:example", FALSE)
}
}
