##################################################################################
# BaSAR package 
# Emma Granqvist, Matthew Hartley and Richard J Morris
##################################################################################

require(polynom)
require(orthopolynom)

##################################################################################
# Basic functions
##################################################################################

.BSA.linspace <- function(vstart, vend, vnumpoints) {
    v <- c(0:(vnumpoints-1))
    return(v * (vend - vstart) / (vnumpoints-1) + vstart)
	
}

.BSA.legendre <- function(n, x) {
  leg  <- 0
  leg2 <- 0
  leg <- legendre.polynomials(n,normalized=F)
  leg2 <- predict(leg[[length(leg)]],x)
    return(leg2)
}

.BSA.samplepoint <- function(tpoints, omega, nbackg) {
    tscale <- tpoints[length(tpoints)] - tpoints[1]
    f <- cbind(sin(tpoints * omega), cos(tpoints * omega))
    if (nbackg>0) {
        for (n in c(1:nbackg)) {
            l = .BSA.legendre(n, tpoints/tscale - 0.5)
            f <- cbind(l, f)
        }
    }
    f <- cbind(1, f)

    return(f)

}

.BSA.orthonormalize <- function(a) {

    eig <- eigen(t(a) %*% a)

    ortha = a %*% eig$vectors

    anorm = sqrt(colSums(ortha * ortha))

    for (i in c(1:ncol(a))) {
        ortha[,i] = ortha[,i] / anorm[i]
    }

    return(list(ortha=ortha, evalues=eig$values))

}

##################################################################################
# Probability functions, calculating posterior
##################################################################################

.BSA.prob_short <- function(data, fvalues, maxlogST) {
    ndata = nrow(fvalues)
    nfunc = ncol(fvalues)
    a = .BSA.orthonormalize(fvalues)
    orthofvalues = a$ortha
    h = data %*% orthofvalues
    meanhsq = sum(h * h)/nfunc
    meandsq = sum(data * data)/ndata

    return(list(meandsq=meandsq, meanhsq=meanhsq))
}

.BSA.prob <- function(data, fvalues, maxlogST) {
    ndata <- nrow(fvalues)
    nfunc <- ncol(fvalues)

    a = .BSA.orthonormalize(fvalues)
    h = data %*% a$ortha

    meanhsq = sum(h * h)/nfunc
    meandsq = sum(data * data)/ndata

    factor = 1.0 - nfunc*meanhsq/ndata/meandsq

    if(abs(factor < 1.0e-14)) {
        factor = .Machine$double.xmin
    }

    logST = log(factor) * (nfunc-ndata)/2.0
    logdiff = logST - maxlogST

    ST = 0.0

    if (maxlogST != 0.0) {
        ST = exp(logdiff)
    }

    sigma = sqrt(ndata / abs(ndata - nfunc - 2) * abs(meandsq - nfunc * meanhsq/ndata))
    spden = nfunc * meanhsq * ST
    signaltonoise = sqrt(nfunc/ndata * (1 + meanhsq/sigma/sigma))

    return(list(logST=logST, ST=ST, sigma=sigma, spden=spden, signaltonoise=signaltonoise)) 

}

.BSA.post1 <- function(data, tpoints, start, stop, nsamples, nbackg, normp) {
    start2 <- ((2*pi)/stop)
    stop2 <- ((2*pi)/start)
    omega <- numeric()
    logp <- numeric()
    p <- numeric()
    noise <- numeric()
    power <- numeric()
    signaltonoise <- numeric()

    for (i in c(1:nsamples)) {
      omega[i] = start2 + i * (stop2 - start2) / nsamples
      fpoints = .BSA.samplepoint(tpoints, omega[i], nbackg)
      l = .BSA.prob(data, fpoints, normp)
      logp[i] = l$logST
      p[i] = l$ST
      noise[i] = l$sigma
      power[i] = l$spden
      signaltonoise[i] = l$signaltonoise
        
    }
    return(list(omega=omega,logp=logp,p=p,noise=noise,power=power,signaltonoise=signaltonoise))
}





##################################################################################
# Downhill-simplex (amoeba) optimisation functions
##################################################################################

.BSA.amoeba_function <- function(omega, tpoints, nbackg, data) {
    fpoints = numeric()
    fpoints = .BSA.samplepoint(tpoints, omega, nbackg)
    r = .BSA.prob(data, fpoints, 0)
    logp = r$logST

    return(logp)
}

