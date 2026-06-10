% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_devices}
\alias{mx_devices}
\title{List this account's devices}
\usage{
mx_devices(session)
}
\arguments{
\item{session}{An "mx_session" object.}
}
\value{
A list of devices, each with \code{device_id},
  \code{display_name}, \code{last_seen_ip}, and \code{last_seen_ts}.
}
\description{
List this account's devices
}
\examples{
\dontrun{
vapply(mx_devices(s), function(d) d$device_id, character(1))
}
}
