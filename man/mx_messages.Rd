% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_messages}
\alias{mx_messages}
\title{Fetch historical messages from a room}
\usage{
mx_messages(session, room_id, from = NULL, dir = "b", limit = 50L)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{from}{Character or NULL. Pagination token; NULL starts at the
most recent message.}

\item{dir}{Character. "b" (backwards, default) or "f" (forwards).}

\item{limit}{Integer. Maximum events to return.}
}
\value{
A list with fields chunk, start, end.
}
\description{
Thin wrapper over the /rooms/\{id\}/messages endpoint.
}
\examples{
\dontrun{
mx_messages(s, "!abc:matrix.example", limit = 20L)
}
}
