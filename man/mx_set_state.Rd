% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_set_state}
\alias{mx_set_state}
\title{Set a room state event}
\usage{
mx_set_state(session, room_id, event_type, content, state_key = "")
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_type}{Character. State event type, e.g.
\code{"m.room.encryption"}.}

\item{content}{List. The state content, sent as-is.}

\item{state_key}{Character. State key (default empty string).}
}
\value{
The event ID of the state event.
}
\description{
Generic state setter, e.g. to mark a room encrypted by putting an
\code{m.room.encryption} event.
}
\examples{
\dontrun{
mx_set_state(s, "!abc:example", "m.room.encryption",
             list(algorithm = "m.megolm.v1.aes-sha2"))
}
}
