sink("Bayesian/RW.jags")
cat("
    model{

    #Constants
    pi <- 3.141592653589

    #Transition Matrix for turning angles
    T[1,1] <- cos(theta)
    T[1,2] <- (-sin(theta))
    T[2,1] <- sin(theta)
    T[2,2] <- cos(theta)

    ###Prediction First Step#####
    #First movement - random walk.
    y[2,1:2] ~ dmnorm(y[1,1:2],iSigma)
    
    #Process Model for movement
    for(t in 2:(steps-1)){
      
      #Correlation in movement change
      d[t,1:2] <- y[t,] + gamma * T %*% (y[t,1:2] - y[t-1,1:2])

      #Gaussian Displacement
      y[t+1,1:2] ~ dmnorm(d[t,1:2],iSigma)

      #
  
    }

    #Priors
    #Process Variance
    iSigma ~ dwish(R,2)
    Sigma <- inverse(iSigma)

    #Persistance
    gamma ~ dbeta(1,1)
  
    #Mean angle
    theta ~ dunif(-1*pi,pi)
    }"
    ,fill=TRUE)
sink()
