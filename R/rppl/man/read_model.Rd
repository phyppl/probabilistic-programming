% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rppl.R
\name{read_model}
\alias{read_model}
\title{Reads Simulation Results}
\usage{
read_model(model, modelf, reps)
}
\arguments{
\item{model}{(string) model name - will be used as a prefix in the data frame columns}

\item{modelf}{(string)  model file - path to *-results.JSON file}

\item{reps}{(integer) the number of replicates (independent runs of the probabilistic program) that the model has been run; corresponds to the last parameter of 'npm run sim' and 'npm run wppl'}
}
\value{
data frame with *-results.JSON file parsed
}
\description{
Simulations that are stored in *-results.JSON are read via this function.
}
