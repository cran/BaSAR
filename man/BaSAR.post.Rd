\name{BaSAR.post}
\alias{BaSAR.post}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Normalized posterior}
\description{A normalised posterior of the frequency in the chosen range.}
\usage{
BaSAR.post(data, start, stop, nsamples, nbackg, tpoints)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{data as a 1-dimensional vector}
  \item{start}{lower limit of period of interest, in seconds}
  \item{stop}{upper limit of period of interest, in seconds}
  \item{nsamples}{number of samples within the interval start-stop}
  \item{nbackg}{number of background functions to be added to the model}
  \item{tpoints}{vector of time points, in seconds}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
This function calculates the posterior probability distribution over a chosen range of omega (angular frequency), following Bretthorst (1988). It is based on a signal model of sines and cosines, and assumes uniform priors for model parameters such as amplitudes and noise models. The resulting distribution is then normalized over the range of omega. 

If there is a background trend in the data, background functions can be added to the signal model to account for this. The Legendre polynomials are used for these background functions, and \code{nbackg} is the number of Legendre extension orders to be used.

To plot the output over period instead of omega, see \code{\link{BaSAR.plotperiod}}.

}
\value{
A list containing:
\item{normp}{1D normalized posterior distribution over omega}
\item{omega}{1D vector of the omega sampled}
\item{stats}{list of statistics from the probability distribution}
}
\references{
%% ~put references to the literature/web site here ~
Granqvist, E., Oldroyd, G. E. and Morris, R. J. (2011) Automated Bayesian model development for frequency detection in biological time series. \emph{BMC Syst Biol} \bold{5}, 97.\cr
\url{http://dx.doi.org/10.1186/1752-0509-5-97} 

Bretthorst, G. L. (1988) Bayesian spectrum analysis and parameter estimation. \emph{Lecture notes 
in statistics.} New York: Springer-Verlag.
}
\author{
%%  ~~who you are~~
Emma Granqvist, Matthew Hartley and Richard J Morris.
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

%%\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
%%}
\examples{
# Create time series omega = 0.5
tpoints = seq(from=1, to=200, length=200)
dpoints = sin(0.5 * tpoints) + 0.1 * rnorm(200, 0, 1)
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BaSAR to get normalized posterior distirbution
r <- BaSAR.post(dpoints, 6, 600, 100, 0, tpoints)
# Plot the resulting posterior density function
plot(r$omega, r$normp, xlim=c(0:1), type="h", col="red", ylab="PDF",
xlab=expression(omega))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{  }
%\keyword{  }% __ONLY ONE__ keyword per line
