% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_well_known_client}
\alias{mx_well_known_client}
\title{Read a server's client well-known file}
\usage{
mx_well_known_client(server_name)
}
\arguments{
\item{server_name}{Character. The server name part of a Matrix ID,
e.g. \code{"example.org"}, or a URL whose host is used.}
}
\value{
The parsed document as a list, or NULL when there is none.
}
\description{
Fetches \code{https://<server_name>/.well-known/matrix/client}, the
discovery document that names the homeserver's base URL and, for some
deployments, its RTC foci (\code{org.matrix.msc4143.rtc_foci}).
}
\examples{
\dontrun{
mx_well_known_client("example.org")$`m.homeserver`$base_url
}
}