.BSA.amoeba_eval <- function(P, R, tpoints, nbackg, data) {
    bP = .BSA.amoeba_function(P, tpoints, nbackg, data)[1]
    bR = .BSA.amoeba_function(R, tpoints, nbackg, data)[1]
    if (bP > bR) {
        Rnew = P
        Pnew = R
    } else {
        Pnew = P
        Rnew = R
    }

    return(list(Pnew=Pnew,Rnew=Rnew))
}

.BSA.amoeba_reflect <- function(P, R) {
    PR = R-P
    P = P + PR * 2
    return(list(P=P,R=R))
}

.BSA.amoeba_extrapol <- function(P, R) {
    PR = R-P
    P = P + PR * -0.25
    return(P)
}

.BSA.amoeba_contract <- function(P, R) {
    PR = R-P
    P = P + PR * 0.25
    return(list(P=P, R=R))
}

.BSA.amoeba <- function(x, xini, lambda, tpoints, nbackg, data) {
    P = xini
    R = xini + lambda
    limit = 0.000001
    r = .BSA.amoeba_eval(P, R, tpoints, nbackg, data)
    P = r$Pnew
    R = r$Rnew

    for (i in c(1:x)) {
        r = .BSA.amoeba_eval(P, R, tpoints, nbackg, data)
        P = r$Pnew
        R = r$Rnew

        if (.BSA.amoeba_function(R, tpoints, nbackg, data)[1] - .BSA.amoeba_function(P, tpoints, nbackg, data)[1] < limit) {
            break
        } else {
            r = .BSA.amoeba_reflect(P, R)
            P = r$P
            R = r$R
            if(.BSA.amoeba_function(P, tpoints, nbackg, data)[1] > .BSA.amoeba_function(R, tpoints, nbackg, data)[1]) {
                P = .BSA.amoeba_extrapol(P, R)
            } else {
                r = .BSA.amoeba_contract(P, R)
                P = r$P
                R = r$R
            }
        }
    }

    r = .BSA.amoeba_eval(P, R, tpoints, nbackg, data)
    P = r$Pnew
    R = r$Rnew

    logp = .BSA.amoeba_function(R, tpoints, nbackg, data)
    omega1 = R

    return(list(logp=logp, omega1=omega1))


}

##################################################################################
# Normalisation of posterior, and some stats of distributions over omega and period
##################################################################################

.BSA.normalise <- function(data, omega, p, nsamples, nbackg, logp_max, omega_range) {
    omegaN = omega_range / nsamples
    meanP = 0
    meanO = 0
    varP = 0
    varO = 0
    stO = 0
    stP = 0
    periodinfo = numeric()
	normp_new <- p
	dx = (max(omega)-min(omega))/nsamples
	
	periodinfo <- BaSAR.plotperiod(omega, normp_new)
	normp_new2 <-periodinfo$normp
	period <-periodinfo$period
	dx2 <- (max(period)-min(period))/nsamples
	
	sum1 = sum(normp_new * dx)
	sum2 = sum(normp_new2 * dx2)
	
	
    for (i in c(1:nsamples)) {		
        normp_new[i] = normp_new[i] / sum1
		normp_new2[i] = normp_new2[i] / sum2		
	}
	
	for (k in c(1:nsamples)) {
        varO = varO + dx * normp_new[k] * omega[k] ^ 2
        meanO = meanO + dx * normp_new[k] * omega[k]
        varP = varP + dx2 * normp_new2[k] * period[k] ^ 2
        meanP = meanP + dx2 * normp_new2[k] * period[k]
    }

    varP = varP - (meanP) ^ 2	
    varO = varO - (meanO) ^ 2	
    stP = sqrt(varP)	
    stO = sqrt(varO)

    res = data.frame(cbind(Peak_probability_over_omega=max(normp_new), omega_mean=meanO, omega_stdev=stO, period_mean=meanP, period_stdev=stP))
	
    return(list(norm_p=normp_new, omega=omega, res=res))
}




##################################################################################
# User-availble functions for posterior
##################################################################################

BaSAR.post <- function(data, start, stop, nsamples, nbackg, tpoints) {
    omega_range <- ((2*pi)/start) - ((2*pi)/stop)
    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, 0)
    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, max(r$logp))
    p = r$p
    omega = r$omega
    logp = r$logp
    r = .BSA.normalise(data, omega, p, nsamples, nbackg, max(logp), omega_range)
    normp = r$norm_p
    omega = r$omega
    res = r$res
    
    return(list(normp=normp, omega=omega, stats=res))
}


