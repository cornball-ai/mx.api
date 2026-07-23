% tinyrox says don't edit this manually, but it can't stop you!
\name{print.mx_session}
\alias{print.mx_session}
\title{Print a Matrix session}
\usage{
\method{print}{mx_session}(x, ...)
}
\arguments{
\item{x}{An "mx_session" object.}

\item{...}{Ignored.}
}
\value{
\code{x}, invisibly.
}
\description{
Prints the session with the access token masked, so that an
interactive session, a screenshot, or a pasted bug report does not
leak it. The token shows as \code{<hidden>} when set and
\code{<unset>} when empty; every other field prints as-is. Use
\code{unclass(x)} when the raw token is genuinely needed.
}
\examples{
s <- mx_session(
    server = "https://matrix.example",
    token = "syt_secret_value",
    user_id = "@alice:matrix.example",
    device_id = "ABC123"
)
s
}
