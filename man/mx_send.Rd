% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_send}
\alias{mx_send}
\title{Send a message to a room}
\usage{
mx_send(session, room_id, body, msgtype = "m.text", extra = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{body}{Character. The message body.}

\item{msgtype}{Character. Matrix msgtype, default "m.text".}

\item{extra}{List or NULL. Extra fields merged into the event content
(e.g. formatted body, reply relation).}
}
\value{
The event ID of the sent message.
}
\description{
Send a message to a room
}
\examples{
\dontrun{
mx_send(s, "!abc:matrix.example", "hello world")
}
}
