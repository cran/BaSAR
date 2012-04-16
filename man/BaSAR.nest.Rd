\name{BaSAR.nest}
\alias{BaSAR.nest}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{BSA with nested sampling}
\description{BSA using nested sampling to calculate the evidence.}
\usage{
BaSAR.nest(data, start, stop, nsamples, nbackg, tpoints, nposts)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{data as a 1-dimensional vector}
  \item{start}{lower limit of period of interest, in seconds}
  \item{stop}{upper limit of period of interest, in seconds}
  \item{nsamples}{number of samples within the interval start-stop}
  \item{nbackg}{number of background functions to be added to the model}
  \item{tpoints}{vector of time points, in seconds}
  \item{nposts}{number of samples to draw from the posterior}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
Nested sampling is a variant of Markov chain Monte Carlo (MCMC), and repeatedly samples the posterior by ranking the sample points by their likelihoods. This function will return the evidence, which can be used to directly evaluate models. A model with a higher evidence should be preferred. 

\code{\link{BaSAR.nest}} should be preferred over the functions \code{\link{BaSAR.auto}} and 
\code{\link{BaSAR.modelratio}} when there are multiple frequencies present in the data. This is because the model comparison in the mentioned functions is based on a local integration around the point of maximum likelihood, and this approximation is not valid when there are several high peaks in the posterior. Calculating the evidences and comparing those is then a better approach. 

}
\value{
A list containing:
\item{samples}{1D vector of omega}
\item{weights}{1D vector of posterior samples, corresponding to omega}
\item{logZ}{the evidence of the sampled posterior}
\item{logZerror}{error of logZ}
\item{momega}{mean omega estimate}
\item{stomega}{standard deviation of mean omega}
}
\references{
%% ~put references to the literature/web site here ~
Sivia, D. S. and Skilling, J. (2006) Data analysis: a Bayesian tutorial. 2nd Edition. Oxford: Oxford 
science publications. Oxford University Press.

Granqvist, E., Oldroyd, G. E. and Morris, R. J. (2011) Automated Bayesian model development for frequency detection in biological time series. \emph{BMC Syst Biol} \bold{5}, 97.\cr
\url{http://dx.doi.org/10.1186/1752-0509-5-97} 
}
\author{
%%  ~~who you are~~
Emma Granqvist, Matthew Hartley and Richard J Morris.
}


%% ~Make other sections like Warning with \section{Warning }{....} ~


\examples{
# Create time series with omega = 0.5 and 0.3, plus noise
tpoints = seq(from=1, to=200, length=200)
dpoints = sin(0.5 * tpoints) +sin(0.3 * tpoints) + 0.1 * rnorm(200, 0, 1)
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BaSAR with nested sampling to estimate mean omega and evidence
r = BaSAR.nest(dpoints, 6, 600, 100, 0, tpoints, 500)
# Plot samples drawn from probability distribution
plot(r$samples,exp(r$weight),type="h",pch=20, col="red", ylab="",
xlab=expression(omega),xlim=c(0,1),ylim=c(0,max(exp(r$weight))))
# Note that two peaks appear, omega 0.3 and 0.5
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ models }
%\keyword{ nested sampling }
%\keyword{ evidence }% __ONLY ONE__ keyword per line
