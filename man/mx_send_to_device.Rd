% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_send_to_device}
\alias{mx_send_to_device}
\title{Send a to-device event}
\usage{
mx_send_to_device(session, event_type, messages, txn_id = NULL)
}
\arguments{
\item{session}{An \code{mx_session}.}

\item{event_type}{Character. The to-device event type, e.g.
\code{"m.room.encrypted"}.}

\item{messages}{Named list. Outer names are user ids; values are
named lists mapping device id (or the wildcard \code{"*"}) to
the event content.}

\item{txn_id}{Character or NULL. Idempotency key; auto-generated
when NULL.}
}
\value{
Invisible NULL (the server returns an empty body on success).
}
\description{
PUT \code{/_matrix/client/v3/sendToDevice/{eventType}/{txnId}}.
Used to ship encrypted Olm payloads (e.g. m.room_key carriers
wrapped as \code{m.room.encrypted}) to specific
\code{(user_id, device_id)} targets.
}
\examples{
\dontrun{
mx_send_to_device(s, "m.room.encrypted", list(
  "@bob:example.org" = list(BBBB = encrypted_content)
))
}
}
