# Canonical JSON per the Matrix spec — intentionally hand-rolled,
# not a wrapper around jsonlite.
#
# Matrix request signing needs byte-stable canonical JSON: every
# implementation must produce the exact same bytes for the same input
# because those bytes are what gets fed into ed25519. A general-purpose
# JSON serializer's job is to produce *valid* JSON; that's a strictly
# weaker contract. Key ordering, number formatting (no scientific
# notation, integer-vs-double behavior), NaN / Inf / NA handling, and
# whether non-ASCII gets emitted as \uXXXX escapes or as raw UTF-8
# bytes are all free choices for a general serializer that the
# canonical-JSON spec pins down.
#
# This file keeps every one of those rules visible and directly
# testable in roughly 80 lines. The alternative — relying on
# "jsonlite's defaults happen to match the spec (today)" — moves the
# correctness of every signature into another package's release notes.
#
# Spec: https://spec.matrix.org/v1.10/appendices/#canonical-json
#
# - Object keys sorted by UTF-8 byte sequence (radix sort, locale-free)
# - No insignificant whitespace
# - Non-ASCII preserved as raw UTF-8 bytes (no \uXXXX escapes)
# - Numbers: integers only in [-(2^53)+1, (2^53)-1]; no decimal places,
#   no exponents; floats, NaN, Inf, NA all rejected (spec: "Float
#   values are not permitted by this encoding")
# - Object keys: must not be NA or duplicated
# - Control chars 0x01-0x1F escaped (\b \f \n \r \t as named, rest \u)

#' Encode a value as Matrix canonical JSON
#'
#' Produces the canonical JSON byte sequence the Matrix specification
#' requires for signed objects: object keys sorted by UTF-8 byte
#' sequence, no insignificant whitespace, raw UTF-8 for non-ASCII
#' strings, integers only (no floats, no exponents, no decimal places,
#' within \code{[-(2^53)+1, (2^53)-1]}), and rejection of NaN, Inf,
#' NA values, and NA or duplicate object keys. The output is the exact
#' byte sequence to feed into an ed25519 signer.
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
        if (any(is.na(nm))) {
            stop("mx_canonical_json: NA in object keys disallowed",
                 call. = FALSE)
        }
        nm_utf8 <- enc2utf8(nm)
        if (anyDuplicated(nm_utf8)) {
            dup <- nm_utf8[duplicated(nm_utf8)][[1L]]
            stop(sprintf(
                         "mx_canonical_json: duplicate object key '%s'", dup
                ), call. = FALSE)
        }
        ord <- order(nm_utf8, method = "radix")
        parts <- vapply(ord, function(i) {
            paste0(mx_cj_string(nm_utf8[[i]]), ":", mx_cj_emit(x[[i]]))
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
    # Matrix canonical JSON allows only integers in
    # [-(2^53)+1, (2^53)-1] (spec: "Float values are not permitted by
    # this encoding").
    if (x != trunc(x)) {
        stop(sprintf(
                     "mx_canonical_json: non-integer number %s disallowed", x
            ), call. = FALSE)
    }
    if (abs(x) > 2 ^ 53 - 1) {
        stop(sprintf(
                     "mx_canonical_json: integer %s out of [-2^53+1, 2^53-1]", x
            ), call. = FALSE)
    }
    # R normalises negative zero to "0", which is what the spec
    # requires ("-0 MUST NOT appear" in output).
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

