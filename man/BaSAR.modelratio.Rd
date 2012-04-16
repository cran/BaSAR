\name{BaSAR.modelratio}
\alias{BaSAR.modelratio}
%- Also NEED an '\alias' for EACH other topic documented here.
\title{BSA model comparison}
\description{Function for model comparison with background trends using model ratios.}
\usage{
BaSAR.modelratio(data, start, stop, nsamples, nbackg1, nbackg2, tpoints)
}
%- maybe also 'usage' for other objects documented here.
\arguments{
  \item{data}{data as a 1-dimensional vector}
  \item{start}{lower limit of period of interest, in seconds}
  \item{stop}{upper limit of period of interest, in seconds}
  \item{nsamples}{number of samples within the interval start-stop}
  \item{nbackg1}{number of background functions to be added to 1st model}
  \item{nbackg2}{number of background functions to be added to 2nd model}
  \item{tpoints}{vector of time points, in seconds}
}
\details{
%%  ~~ If necessary, more details than the description above ~~
The model ratio between 1st model, \eqn{H_i}, and the 2nd model, \eqn{H_j}, will be calculated as
\deqn{ {{P(H_i | D,I)}\over {P(H_j | D,I)}} = {{P(H_i | I) P(D | H_i,I) } \over  {P(H_j | I) P(D | H_j,I)}}.   }

where model \eqn{H_i} is the one with fewer background functions. When the ratio > 1, model \eqn{H_i} is a better fit than model \eqn{H_j}.

Legendre polynomials are used for the background functions, and are scaled to be orthogonal over the data.

Plot log of posterior probability distribution and visually inspect if there are additional frequencies present. If they are, \code{\link{BaSAR.nest}} should be used instead for model comparison.
}
\value{
A list containing:
\item{normp}{1D normalized posterior distribution over omega}
\item{omega}{1D vector of the omega sampled}
\item{stats}{list of statistics from the probability distribution}
\item{ratio}{ratio between 1st model and 2nd model}
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
\note{
%%  ~~further notes~~
This function has been automated in \code{\link{BaSAR.auto}}. 
}

%% ~Make other sections like Warning with \section{Warning }{....} ~

\seealso{
%% ~~objects to See Also as \code{\link{help}}, ~~~
\code{\link{BaSAR.auto}}, 
\code{\link{BaSAR.post}}
}
\examples{
require(polynom)
require(orthopolynom)
# Create time series with omega = 0.5 and a background trend
tpoints = seq(from=1, to=200, length=200)
dpoints = sin(0.5 * tpoints) - tpoints ^ 2 * 0.005 + 0.1 * rnorm(200, 0, 1)
# Plot time series
plot(dpoints, type="l", col="blue", xlab="t", ylab="d(t)")
# Run BSA with model comparison for background trends
# 1,2 background functions in this example
r = BaSAR.modelratio(dpoints, 6, 30, 100, 1, 2, tpoints)
# r$modelratio < 1 , add more background functions!
# Run BaSAR with model comparison for background trends
# 2,3 background functions in this example
r = BaSAR.modelratio(dpoints, 6, 600, 100, 2, 3, tpoints)
# This ratio is above 1, i.e. the model with 2 bg funcs has been selected
# Plot the resulting posterior density function
plot(r$omega, r$normp, xlim=c(0:1), type="h", col="red", ylab="PDF",
xlab=expression(omega))
}
% Add one or more standard keywords, see file 'KEYWORDS' in the
% R documentation directory.
%\keyword{ models }
%\keyword{ background }% __ONLY ONE__ keyword per line
