# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  









![](SingleSpecies_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

##By Month

![](SingleSpecies_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

##Distance



##Time 


##Velocity


##Angles



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
$$\alpha_{i,2,1} = \text{Probability of switching from Foraging to traveling}$$

$$\begin{matrix}
  \alpha_{i,1,1} & 1-\alpha_{i,1,1} \\
  \alpha_{i,2,1} & 1-\alpha_{i,2,1} \\
\end{matrix}
$$


With the probability of switching states:

$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}}$$

$$\phi_{foraging} = 1 - \phi_{traveling} $$

##Continious tracks

The transmitter will often go dark for 10 to 12 hours, due to weather, right in the middle of an otherwise good track. The model requires regular intervals to estimate the turning angles and temporal autocorrelation. As a track hits one of these walls, call it the end of a track, and begin a new track once the weather improves. We can remove any micro-tracks that are less than three days.
Specify a duration, calculate the number of tracks and the number of removed points. Iteratively.





How did the filter change the extent of tracks?

![](SingleSpecies_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-15-2.png)<!-- -->


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
    logit(phi[i,g,t,1]) <- alpha_mu[state[i,g,t-1]] 
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
    logit(phi[i,g,steps[i,g],1]) <- alpha_mu[state[i,g,steps[i,g]-1]] 
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
    gamma[2] ~ dbeta(1.5, 2)		## gamma for state 2
    dev ~ dbeta(1,1)			## a random deviate to ensure that gamma[1] > gamma[2]
    gamma[1] <- gamma[2] + dev 		## gamma for state 1
    
    
    ##Behavioral States
    
    #Hierarchical structure across motnhs
    #Intercepts
    alpha_mu[1] ~ dnorm(0,0.386)
    alpha_mu[2] ~ dnorm(0,0.386)
    
    #Variance
    alpha_tau[1] ~ dt(0,1,1)I(0,)
    alpha_tau[2] ~ dt(0,1,1)I(0,)
    
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
##     user   system  elapsed 
##  437.387    1.532 2506.422
```



##Chains

```
##                         Type      Size    PrettySize  Rows Columns
## jagM          rjags.parallel 326073088  [1] "311 Mb"     6      NA
## data                    list  62794448 [1] "59.9 Mb"     9      NA
## argos                  array  40901024   [1] "39 Mb"    34      14
## obs                    array  40901024   [1] "39 Mb"    34      14
## mdat              data.frame  24692824 [1] "23.5 Mb" 57230      54
## d     SpatialPointsDataFrame  21934528 [1] "20.9 Mb" 51696      61
## oxy               data.frame  21104304 [1] "20.1 Mb" 51696      61
## j                      array  20459496 [1] "19.5 Mb"    34      14
## sxy                     list  17585904 [1] "16.8 Mb"   164      NA
## mxy               grouped_df  16724840   [1] "16 Mb" 36213      66
```

```
##            used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells  1664970  89.0    3886542  207.6   3886542  207.6
## Vcells 92626348 706.7  148852402 1135.7 148852398 1135.7
```

![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

## Parameter Summary

```
##   parameter         par        mean        lower       upper
## 1  alpha_mu alpha_mu[1]  1.00891237  0.733299824  1.29444602
## 2  alpha_mu alpha_mu[2] -2.20556490 -2.806954358 -1.51849410
## 3     gamma    gamma[1]  0.90086453  0.826061178  0.95174042
## 4     gamma    gamma[2]  0.15498165  0.007416695  0.23156457
## 5     theta    theta[1] -0.00450118 -0.023512847  0.02081974
## 6     theta    theta[2]  5.75929716  4.027373748  6.17736495
```

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

### Per Animal


##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

##Behavioral description

##Location of Behavior



# Overlap with Krill Fishery


#Time spent in grid cell

![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-31-2.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->



##Traveling

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-34-2.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->


```
##                         Type      Size    PrettySize    Rows Columns
## jagM          rjags.parallel 326073088  [1] "311 Mb"       6      NA
## pc                    tbl_df  66876592 [1] "63.8 Mb" 1270100      10
## data                    list  62794448 [1] "59.9 Mb"       9      NA
## argos                  array  40901024   [1] "39 Mb"      34      14
## obs                    array  40901024   [1] "39 Mb"      34      14
## mdat              data.frame  24692824 [1] "23.5 Mb"   57230      54
## d     SpatialPointsDataFrame  21934528 [1] "20.9 Mb"   51696      61
## oxy               data.frame  21104304 [1] "20.1 Mb"   51696      61
## j                      array  20459496 [1] "19.5 Mb"      34      14
## mxy               data.frame  15682008   [1] "15 Mb"   34328      69
```

```
##             used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1704503  91.1    3886542  207.6   3886542  207.6
## Vcells 102782828 784.2  148852402 1135.7 148852398 1135.7
```
