% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_send_media}
\alias{mx_send_media}
\alias{mx_send_file}
\alias{mx_send_image}
\alias{mx_send_audio}
\alias{mx_send_video}
\title{Send a media file to a room}
\usage{
mx_send_media(session, room_id, path, body = basename(path),
              msgtype = "m.file", content_type = NULL, info = list())

mx_send_file(session, room_id, path, body = basename(path),
             content_type = NULL, info = list())

mx_send_image(session, room_id, path, body = basename(path),
              content_type = NULL, info = list())

mx_send_audio(session, room_id, path, body = basename(path),
              content_type = NULL, info = list())

mx_send_video(session, room_id, path, body = basename(path),
              content_type = NULL, info = list())
}
\arguments{
\item{session}{An "mx_session" object.}

\item{room_id}{Character. The room ID.}

\item{path}{Character. Path to the file to upload.}

\item{body}{Character. Message body / filename shown by clients.}

\item{msgtype}{Character. One of \code{"m.file"}, \code{"m.image"},
\code{"m.audio"}, \code{"m.video"}.}

\item{content_type}{Character or NULL. MIME type (guessed from the
extension when NULL).}

\item{info}{List. Extra fields merged into the \code{info} object.}
}
\value{
The event ID of the sent message.
}
\description{
Uploads \code{path} to the media repository and posts an
\code{m.room.message} referencing it. The default \code{info} carries
\code{mimetype} and \code{size}; pass richer metadata (width, height,
duration) yourself -- mx.api deliberately does not inspect media files.
}
\examples{
\dontrun{
mx_send_media(s, "!abc:example", "clip.mp4", msgtype = "m.video")
}
}
