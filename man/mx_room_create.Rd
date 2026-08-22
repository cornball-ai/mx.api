% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_room_create}
\alias{mx_room_create}
\title{Create a room}
\usage{
mx_room_create(
  session,
  name = NULL,
  topic = NULL,
  visibility = "private",
  preset = NULL,
  invite = character(),
  creation_content = NULL
)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{name}{Character or NULL. Human-readable room name.}

\item{topic}{Character or NULL. Room topic.}

\item{visibility}{Character. "private" (default) or "public".}

\item{preset}{Character or NULL. A Matrix room preset
("private_chat", "trusted_private_chat", "public_chat").}

\item{invite}{Character vector. Matrix IDs to invite.}

\item{creation_content}{Named list or NULL. Merged into the
\code{m.room.create} event content. This is the only way to set
properties that are fixed at creation and immutable afterwards --
notably \code{type = "m.space"}, which makes the room a space rather
than a conversation. A space cannot be converted from an ordinary
room later, so it has to be requested here or not at all.}
}
\value{
The new room ID as a character string.
}
\description{
Create a room
}
\examples{
\dontrun{
room_id <- mx_room_create(s, name = "test", topic = "hello")

# A space, which holds other rooms instead of messages
space_id <- mx_room_create(s, name = "Topics",
                           creation_content = list(type = "m.space"))
}
}
