# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  









![](SingleSpecies_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

##By Month

![](SingleSpecies_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

##CCAMLR Units
![](SingleSpecies_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

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

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-16-2.png)<!-- -->


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
    # prior for gamma (autocorrelation parameter)
    #from jonsen 2016
    gamma[1] ~ dbeta(5,2)   ## gamma for state 1: traveling
    dev ~ dbeta(1,1)			## a random deviate to ensure that gamma[1] > gamma[2]
    gamma[2] <- gamma[1] * dev 		## gamma for state 1
    
    
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
##      user    system   elapsed 
##   581.579     2.469 10851.723
```



##Chains

```
##                         Type      Size     PrettySize  Rows Columns
## jagM          rjags.parallel 712496752 [1] "679.5 Mb"     6      NA
## data                    list  72552256  [1] "69.2 Mb"     9      NA
## argos                  array  47265240  [1] "45.1 Mb"    34      21
## obs                    array  47265240  [1] "45.1 Mb"    34      21
## mdat              data.frame  24692824  [1] "23.5 Mb" 57230      54
## j                      array  23640224  [1] "22.5 Mb"    34      21
## d     SpatialPointsDataFrame  21189136  [1] "20.2 Mb" 49938      61
## oxy               data.frame  20387040  [1] "19.4 Mb" 49938      61
## sxy                     list  17181104  [1] "16.4 Mb"   188      NA
## mxy               grouped_df  15930600  [1] "15.2 Mb" 34484      66
```

```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1792220   95.8    3886542  207.6   3886542  207.6
## Vcells 147026206 1121.8  284656791 2171.8 249371005 1902.6
```

![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

## Parameter Summary

```
##   parameter         par         mean       lower       upper
## 1  alpha_mu alpha_mu[1]  1.144350971  0.85563677  1.42641400
## 2  alpha_mu alpha_mu[2] -2.664434982 -3.04460509 -2.32725227
## 3     gamma    gamma[1]  0.925931756  0.88758239  0.95791358
## 4     gamma    gamma[2]  0.198584979  0.15146791  0.23156665
## 5     theta    theta[1]  0.001552837 -0.01541057  0.01907055
## 6     theta    theta[2]  6.119185260  6.01580585  6.18379434
```

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

### Per Animal


##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

##Behavioral description

##Location of Behavior



# Overlap with Krill Fishery


#Time spent in grid cell

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-32-2.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->



##Traveling

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-35-2.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-38-2.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->


```
##                         Type      Size     PrettySize    Rows Columns
## jagM          rjags.parallel 712496752 [1] "679.5 Mb"       6      NA
## pc                    tbl_df 128147896 [1] "122.2 Mb" 2449000      10
## data                    list  72552256  [1] "69.2 Mb"       9      NA
## argos                  array  47265240  [1] "45.1 Mb"      34      21
## obs                    array  47265240  [1] "45.1 Mb"      34      21
## mdat              data.frame  24692824  [1] "23.5 Mb"   57230      54
## j                      array  23640224  [1] "22.5 Mb"      34      21
## d     SpatialPointsDataFrame  21189136  [1] "20.2 Mb"   49938      61
## oxy               data.frame  20387040  [1] "19.4 Mb"   49938      61
## mxy               data.frame  14834928  [1] "14.1 Mb"   32477      69
```

```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1844413   98.6    3886542  207.6   3886542  207.6
## Vcells 165915607 1265.9  284656791 2171.8 283066247 2159.7
```
