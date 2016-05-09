sink("Bayesian/RW.jags")
cat("
    model{

    #Constants
    pi <- 3.141592653589

    ###First Step###
    #First movement - random walk.
    y[2,1:2] ~ dmnorm(y[1,1:2],iSigma)
    
    ###First Behavioral State###
    state[1] ~ dcat(lambda[]) ## assign state for first obs
    
    #Process Model for movement
    for(t in 2:(steps-1)){
      
      #Turning covariate
      #Transition Matrix for turning angles
      T[t,1,1] <- cos(theta[state[t]])
      T[t,1,2] <- (-sin(theta[state[t]]))
      T[t,2,1] <- sin(theta[state[t]])
      T[t,2,2] <- cos(theta[state[t]])
      
      #Behavioral State at time T
      phi[t,1] <- alpha[state[t-1]]
      phi[t,2] <- 1 - alpha[state[t-1]]
      state[t] ~ dcat(phi[t,])
      
      #Correlation in movement change
      d[t,1:2] <- y[t,] + gamma[state[t]] * T[t,,] %*% (y[t,1:2] - y[t-1,1:2])

      #Gaussian Displacement
      y[t+1,1:2] ~ dmnorm(d[t,1:2],iSigma)
  
    }

    #Priors
    #Process Variance
    iSigma ~ dwish(R,2)
    Sigma <- inverse(iSigma)

    ##Mean Angle
    
    tmp[1] ~ dbeta(10, 10)
    tmp[2] ~ dbeta(10, 10)
    
    # prior for theta in 'traveling state'
    theta[1] <- (2 * tmp[1] - 1) * pi
    
    # prior for theta in 'foraging state'    
    theta[2] <- (tmp[2] * pi * 2)

    ##Move persistance
    # prior for gamma (autocorrelation parameter) in state 1
    gamma[1] ~ dbeta(1,1)
    
    # prior for gamma in state 2
    gamma[2] ~ dbeta(1,1)
    
    ##Behavioral States
    # prob of being in state 1 at t, given in state 1 at t-1    
    alpha[1] ~ dbeta(1,1)
    
    # prob of being in state 1 at t, given in state 2 at t-1    
    alpha[2] ~ dbeta(1,1) 

    #Probability of behavior switching 
    lambda[1] ~ dbeta(1,1)
    lambda[2] <- 1 - lambda[1]

    }"
    ,fill=TRUE)
sink()
