# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  





#Abstract



#Descriptive Statistics


![](SingleSpecies_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

##Distance

![](SingleSpecies_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

##Time 
![](SingleSpecies_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

##Velocity
![](SingleSpecies_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

##Angles

![](SingleSpecies_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

#Correlated random walk

*Process Model*

$$ d_{t} \sim T*d_{t-1} + Normal(0,\Sigma)$$
$$ x_t = x_{t-1} + d_{t} $$

## Parameters

For each individual:

$$\theta = \text{Mean turning angle}$$
$$\gamma = \text{Move persistence} $$

For both behaviors process variance is:
$$ \sigma_{latitude} = 0.1$$
$$ \sigma_{longitude} = 0.1$$

##Behavioral States

$$ \text{For each individual i}$$
$$ Behavior_1 = \text{traveling}$$
$$ Behavior_2 = \text{foraging}$$

$$ \alpha_{i,1,1} = \text{Probability of remaining traveling when traveling}$$
$$\alpha_{i,2,1} = \text{Probability of switching from feeding to traveling}$$

$$\begin{matrix}
  \alpha_{i,1,1} & 1-\alpha_{i,1,1} \\
  \alpha_{i,2,1} & 1-\alpha_{i,2,1} \\
\end{matrix}
$$

##Environment

Behavioral states are a function of local environmental conditions. The first environmental condition is ocean depth. I then build a function for preferential foraging in shallow waters.

It generally follows the form, conditional on behavior at t -1:

$$Behavior_t \sim Multinomial([\phi_{traveling},\phi_{foraging}])$$
$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}} + \beta_1 * Ocean_{y[t,]}$$
$$logit(\phi_{foraging}) = \alpha_{Behavior_{t-1}} + \beta_2 * Ocean_{y[t,]}$$



##Continious tracks

The transmitter will often go dark for 10 to 12 hours, due to weather, right in the middle of an otherwise good track. The model requires regular intervals to estimate the turning angles and temporal autocorrelation. As a track hits one of these walls, call it the end of a track, and begin a new track once the weather improves. We can remove any micro-tracks that are less than three days.
Specify a duration, calculate the number of tracks and the number of removed points. Iteratively.





How did the filter change the extent of tracks?

![](SingleSpecies_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-14-2.png)<!-- -->


sink("Bayesian/Multi_RW.jags")
cat("
    model{
    
    #Constants
    pi <- 3.141592653589
    
    ##argos observation error##
    argos_prec[1:2,1:2] <- inverse(argos_sigma*argos_cov[,])
    
    #Constructing the covariance matrix
    argos_cov[1,1] <- 1
    argos_cov[1,2] <- sqrt(argos_alpha) * rho
    argos_cov[2,1] <- sqrt(argos_alpha) * rho
    argos_cov[2,2] <- argos_alpha
    
    for(i in 1:ind){
      for(g in 1:tracks[i]){

        ## Priors for first true location
        #for lat long
        y[i,g,1,1:2] ~ dmnorm(argos[i,g,1,1,1:2],argos_prec)

        #First movement - random walk.
        y[i,g,2,1:2] ~ dmnorm(y[i,g,1,1:2],iSigma)
        
        ###First Behavioral State###
        state[i,g,1] ~ dcat(lambda[]) ## assign state for first obs
        
        #Process Model for movement
        for(t in 2:(steps[i,g]-1)){
        
        #Behavioral State at time T
        logit(phi[i,g,t,1]) <- alpha[i,state[i,g,t-1]] + beta[i,state[i,g,t-1]] * ocean[i,g,t] + beta2[i,state[i,g,t-1]] * coast[i,g,t]
        phi[i,g,t,2] <- 1-phi[i,g,t,1]
        state[i,g,t] ~ dcat(phi[i,g,t,])
            
        #Turning covariate
        #Transition Matrix for turning angles
        T[i,g,t,1,1] <- cos(theta[state[i,g,t]])
        T[i,g,t,1,2] <- (-sin(theta[state[i,g,t]]))
        T[i,g,t,2,1] <- sin(theta[state[i,g,t]])
        T[i,g,t,2,2] <- cos(theta[state[i,g,t]])
        
        #Correlation in movement change
        d[i,g,t,1:2] <- y[i,g,t,] + gamma[state[i,g,t]] * T[i,g,t,,] %*% (y[i,g,t,1:2] - y[i,g,t-1,1:2])
        
        #Gaussian Displacement
        y[i,g,t+1,1:2] ~ dmnorm(d[i,g,t,1:2],iSigma)
      }

    #Final behavior state
    logit(phi[i,g,steps[i,g],1]) <- alpha[i,state[i,g,steps[i,g]-1]] + beta[i,state[i,g,steps[i,g]-1]] * ocean[i,g,steps[i,g]] + beta2[i,state[i,g,steps[i,g]-1]] * coast[i,g,steps[i,g]]
    phi[i,g,steps[i,g],2] <- 1-phi[i,g,steps[i,g],1]
    state[i,g,steps[i,g]] ~ dcat(phi[i,g,steps[i,g],])
    
    ##	Measurement equation - irregular observations
    # loops over regular time intervals (t)    
    
    for(t in 2:steps[i,g]){
    
    # loops over observed locations within interval t
    for(u in 1:idx[i,g,t]){ 
      zhat[i,g,t,u,1:2] <- (1-j[i,g,t,u]) * y[i,g,t-1,1:2] + j[i,g,t,u] * y[i,g,t,1:2]

        #for each lat and long
          #argos error
          argos[i,g,t,u,1:2] ~ dmnorm(zhat[i,g,t,u,1:2],argos_prec)
          }
        }
      }
    }
    ###Priors###

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
    gamma[1] ~ dbeta(5,2)
    
    # prior for gamma in state 2
    gamma[2] ~ dbeta(2,5)
    
    ##Behavioral States
    # Following lunn 2012 p85
    
    #Hierarchical structure
    #Intercepts
    alpha_mu[1] ~ dnorm(0,0.386)
    alpha_mu[2] ~ dnorm(0,0.386)

    #Variance
    alpha_tau[1] ~ dt(0,1,1)I(0,)
    alpha_tau[2] ~ dt(0,1,1)I(0,)

    #Slopes
    ## Ocean Depth
    beta_mu[1] ~ dnorm(0,0.386)
    beta_mu[2] ~ dnorm(0,0.386)

    # Distance coast
    beta2_mu[1] ~ dnorm(0,0.386)
    beta2_mu[2] ~ dnorm(0,0.386)

    #Variance
    #Ocean
    beta_tau[1] ~ dt(0,1,1)I(0,)
    beta_tau[2] ~ dt(0,1,1)I(0,)
    
    #Coast
    beta2_tau[1] ~ dt(0,1,1)I(0,)
    beta2_tau[2] ~ dt(0,1,1)I(0,)
    
    #For each individual
    for(i in 1:ind){
      # prob of being in state 1 at t, given in state 1 at t-1    
      #Individual Intercept
      alpha[i,1] ~ dnorm(alpha_mu[1],alpha_tau[1])
      
      #effect of ocean on traveling -> traveling
      beta[i,1] ~ dnorm(beta_mu[1],beta_tau[1])
      
      #effect of coast on traveling -> traveling
      beta2[i,1] ~ dnorm(beta2_mu[1],beta2_tau[1])
    
      #Prob of transition to state 1 given state 2 at t-1
      alpha[i,2] ~ dnorm(alpha_mu[2],alpha_tau[2])

      #effect of ocean on feeding -> traveling
      beta[i,2] ~ dnorm(beta_mu[2],beta_tau[2])

      #effect of dist to coast on feeding -> traveling
      beta2[i,2] ~ dnorm(beta_mu[2],beta_tau[2])
    
    }
    
    #Probability of behavior switching 
    lambda[1] ~ dbeta(1,1)
    lambda[2] <- 1 - lambda[1]

    ##Argos priors##
    #longitudinal argos error
    argos_sigma ~ dunif(0,10)
    
    #latitidunal argos error
    argos_alpha~dunif(0,10)
    
    #correlation in argos error
    rho ~ dunif(-1, 1)
    

    }"
    ,fill=TRUE)
sink()


```
##    user  system elapsed 
##    1.11    0.13   77.94
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

##Prediction - environmental function

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-3.png)<!-- -->

##Log Odds of Feeding
![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration
![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

##Location of Behavior



Global Plotting

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->


#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->


```
##           used (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells 1502991 80.3    2637877 140.9  2637877 140.9
## Vcells 7584160 57.9   21940639 167.4 27424992 209.3
```
