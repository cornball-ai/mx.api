library(tinytest)

# mx_raise() produces classed conditions with structured fields and the
# historical message shape.
e <- tryCatch(mx.api:::mx_raise("M_NOT_FOUND", "Event not found.",
                                status = 404L),
              error = function(e) e)
expect_true(inherits(e, "mx_error"))
expect_true(inherits(e, "mx_error_M_NOT_FOUND"))
expect_equal(e$errcode, "M_NOT_FOUND")
expect_equal(e$status, 404L)
expect_equal(conditionMessage(e),
             "Matrix error [M_NOT_FOUND]: Event not found.")

# class-targeted handlers fire
got <- tryCatch(mx.api:::mx_raise("M_UNKNOWN_TOKEN", "expired"),
                mx_error_M_UNKNOWN_TOKEN = function(e) "relogin")
expect_equal(got, "relogin")

# generic mx_error handler catches any code
got2 <- tryCatch(mx.api:::mx_raise("M_LIMIT_EXCEEDED", "slow down"),
                 mx_error = function(e) e$errcode)
expect_equal(got2, "M_LIMIT_EXCEEDED")
