
sink("Bayesian/HMM.jags")

cat("
    model {

  #Constants
  pi <- 3.141592653589
  pi2 <- 2 * pi
  npi <- pi * -1
  
  #First States
  Omega[1,1] <- 1
  Omega[1,2] <- 0
  Omega[2,1] <- 0
  Omega[2,2] <- 1
  
  ## Assume simple random walk to estimate 2nd regular position
  x[2,1:2] ~ dmnorm(x[1,], iSigma[,])
  
  ## Transition Model
  for(t in 2:(RegN-1)){
    
    phi[t,1] <- alpha[state[t-1]]
    phi[t,2] <- 1 - alpha[state[t-1]]
    state[t] ~ dcat(phi[t,])
    
    ## Build transition matrix for rotational component	
    T[t,1,1] <- cos(theta[state[t]])
    T[t,1,2] <- (-sin(theta[state[t]]))
    T[t,2,1] <- sin(theta[state[t]])
    T[t,2,2] <- cos(theta[state[t]])

    for(k in 1:2){
      Tdx[t,k] <- T[t,k,1] * (x[t,1] - x[t-1,1]) + T[t,k,2] * (x[t,2] - x[t-1,2])	## matrix multiplication
      x.mn[t,k] <- x[t,k] + gamma[state[t]] * Tdx[t,k]	## estimation next location (no error)
    }
    
    x[t+1,1:2] ~ dmnorm(x.mn[t,], iSigma[,])	## estimate next location (with error)
  }
  
  ##	Measurement equation
  for(t in 2:RegN){					# loops over regular time intervals (t)
    for(i in idx[t-1]:(idx[t]-1)){			# loops over observed locations within interval t
      for(k in 1:2){
        itau2.new[i,k] <- itau2[i,k] * itau2.prior
        zhat[i,k] <- (1-j[i]) * x[t-1,k] + j[i] * x[t,k]
        y[i,k] ~ dt(zhat[i,k], itau2.new[i,k], nu[i,k])
      }
    }
  }	
  
    ###Priors
    ## priors on process uncertainty
    iSigma[1:2,1:2] ~ dwish(Omega[,],2)	
    Sigma[1:2,1:2] <- inverse(iSigma[,])
    
    theta[1] ~ dunif(npi,pi)	## prior for theta in state 1, should be the 'foraging state'
    theta[2] ~ dunif(npi,pi)	## prior for theta in state 2, should be the 'migrating state'
    
    gamma[1] ~ dbeta(1,1)	## prior for gamma (autocorrelation parameter) in state 1
    gamma[2] ~ dbeta(1,1)	## prior for gamma in state 2 
    
    alpha[1] ~ dunif(0,1)	## prob of being in state 1 at t, given in state 1 at t-1
    alpha[2] ~ dunif(0,1)	## prob of being in state 1 at t, given in state 2 at t-1
    
    #Probability of behavior switching
    lambda[1] ~ dbeta(1,1)
    lambda[2] <- 1 - lambda[1]
    state[1] ~ dcat(lambda[]) ## assign state for first obs
    
    
    itau2.prior ~ dunif(0,10)
    
    ## Priors for first location
    for(k in 1:2){
    x[1,k] ~ dt(y[1,k], itau2[1,k], nu[1,k])
    }
    
    }
    ",fill=TRUE)

sink()
