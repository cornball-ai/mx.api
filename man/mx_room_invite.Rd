% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_invite}
\alias{mx_room_invite}
\title{Invite a user to a room}
\usage{
mx_room_invite(session, room_id, user_id)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{user_id}{Character. The Matrix ID to invite.}
}
\value{
Invisibly TRUE on success.
}
\description{
Invitation at creation time is covered by \code{mx_room_create()};
this covers the other common lifecycle case, inviting into an
existing room.
}
\examples{
\dontrun{
mx_room_invite(s, "!abc:example", "@friend:example.org")
}
}
