% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_upload}
\alias{mx_upload}
\title{Upload a file to the homeserver media repository}
\usage{
mx_upload(session, path, content_type = NULL, filename = NULL)
}
\arguments{
\item{session}{An "mx_session" object.}

\item{path}{Character. Local file path.}

\item{content_type}{Character or NULL. MIME type; guessed from the
file extension if NULL.}

\item{filename}{Character or NULL. Filename advertised to the server.}
}
\value{
An "mxc://" URI as a character string.
}
\description{
Upload a file to the homeserver media repository
}
\examples{
\dontrun{
uri <- mx_upload(s, "photo.png")
}
}
