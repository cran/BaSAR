\name{BaSAR.plotperiod}
\alias{BaSAR.plotperiod}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Plotting over period}
\description{Calculates a normalised posterior over period range.}
\usage{
BaSAR.plotperiod(omega,p)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{omega}{1D vector of omega}
  \item{p}{posterior distribution over omega}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
The other BaSAR functions return the posterior over omega (angular frequency). If the user wants to plot the result over period instead, this function takes the results from e.g. \code{BaSAR.post} and computes the posterior over an evenly spaced vector of the period. This is done using linear interpolation of the posterior over omega.

}
\value{
A list containing:
\item{period}{1D vector of the period (in seconds), evenly sampled}
\item{normp}{normalised posterior distribution over \code{period}}
\item{omega}{1D vector of the omega, corresponding to \code{period}}
}
%%\references{
%%
%%}
\author{
%%  ~~who you are~~
Emma Granqvist, Matthew Hartley and Richard J Morris.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
\code{\link{BaSAR.post}}
}
\examples{
# Create time series omega = 0.5
tpoints = seq(from=1, to=200, length=200)
dpoints = sin(0.5 * tpoints) + 0.1 * rnorm(200, 0, 1)
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BaSAR to get normalized posterior distirbution
r <- BaSAR.post(dpoints, 6, 30, 100, 0, tpoints)
# Plot the resulting posterior density function
plot(r$omega, r$normp, xlim=c(0:1), type="h", col="red", ylab="PDF",
xlab=expression(omega))
# Calculate distribution over period interval 6-30 seconds
r2 <- BaSAR.plotperiod(r$omega,r$normp)
# Plot distribution over period instead
plot(r2$period, r2$normp, type="h", col="red", ylab="PDF",
xlab="Period in seconds")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{  }
%\keyword{  }% __ONLY ONE__ keyword per line
