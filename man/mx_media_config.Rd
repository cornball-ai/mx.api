% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_media_config}
\alias{mx_media_config}
\title{Query the homeserver's media configuration}
\usage{
mx_media_config(session)
}
\arguments{
\item{session}{An "mx_session" object.}
}
\value{
A list; \code{$`m.upload.size`} is the upload cap in bytes
  (may be absent if the server does not advertise one).
}
\description{
Asks the server for its media limits, chiefly \code{m.upload.size}
(maximum upload bytes), so callers can check a file fits before
uploading. Tries the v1 endpoint and falls back to the legacy
location for older homeservers.
}
\examples{
\dontrun{
cap <- mx_media_config(s)$`m.upload.size`
file.size("clip.mp4") <= cap
}
}
