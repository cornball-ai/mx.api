% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_read_receipt}
\alias{mx_read_receipt}
\title{Send a read receipt for a room event}
\usage{
mx_read_receipt(session, room_id, event_id,
                receipt_type = c("m.read", "m.read.private"))
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_id}{Character. The event to mark as read.}

\item{receipt_type}{Character. "m.read" (default) or "m.read.private".}
}
\value{
Invisible NULL.
}
\description{
Public receipt (\code{m.read}) advances the "seen" marker in other
clients; private receipt (\code{m.read.private}) only advances the
bot's own view. Defaults to public so user clients show
"seen by @bot".
}
