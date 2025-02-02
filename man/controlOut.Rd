% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/control.R
\name{controlOut}
\alias{controlOut}
\title{Control parameters for outcome model}
\usage{
controlOut(
  method = c("glm", "nn"),
  epsilon = 1e-06,
  maxit = 100,
  trace = FALSE,
  k = 5,
  penalty = c("SCAD", "LASSO"),
  lambda_min = 0.001,
  nlambda = 100
)
}
\arguments{
\item{method}{estimation method.}

\item{epsilon}{Tolerance for fitting algorithms. Default is \code{1e-6}.}

\item{maxit}{Maximum number of iterations.}

\item{trace}{logical value. If `TRUE` trace steps of the fitting algorithms. Default is `FALSE`.}

\item{k}{The k parameter in the [RANN2::nn()] function. Default is 5.}

\item{penalty}{penalty algorithm for variable selection. Default is `SCAD`}

\item{lambda_min}{The smallest value for lambda, as a fraction of lambda.max. Default is .001.}

\item{nlambda}{The number of lambda values. Default is 100.}
}
\description{
\code{controlOUT} constructs a list with all necessary control parameters
for outcome model.
}
