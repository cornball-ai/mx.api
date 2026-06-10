% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_redact}
\alias{mx_redact}
\title{Redact an event}
\usage{
mx_redact(session, room_id, event_id, reason = NULL, txn_id = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{event_id}{Character. The event to redact.}

\item{reason}{Character or NULL. Optional human-readable reason.}

\item{txn_id}{Character or NULL. Transaction id (generated if NULL).}
}
\value{
The event ID of the redaction event.
}
\description{
Removes the content of a message, reaction, or other event. This is
how Matrix deletes things.
}
\examples{
\dontrun{
mx_redact(s, "!abc:example", "$someevent", reason = "typo")
}
}
