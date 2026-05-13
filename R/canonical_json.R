# Canonical JSON per the Matrix spec.
#
# Sort object keys lexicographically by Unicode codepoint, no
# whitespace, UTF-8 bytes for non-ASCII characters, no scientific
# notation, no NaN / Inf / NA. Used by callers that need to sign
# request bodies for /keys/upload and friends.

#' Encode a value as Matrix canonical JSON
#'
#' Produces the canonical JSON byte sequence the Matrix specification
#' requires for signed objects: object keys sorted lexicographically by
#' Unicode codepoint, no insignificant whitespace, raw UTF-8 for
#' non-ASCII strings, integer formatting without scientific notation,
#' and rejection of NaN / Inf / NA. The output is the exact byte
#' sequence to feed into an ed25519 signer.
#'
#' R named lists become JSON objects; unnamed lists and length > 1
#' atomic vectors become arrays. Length-1 atomics become scalars. Pass
#' a length-1 element through \code{I()} (or wrap in a single-element
#' list) to force array encoding.
#'
#' @param x An R value: NULL, atomic vector, or list.
#'
#' @return A length-1 character string. Always ASCII-safe to write to
#'   disk or hand to a signer because non-ASCII content is preserved
#'   as UTF-8 bytes (jsonlite-style \\uXXXX escaping is not used).
#'
#' @examples
#' mx_canonical_json(list(b = 2, a = 1))
#' # "{\"a\":1,\"b\":2}"
#'
#' mx_canonical_json(list(key = "abc"))
#' # "{\"key\":\"abc\"}"
#'
#' @export
mx_canonical_json <- function(x) {
    mx_cj_emit(x)
}

mx_cj_emit <- function(x) {
    if (is.null(x)) {
        return("null")
    }
    if (inherits(x, "AsIs")) {
        x <- unclass(x)
    }
    if (is.list(x)) {
        nm <- names(x)
        if (length(x) == 0L) {
            return(if (is.null(nm)) "[]" else "{}")
        }
        if (is.null(nm)) {
            return(paste0(
                          "[",
                          paste(vapply(x, mx_cj_emit, character(1)), collapse = ","),
                          "]"
                ))
        }
        ord <- order(nm)
        parts <- vapply(ord, function(i) {
            paste0(mx_cj_string(nm[[i]]), ":", mx_cj_emit(x[[i]]))
        }, character(1))
        return(paste0("{", paste(parts, collapse = ","), "}"))
    }
    if (is.logical(x)) {
        if (any(is.na(x))) {
            stop("mx_canonical_json: NA disallowed", call. = FALSE)
        }
        if (length(x) == 1L) {
            return(if (isTRUE(x)) "true" else "false")
        }
        return(paste0(
                      "[",
                      paste(ifelse(x, "true", "false"), collapse = ","),
                      "]"
            ))
    }
    if (is.character(x)) {
        if (any(is.na(x))) {
            stop("mx_canonical_json: NA disallowed", call. = FALSE)
        }
        if (length(x) == 1L) {
            return(mx_cj_string(x))
        }
        return(paste0(
                      "[",
                      paste(vapply(x, mx_cj_string, character(1)), collapse = ","),
                      "]"
            ))
    }
    if (is.numeric(x)) {
        if (any(is.na(x)) || any(!is.finite(x))) {
            stop("mx_canonical_json: NA/NaN/Inf disallowed", call. = FALSE)
        }
        if (length(x) == 1L) {
            return(mx_cj_number(x))
        }
        return(paste0(
                      "[",
                      paste(vapply(x, mx_cj_number, character(1)), collapse = ","),
                      "]"
            ))
    }
    stop(sprintf("mx_canonical_json: unsupported type '%s'", typeof(x)),
         call. = FALSE)
}

mx_cj_number <- function(x) {
    format(x, scientific = FALSE, trim = TRUE, drop0trailing = TRUE)
}

mx_cj_string <- function(s) {
    s <- enc2utf8(as.character(s))
    s <- gsub("\\", "\\\\", s, fixed = TRUE)
    s <- gsub("\"", "\\\"", s, fixed = TRUE)
    s <- gsub("\b", "\\b", s, fixed = TRUE)
    s <- gsub("\f", "\\f", s, fixed = TRUE)
    s <- gsub("\n", "\\n", s, fixed = TRUE)
    s <- gsub("\r", "\\r", s, fixed = TRUE)
    s <- gsub("\t", "\\t", s, fixed = TRUE)
    # Any remaining 0x01-0x1F control chars need \u escaping. NUL (0x00)
    # cannot appear in an R string, so it's not iterated.
    for (cp in c(1:7, 11L, 14:31)) {
        ch <- intToUtf8(cp)
        if (grepl(ch, s, fixed = TRUE)) {
            s <- gsub(ch, sprintf("\\u%04x", cp), s, fixed = TRUE)
        }
    }
    paste0("\"", s, "\"")
}

