% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/hints.R
\name{ag_if_vars}
\alias{ag_if_vars}
\title{Specify \code{tf.cond()} output structure when autographing \code{if}}
\usage{
ag_if_vars(
  ...,
  modified = list(),
  return = FALSE,
  undefs = NULL,
  control_flow = 0
)
}
\arguments{
\item{...}{Variables modified by the \code{tf.cond()} node supplied as bare
symbols like \code{foo} or expressions using \code{$} e.g, \code{foo$bar}. Symbols do not
have to exist before the autographed \code{if} so long as they are created in
both branches.}

\item{modified}{Variables names supplied as a character vector, or a list of
character vectors if specifying nested complex structures. This is an
escape hatch for the lazy evaluation semantics of \code{...}}

\item{return}{logical, whether to include the return value the evaluated R
expression in the \code{tf.cond()}. if \code{FALSE} (the default), only the objects
assigned in scope are captured.}

\item{undefs}{A bare character vector or a list of character vectors.
Supplied names are exported as undefs in the parent frame. This is used to
give a more informative error message when attempting to access a variable
that can't be balanced between branches.}

\item{control_flow}{An integer, the maximum number of control-flow statements
(\code{break} and/or \code{next}) that will be captured in a single branch as part of
the \code{tf.cond()}. Do not count statements in loops that are dispatching to
standard R control flow (e.g., don't count \code{break} statements in a \code{for}
loop that is iterating over an R vector)}
}
\value{
\code{NULL}, invisibly
}
\description{
This function can be used to specify the output structure from \code{tf.cond()}
when autographing an \code{if} statement. In most use cases, use of this function
is purely optional. If not supplied, the \code{if} output structure is
automatically built.
}
\details{
If the output structure is not explicitly supplied via
\code{ag_if_vars()}, then the output structure is automatically composed: The
true and false branches of the expression are traced into concrete
functions, then the output signature from the two branch functions are
balanced. Balancing is performed by either fetching a variable from an
outer scope or by reclassifying a symbol as an undef.

When dealing with complex composites (that is, nested structures where a
modified tensor is part of a named list or dictionary), care is taken to
prevent unnecessarily capturing other unmodified tensors in the structure.
This is done by pruning unmodified tensors from the returned output
structure, and then merging them back with the original object recursively.
One limitation of the implementation is that lists must either be fully
named with unique names, or not named at all, partially named lists or
duplicated names in a list throw an error. This is due to the conversion
that happens when going between python and R: named lists get converted to
python dictionaries, which require that all keys are unique. Additionally,
pruning of unmodified objects from an autographed \code{if} is currently only
supported for named lists (python dictionaries). Unnamed lists or tuples
are passed as is (e.g, no pruning and merging done), which may lead to
unnecessarily bloat in the constructed graphs.
}
\examples{
\dontrun{
# these examples only have an effect in graph mode
# to enter graph mode easily we'll create a few helpers
ag <- autograph

# pass which symbols you expect to be modifed or created liks this:
ag_if_vars(x)
ag(if (y > 0) {
  x <- y * y
} else {
  x <- y
})

# if the return value from the if expression is important, pass `return = TRUE`
ag_if_vars(return = TRUE)
x <- ag(if(y > 0) y * y else y)

# pass complex nested structures like this
x <- list(a = 1, b = 2)

ag_if_vars(x$a)
ag(if(y > 0) {
  x$a <- y
})

# undefs are for mark branch-local variables
ag_if_vars(y, x$a, undef = "tmp_local_var")
ag(if(y > 0) {
  y <- y * 100
  tmp_local_var <- y + 1
  x$a <- tmp_local_var
})

# supplying `undef` is not necessary, it exists purely as a way to supply a
# guardrail for defensive programming and/or to improve code readability

## modified vars can be supplied in `...` or as a named arg.
## these paires of ag_if_vars() calls are equivalent
ag_if_vars(y, x$a)
ag_if_vars(modified = list("y", c("x", "a")))

ag_if_vars(x, y, z)
ag_if_vars(modified = c("x", "y", "z"))


## control flow
# count number of odds between 0:10
ag({
  x <- 10
  count <- 0
  while(x > 0) {
    ag_if_vars(control_flow = 1)
    if(x \%\% 2 == 0)
      next
    count <- count + 1
  }
})
}
}