BaSAR.fine <- function(data, start, stop, nsamples, nbackg, tpoints) {
    omega_range <- ((2*pi)/start) - ((2*pi)/stop)
    omegaN = omega_range * 0.05
    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, 0)
    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, max(r$logp))
    p = r$p
    maxp = 0
    for (j in c(1:nsamples)) {
        if (p[j] > maxp) {
            maxp = p[j]
            guess = r$omega[j]
        }
    }
    normp = .BSA.normalise(data, r$omega, r$p, nsamples, nbackg, max(r$logp), omega_range)
    s = .BSA.amoeba(1000, guess, omegaN*2, tpoints, nbackg, data)
    maxlogp = s$logp
    omega1 = s$omega1

    r = BaSAR.post(data, (2*pi)/(omega1+omegaN), (2*pi)/(omega1-omegaN), nsamples, nbackg, tpoints)
    normp = r$normp
    omega = r$omega
    res = r$res
    
    return(list(normp=normp, omega=omega, stats=res))
}

##################################################################################
# Model comparison using model ratios
##################################################################################

.BSA.ratiocal <- function(data, tpoints, start, stop, nsamples, nbackg) {
    omega_range = ((2*pi)/start) - ((2*pi)/stop)
    ndata = length(data)

    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, 0)
    r = .BSA.post1(data, tpoints, start, stop, nsamples, nbackg, max(r$logp))

    p = r$p
    omega = r$omega
    logp = r$logp
    normp = .BSA.normalise(data, omega, p, nsamples, nbackg, max(logp), omega_range)
    
    logpmax = 0

    for(j in c(1:nsamples)) {
        if(logp[j] > logpmax) {
            logpmax = logp[j]
            omega1 = omega[j]
        }
    }

    r=1
    meanosq = sum(omega1^2)
    fpoints = .BSA.samplepoint(tpoints, omega1, nbackg)
    ndata = nrow(fpoints)
    nfunc = ncol(fpoints)

    ret = .BSA.prob_short(data, fpoints, max(logp))
    meandsq1 = ret$meandsq
    meanhsq1 = ret$meanhsq

    GL1 = gamma(nfunc / 2) * (((nfunc * meanhsq1) / 2) ^ (-nfunc/2))
    GL2 = gamma(r / 2) * (((r * meanosq) / 2) ^ (-r / 2))
    GL31 = abs(ndata - nfunc -r)/2
    GL4 = ndata * meandsq1
    GL5 = nfunc * meanhsq1
    GL32 = (GL4 - GL5) / 2
    fact = (nfunc + r - ndata) / 2
    GL6 = GL32 ^ fact
    if (GL6 == Inf) {
        GL6 = .Machine$double.xmax
    }
	if (GL6 == 0) {
        GL6 = .Machine$double.xmin
    }

    return(list(GL1=GL1, GL2=GL2, GL31=GL31, GL6=GL6))

}

.BSA.modelratio_auto <- function(data, start, stop, nsamples, nbackg, tpoints) {
  for(i in c(0:nbackg)) {
    if (i==nbackg) {
            r = BaSAR.post(data, start, stop, nsamples, i, tpoints)
            normp = r$normp
            omega = r$omega
            res = r$res
			model = c("max reached:",i)
        } else {
            ret = .BSA.ratiocal(data, tpoints, start, stop, nsamples, i)
            GL1_1 = ret$GL1
            GL2_1 = ret$GL2
            GL31_1 = ret$GL31
            GL4_1 = ret$GL6
            ret = .BSA.ratiocal(data, tpoints, start, stop, nsamples, i+1)
            GL1 = ret$GL1
            GL2 = ret$GL2
            GL31 = ret$GL31
            GL4 = ret$GL6           
            if (GL31_1 > GL31) {
                n = GL31
                GL3 = gamma(0.5)/beta(n, 0.5)
            } else {
                n = GL31_1
                GL3 = beta(n, 0.5) / gamma(0.5)
            }
            ratio = 0
            ratio = ((GL1_1*GL2_1*GL4_1)/(GL1*GL2*GL4))*GL3;
            if (ratio>1) {
                ret = BaSAR.post(data, start, stop, nsamples, i, tpoints)
				model = i
				return(list(normp=ret$normp, omega=ret$omega,stats=ret$res,ratio=ratio,model=model))
            } 
        }
    }

    return(list(normp=normp, omega=omega,stats=res,ratio=ratio,model=model))
}

