% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_rtc_transports}
\alias{mx_rtc_transports}
\title{List the homeserver's RTC transports}
\usage{
mx_rtc_transports(session)
}
\arguments{
\item{session}{An "mx_session" object.}
}
\value{
A list of transports, each a list, or an empty list when the
  server advertises none or does not implement the endpoint.
}
\description{
Reads \code{GET /_matrix/client/unstable/org.matrix.msc4143/rtc/transports}
(MSC4143), where a homeserver advertises the media back ends its calls
use. For LiveKit each entry has \code{type} \code{"livekit"} and a
\code{livekit_service_url}, the JWT service that issues media tokens.
}
\examples{
\dontrun{
urls <- vapply(mx_rtc_transports(s), `[[`, "", "livekit_service_url")
}
}
