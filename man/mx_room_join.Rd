% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_join}
\alias{mx_room_join}
\title{Join a room by ID or alias}
\usage{
mx_room_join(session, room)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room}{Character. Room ID (!abc:server) or alias (#name:server).}
}
\value{
The joined room ID.
}
\description{
Join a room by ID or alias
}
\examples{
\dontrun{
mx_room_join(s, "#general:matrix.example")
}
}
