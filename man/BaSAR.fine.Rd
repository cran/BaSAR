\name{BaSAR.fine}
\alias{BaSAR.fine}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Finely sampled BSA}
\description{High-resolution BSA which identifies the highest peak and samples more finely in its vicinity.}
\usage{
BaSAR.fine(data, start, stop, nsamples, nbackg, tpoints)
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
\code{\link{BaSAR.fine}} combines the function \code{\link{BaSAR.post}} with a Downhill-Simplex optimizer to identify the maximum peak in the frequency range chosen. It then samples over a narrower range around this peak for a high-resolution estimate of the strongest frequency. See e.g. Press (2002) for an example of Downhill-Simplex optimization.

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

Press, W. H. (2002) \emph{Numerical recipes in C++: the art of scientific computing}, 2nd Edition. 
Cambridge, UK: Cambridge University Press. 
}
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
# Create time series with omega = 0.5 and add noise
tpoints = seq(from=1, to=200, length=200)
r1 = rnorm(200, 0, 1)
r2 = rnorm(200, 0, 1)
dpoints = sin(0.5 * tpoints + 0.1 * (0.5-r1)) + 0.7 * r2
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BaSAR 
r = BaSAR.fine(dpoints, 6, 600, 100, 0, tpoints)
# Plot the resulting probability density function around maximum peak 
plot(r$omega, r$normp, xlim=c(0:1), type="h", col="red", ylab="PDF", 
xlab=expression(omega))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ downhill-simplex }
%\keyword{  }% __ONLY ONE__ keyword per line
