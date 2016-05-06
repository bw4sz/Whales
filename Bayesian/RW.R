sink("Bayesian/RW.jags")
cat("
    model{
    #Process Model
    for(x in 2:steps){
    y[x,] ~ dmnorm(y[x-1,],iSigma)
    }
    #Priors
    iSigma~dwish(R,3)

    #Generate prediction
    ynew[1,1]<-0
    ynew[1,2]<-0
    ynew[x,] ~ dmnorm(y[x-1,],iSigma)
    }"
    ,fill=TRUE)
sink()
