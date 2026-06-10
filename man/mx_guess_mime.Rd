% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_guess_mime}
\alias{mx_guess_mime}
\title{Guess a MIME type from a file extension}
\usage{
mx_guess_mime(path)
}
\arguments{
\item{path}{Character. File path or name.}
}
\value{
Character MIME type.
}
\description{
The extension table mx.api uses for uploads, exported so callers do
not maintain their own. Unknown extensions fall back to
\code{"application/octet-stream"}.
}
\examples{
mx_guess_mime("clip.mp4")
mx_guess_mime("notes.txt")
}