BaSAR.modelratio <- function(data, start, stop, nsamples, nbackg1, nbackg2, tpoints) {
	if (nbackg1 < nbackg2)	{
		model1 <- nbackg1
	    model2 <- nbackg2
	}
	else {
		model2 <- nbackg1
	    model1 <- nbackg2
	}
            ret = .BSA.ratiocal(data, tpoints, start, stop, nsamples, model1)
            GL1_1 = ret$GL1
            GL2_1 = ret$GL2
            GL31_1 = ret$GL31
            GL4_1 = ret$GL6
            ret = .BSA.ratiocal(data, tpoints, start, stop, nsamples, model2)
            GL1 = ret$GL1
            GL2 = ret$GL2
            GL31 = ret$GL31
            GL4 = ret$GL6           
            if (GL31_1 > GL31) {
                n = GL31
                GL3 = gamma(0.5)/beta(n, 0.5)
            } else {
                n = GL31_1
                GL3 = beta(n, 0.5) / gamma(0.5)
            }
            ratio = 0
            ratio = ((GL1_1*GL2_1*GL4_1)/(GL1*GL2*GL4))*GL3;          
            if (ratio>1) {
                ret = BaSAR.post(data, start, stop, nsamples, model1, tpoints)
            } else {
				ret = BaSAR.post(data, start, stop, nsamples, model2, tpoints)
            }
	
    return(list(normp=ret$normp, omega=ret$omega,stats=ret$res, modelratio=ratio))
}


BaSAR.auto <- function(data, start, stop, nsamples, nbackg, tpoints) {
    r = .BSA.modelratio_auto(data, start, stop, nsamples, nbackg, tpoints)
    normp = r$normp
    omega = r$omega
    stats = r$stats
    ratio = r$ratio
    model = r$model
    return(list(normp=normp, omega=omega, stats=stats, modelratio=ratio, model=model))
}

##################################################################################
# BSA local - using windowing to get 2D posterior
##################################################################################

BaSAR.local <- function(data, start, stop, nsamples, tpoints, nbackg, window) {
    n <- length(data)
    from <- 0
    tp <- 0
    data2 <- c()
    resultmatrix <- c()
    for (i in 1:n-1) {
		if ((i-window) > 1) {
			from <- i - window
		}
		else {
			from <-1
		}
		if ((i+window) < n) {
			to <- i + window
		}
		else {
			to <- n
		}
		data2 <- data[from:to]
		tpoints2 <- tpoints[from:to]
		
		r <- BaSAR.post(data2, start, stop, nsamples, nbackg, tpoints2) 
		resultmatrix <- rbind(resultmatrix,r$normp)
    }
	
    return(list(omega=r$omega, p=resultmatrix))
}

##################################################################################
# Nested sampling code, sampling posterior and calculating evidence
##################################################################################

.BSA.prior <- function(omega_min, omega_max, dim, n) {
    x = runif(n, omega_min, omega_max)
    return(x)
}

.BSA.post_nested <- function(data, omega, tpoints, nbackg, dim, normp) {
    tpoints = .BSA.linspace(tpoints, length(data) * tpoints, length(data))
    fpoints = .BSA.samplepoint(tpoints, omega, nbackg)
    r = .BSA.prob(data, fpoints, normp)
	normp = max(r$logST)
	r = .BSA.prob(data, fpoints, normp)
    logp = r$logST
    return(logp)
}

.BSA.loglikelihood <- function(data, omega, tpoints, nbackg, dim) {
    ll = .BSA.post_nested(data, omega, tpoints, nbackg, dim, 0)
    return(ll)
}

.BSA.getLLHoods <- function(data, x, tpoints, nbackg, dim) {
    llvalues = numeric()
    for(i in c(1:length(x))) {
        llvalues[i] = .BSA.loglikelihood(data, x[i], tpoints, nbackg, dim)
    }
    return(llvalues)
} 

.BSA.logplus <- function(a, b) {
    if (a > b) {
        sum = a + log(1+exp(b-a))
    } else {
        sum = b + log(1+exp(a-b))
    }
    return(sum)
}

.BSA.explore <- function(data, x, omega_min, omega_max, logLhoodMin, dim, tpoints, nbackg) {
    step = 0.1
    m = 20
    accept = 0
    reject = 0
    xLL=.BSA.loglikelihood(data, x, tpoints, nbackg, dim)
    for (i in c(1:m)) {
        tryx = rnorm(1, x, step)
        tryx = omega_min + (tryx-omega_min) %% (omega_max-omega_min)
        tryxLL = .BSA.loglikelihood(data, tryx, tpoints, nbackg, dim)
        if (tryxLL > logLhoodMin) {
            x = tryx
            xLL = tryxLL
            accept = accept + 1
        } else {
            reject = reject + 1
        }
        if (accept > reject) {
            step = step * exp(1.0/accept)
        }
        if (accept < reject) {
            step = step / exp(1.0/reject)
        }
    }
    return(list(x=x, xLL=xLL))
}

