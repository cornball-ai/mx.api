% tinyrox says don't edit this manually, but it can't stop you!
\name{mx_canonical_json}
\alias{mx_canonical_json}
\title{Encode a value as Matrix canonical JSON}
\usage{
mx_canonical_json(x)
}
\arguments{
\item{x}{An R value: NULL, atomic vector, or list.}
}
\value{
A length-1 character string. Always ASCII-safe to write to
  disk or hand to a signer because non-ASCII content is preserved
  as UTF-8 bytes (jsonlite-style \\uXXXX escaping is not used).
}
\description{
Produces the canonical JSON byte sequence the Matrix specification
requires for signed objects: object keys sorted lexicographically by
Unicode codepoint, no insignificant whitespace, raw UTF-8 for
non-ASCII strings, integer formatting without scientific notation,
and rejection of NaN / Inf / NA. The output is the exact byte
sequence to feed into an ed25519 signer.
R named lists become JSON objects; unnamed lists and length > 1
atomic vectors become arrays. Length-1 atomics become scalars. Pass
a length-1 element through \code{I()} (or wrap in a single-element
list) to force array encoding.
}
\examples{
mx_canonical_json(list(b = 2, a = 1))
# "{\"a\":1,\"b\":2}"

mx_canonical_json(list(key = "abc"))
# "{\"key\":\"abc\"}"

}
