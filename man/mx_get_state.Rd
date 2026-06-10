% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_get_state}
\alias{mx_get_state}
\title{Get a room state event}
\usage{
mx_get_state(session, room_id, event_type, state_key = "")
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_type}{Character. State event type, e.g.
\code{"m.room.encryption"}.}

\item{state_key}{Character. State key (default empty string).}
}
\value{
The state event content as a list, or NULL when the state
  event is not set.
}
\description{
Read-side counterpart of \code{\link{mx_set_state}}, e.g. to check
whether a room is encrypted before joining the send path.
}
\examples{
\dontrun{
enc <- mx_get_state(s, "!abc:example", "m.room.encryption")
is.null(enc)   # FALSE in an encrypted room
}
}
