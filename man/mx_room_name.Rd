% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_name}
\alias{mx_room_name}
\title{Get a room's human-readable name}
\usage{
mx_room_name(session, room_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}
}
\value{
Character scalar or NULL.
}
\description{
Reads the \code{m.room.name} state event. Returns NULL if the room
has no name set or the state event is inaccessible.
}
\examples{
\dontrun{
mx_room_name(s, "!abc:matrix.example")
}
}
