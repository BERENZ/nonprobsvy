% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nonprobVariablesSelection.R
\name{nonprobSelM}
\alias{nonprobSelM}
\title{Inference with the non-probability survey samples.}
\usage{
nonprobSelM(
  outcome,
  data,
  svydesign,
  pop_totals,
  pop_means,
  pop_size,
  method_outcome,
  family_outcome,
  subset,
  strata,
  weights,
  na_action,
  control_outcome,
  control_inference,
  start,
  verbose,
  contrasts,
  model,
  x,
  y,
  ...
)
}
\arguments{
\item{outcome}{`formula`, the outcome equation.}

\item{data}{an optional `data.frame` with data from the nonprobability sample.}

\item{svydesign}{an optional `svydesign` object (from the survey package) containing probability sample.}

\item{pop_totals}{an optional `named vector` with population totals.}

\item{pop_means}{an optional `named vector` with population means.}

\item{pop_size}{an optional `double` with population size.}

\item{method_outcome}{a `character` with method for response variable estimation}

\item{family_outcome}{a `character` string describing the error distribution and link function to be used in the model. Default is "gaussian". Currently supports: gaussian with identity link, poisson and binomial.}

\item{subset}{an optional `vector` specifying a subset of observations to be used in the fitting process.}

\item{strata}{an optional `vector` specifying strata.}

\item{weights}{an optional `vector` of ‘prior weights’ to be used in the fitting process. Should be NULL or a numeric vector. It is assumed that this vector contains frequency or analytic weights}

\item{na_action}{a function which indicates what should happen when the data contain `NAs`.}

\item{control_outcome}{a list indicating parameters to use in fitting model for outcome variable}

\item{control_inference}{a list indicating parameters to use in inference based on probability and non-probability samples, contains parameters such as estimation method or variance method}

\item{start}{an optional `list` with starting values for the parameters of the selection and outcome equation.}

\item{verbose}{verbose, numeric.}

\item{contrasts}{a}

\item{model}{a}

\item{x}{a}

\item{y}{a}

\item{...}{Additional, optional arguments.}
}
\description{
\code{nonprobSelM} fits model for inference based on non-probability surveys using various methods
with variable selection techniques and mass imputation approach.

\loadmathjax
}
\author{
Łukasz Chrostowski, Maciej Beręsewicz
}
