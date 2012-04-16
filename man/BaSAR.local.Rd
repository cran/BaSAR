\name{BaSAR.local}
\alias{BaSAR.local}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{Local BSA}
\description{A windowed BSA that computes the frequency locally.}
\usage{
BaSAR.local(data, start, stop, nsamples, tpoints, nbackg, window)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{data as a 1-dimensional vector}
  \item{start}{lower limit of period of interest, in seconds}
  \item{stop}{upper limit of period of interest, in seconds}
  \item{nsamples}{number of samples within the interval start-stop}
  \item{tpoints}{vector of time points, in seconds}
  \item{nbackg}{number of background functions to be added to the model}
  \item{window}{length of window, in number of data points}
}
\details{
\code{BaSAR.local} uses \code{\link{BaSAR.post}} with windowing, so it computes a local posterior. The window works in the way that at each time point \eqn{i}, the posterior will be calculated using the data from \eqn{i-window} to \eqn{i+window}.

}
\value{
A list containing:
\item{omega}{1D vector of the omega sampled}
\item{p}{2D posterior distribution over omega and time}
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
Emma Granqvist, Matthew Hartley and Richard J Morris
}
%%\note{
%%  ~~further notes~~
%%Something else?
%%}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
\code{\link{BaSAR.post}}
}
\examples{
require(fields)
# Create time series with changing omega
tpoints = seq(from=1, to=200, length=200)
dpoints <- c()
for (i in 1:200) { dpoints[i] <- sin((0.5+i*0.005)*i) }
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BaSAR with windowing to get 2D posterior over omega and time
r <- BaSAR.local(dpoints, 2, 30, 100, tpoints, 0, 10)
# Plot the resulting 2D posterior density function
# with time on x-axis and omega on y-axis
require(fields)
image.plot(tpoints,r$omega,r$p, col=rev(heat.colors(100)),
ylab=expression(omega),xlab="t")
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ windowing }
%\keyword{  }% __ONLY ONE__ keyword per line
