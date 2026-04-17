% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_topic}
\alias{mx_room_topic}
\title{Get a room's topic}
\usage{
mx_room_topic(session, room_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}
}
\value{
Character scalar or NULL.
}
\description{
Reads the \code{m.room.topic} state event. Returns NULL if the room
has no topic set or the state event is inaccessible.
}
