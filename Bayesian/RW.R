sink("Bayesian/RW.jags")
cat("
    model{
    #Process Model
    for(x in 2:steps){
    y[x,] ~ dmnorm(y[x-1,],iSigma)

    #Generate prediction
    ynew[x,1:2] ~ dmnorm(y[x-1,1:2],iSigma)
    }

    #Priors
    iSigma~dwish(R,3)

    }"
    ,fill=TRUE)
sink()
