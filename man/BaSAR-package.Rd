\name{BaSAR-package}
\alias{BaSAR-package}
\alias{BaSAR}
\docType{package}
\title{Bayesian Spectrum Analysis in R}
\description{
Bayesian Spectrum Analysis of time series data
}
\details{
\tabular{ll}{
Package: \tab BaSAR\cr
Type: \tab Package\cr
Version: \tab 1.1\cr
Date: \tab 2012-01-09\cr
Repository: \tab CRAN\cr
License: \tab GPL (>= 2)\cr
LazyLoad: \tab yes\cr
}
The key function is \code{\link{BaSAR.post}}. It computes the normalized posterior probability distribution over a predefined range. 

Model comparison can be done for time series with trends.
\code{\link{BaSAR.modelratio}} computes the model ratio between two models, and when the ratio is above 1 the simpler model is preferred. The procedure of adding additional background functions to the model until this ratio is above 1 is automated in \code{\link{BaSAR.auto}}.

When there are multiple frequencies present in the data, the nested sampling routine, \code{\link{BaSAR.nest}}, should be preferred over the functions \code{\link{BaSAR.modelratio}} and \code{\link{BaSAR.auto}} to compare models. Plot log of posterior probability distribution and visually inspect if there are additional frequencies present.
\code{\link{BaSAR.nest}} calculates the evidence for a given model, and a model with a higher evidence should be preferred. 

The functions output the posterior over omega (angular frequency). If the user wants to plot over period instead, the function \code{\link{BaSAR.plotperiod}} will produce the posterior over period.

}
\author{
Emma Granqvist, Matthew Hartley and Richard J Morris.

Maintainer: Emma Granqvist \email{\code{emma.granqvist@jic.ac.uk}}
}
\references{
Bretthorst, G. L. (1988) Bayesian spectrum analysis and parameter estimation. \emph{Lecture notes 
in statistics.} New York: Springer-Verlag.

Granqvist, E., Oldroyd, G. E. and Morris, R. J. (2011) Automated Bayesian model development for frequency detection in biological time series. \emph{BMC Syst Biol} \bold{5}, 97.\cr
\url{http://dx.doi.org/10.1186/1752-0509-5-97} 

Sivia, D. S. and Skilling, J. (2006) Data analysis: a Bayesian tutorial. 2nd Edition. Oxford: Oxford 
science publications. Oxford University Press. 

}
\keyword{ models }
\note{
%~~ Optional links to other man pages, e.g. ~~
%~~ \code{\link[<pkg>:<pkg>-package]{<pkg>}} ~~

Requires the R libraries polynom and orthopolynom, which will be loaded automatically.

}
%\examples{
%~~ simple examples of the most important functions ~~
%}
