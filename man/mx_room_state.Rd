% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_state}
\alias{mx_room_state}
\title{Get the full current state of a room}
\usage{
mx_room_state(session, room_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}
}
\value{
A list of state events.
}
\description{
Returns every current state event of a room, one list per event with
\code{type}, \code{state_key}, \code{sender}, \code{content},
\code{origin_server_ts} and \code{event_id}. Unlike
\code{\link{mx_get_state}} this covers all state keys of a type, which
is how per-device state such as call memberships is found.
}
\examples{
\dontrun{
state <- mx_room_state(s, "!abc:example")
Filter(function(ev) ev$type == "m.room.member", state)
}
}
