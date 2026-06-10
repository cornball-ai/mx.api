% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_send_event}
\alias{mx_send_event}
\title{Send an arbitrary room event}
\usage{
mx_send_event(session, room_id, event_type, content, txn_id = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_type}{Character. The event type, e.g.
\code{"m.room.encrypted"}.}

\item{content}{List. The event content, sent as-is.}

\item{txn_id}{Character or NULL. Transaction id (generated if NULL).}
}
\value{
The event ID of the sent event.
}
\description{
Generic counterpart to \code{\link{mx_send}} for event types other than
\code{m.room.message}, such as \code{m.room.encrypted}. The content is
sent verbatim.
}
\examples{
\dontrun{
mx_send_event(s, "!abc:example", "m.room.encrypted", encrypted_content)
}
}
