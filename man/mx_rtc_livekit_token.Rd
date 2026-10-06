% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_rtc_livekit_token}
\alias{mx_rtc_livekit_token}
\title{Exchange an OpenID token for a LiveKit media token}
\usage{
mx_rtc_livekit_token(service_url, room_id, openid_token, device_id)
}
\arguments{
\item{service_url}{Character. Base URL of the JWT service, from
\code{\link{mx_rtc_transports}} or a call member's
\code{foci_preferred}.}

\item{room_id}{Character. The Matrix room of the call.}

\item{openid_token}{The list returned by \code{\link{mx_openid_token}}.}

\item{device_id}{Character. This device's id.}
}
\value{
A list with \code{url} (the LiveKit server) and \code{jwt}.
}
\description{
Calls a LiveKit JWT service (\code{lk-jwt-service}) the way Element
Call and FluffyChat do: \code{POST <service_url>/sfu/get} with the
Matrix room, this user's OpenID token and device id. The service
verifies the token with the homeserver and answers with the SFU's
WebSocket URL and a room-scoped JWT whose LiveKit identity is
\code{"<user_id>:<device_id>"}.
}
\examples{
\dontrun{
tok <- mx_rtc_livekit_token("https://jwt.example", "!abc:example",
                            mx_openid_token(s), s$device_id)
tok$url
}
}
