% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_react}
\alias{mx_react}
\title{Send a reaction (annotation) to a room event}
\usage{
mx_react(session, room_id, event_id, key)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_id}{Character. The event being reacted to.}

\item{key}{Character. The reaction key (usually an emoji).}
}
\value{
The event ID of the sent reaction.
}
\description{
Posts an m.reaction event tying \code{key} (usually an emoji like
"\u{1f44d}") to \code{event_id}. Matrix reactions are plain events
under the hood; they relate to the target via \code{m.annotation}.
}
