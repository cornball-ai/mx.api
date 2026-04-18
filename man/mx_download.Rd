% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_download}
\alias{mx_download}
\title{Download a media file by mxc URI}
\usage{
mx_download(session, mxc_url, dest)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{mxc_url}{Character. An "mxc://server/id" URI.}

\item{dest}{Character. Destination file path.}
}
\value{
The destination path, invisibly.
}
\description{
Download a media file by mxc URI
}
\examples{
\dontrun{
mx_download(s, "mxc://matrix.example/abc123", tempfile())
}
}