.BSA.meanomega <- function(posts, postsLWeights, logZ) {
    momega = 0.0
    stomega = 0.0
    mperiod = 0.0
    stperiod = 0.0
    period = numeric()
	weight = numeric()

    for (j in c(1:length(posts))) {
        period[j] = (2 * pi) / posts[j]
    }

    for (i in c(1:length(posts))) {
        weight[i] = exp(postsLWeights[i] - logZ)
        momega = momega + weight[i] * posts[i]
        stomega = stomega + weight[i] * posts[i] * posts[i]
    }
    stomega = sqrt(stomega - momega * momega)

    for (k in c(1:length(posts))) {
        weight[i] = exp(postsLWeights[k] - logZ)
        mperiod = mperiod + weight[i] * period[k]
        stperiod = stperiod + weight[i] * period[k] * period[k]
    }
    stperiod = sqrt(stperiod - mperiod * mperiod)

    return(list(weight=weight, momega=momega, stomega=stomega, mperiod=mperiod, stperiod=stperiod))
}

.BSA.evidence <- function(data, omega_min, omega_max, dim, nsamples, nbackg, tpoints, nposts) {
    samples = .BSA.prior(omega_min, omega_max, dim, nsamples)
    samplesLLHoods = .BSA.getLLHoods(data, samples, tpoints, nbackg, dim)
    samplesLWeights = array(0, nsamples)
    posts = array(0, nposts)
    postsLWeights = array(0, nposts)
    H = 0.0
    logZ = .Machine$double.xmin
    logwidth = log(1.0-exp(-1.0/nsamples))

    for (i in c(1:nposts)) {
        worst = 1
        for (j in c(2:nsamples)) {
            if(samplesLLHoods[j] < samplesLLHoods[worst]) {
                worst = j
            }
        }
        samplesLWeights[worst] = logwidth + samplesLLHoods[worst]
        logZnew = .BSA.logplus(logZ, samplesLWeights[worst])
        H = exp(samplesLWeights[worst]-logZnew) * samplesLLHoods[worst] + exp(logZ-logZnew) * (H + logZ) - logZnew
        logZ = logZnew
        posts[i] = samples[worst]
        postsLWeights[i] = samplesLWeights[worst]
        newi = worst
        while (newi == worst) {
            newi = 1 + floor(nsamples*runif(1, 0, 1))
        }
        LLHoodmin = samplesLLHoods[worst]
        samples[worst] = samples[newi]
        r = .BSA.explore(data, samples[worst], omega_min, omega_max, LLHoodmin, dim, tpoints, nbackg)
        samples[worst] = r$x
        samplesLLHoods[worst] = r$xLL
        logwidth = logwidth - 1.0/nsamples
		
    }
	
    logZerror = sqrt(H/nsamples)
    r = .BSA.meanomega(posts, postsLWeights, logZ)
	weight = r$weight
    momega = r$momega
    stomega = r$stomega
    mperiod = r$mperiod
    stperiod = r$stperiod

    return(list(samples=samples,weight=samplesLLHoods,logZ=logZ, logZerror=logZerror, momega=momega, stomega=stomega, mperiod=mperiod, stperiod=stperiod))
}

BaSAR.nest <- function(data, start, stop, nsamples, nbackg, tpoints, nposts) {
	start2 <- ((2*pi)/stop)
    stop2 <- ((2*pi)/start)
    r = .BSA.evidence(data, start2, stop2, 1, nsamples, nbackg, tpoints, nposts)

    return(list(samples=r$samples,weights=r$weight,logZ=r$logZ,logZerror=r$logZerror,momega=r$momega,stomega=r$stomega))
}

##################################################################################
# Plotting function to get even distribution over period
##################################################################################

BaSAR.plotperiod <- function(omega, p) {
  N <- length(omega)
  start = 0
  stop = 0
  p.period <- c()
  omega.p <- c()
  normp <- c()

  stop <- ((2*pi)/omega[N])
  start <- ((2*pi)/omega[1])
  
  period <- seq(from=stop,to=start,length=N)
  dx <- (max(period)-min(period))/N

  for (i in 1:N){
    omega.p[i] <- (2*pi)/period[i]
  }

  p.period <- approx(omega,p,xout=omega.p)
	
  for (j in 1:N){
    normp[j] <- p.period$y[j]/sum(p.period$y*dx)
  }
	
    return(list(period=period,normp=normp,omega=omega.p))
}



