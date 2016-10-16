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
\end{matrix}$$


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
    tmp[1] ~ dbeta(20, 20)
    tmp[2] ~ dbeta(10, 10)
    
    # prior for theta in 'traveling state'
    theta[1] <- (2 * tmp[1] - 1) * pi
    
    # prior for theta in 'foraging state'    
    theta[2] <- (tmp[2] * pi * 2)
    
    ##Move persistance
    # prior for gamma (autocorrelation parameter)
    #from jonsen 2016
    gamma[2] ~ dunif(0, 0.2)		## gamma for state 2
    #dev[m] ~ dbeta(1,1)			## a random deviate to ensure that gamma[1] > gamma[2]
    gamma[1] ~  dunif(0.3, 1.5)		## gamma for state 1
    
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
##   362.170     1.729 68269.238
```





##Chains

```
##                         Type      Size    PrettySize  Rows Columns
## jagM          rjags.parallel 718295888  [1] "685 Mb"     6      NA
## data                    list  98589376   [1] "94 Mb"     9      NA
## argos                  array  64822160 [1] "61.8 Mb"    41      15
## obs                    array  64822160 [1] "61.8 Mb"    41      15
## j                      array  32418856 [1] "30.9 Mb"    41      15
## b     SpatialPointsDataFrame  16418080 [1] "15.7 Mb" 46421      47
## mdat              data.frame  16339200 [1] "15.6 Mb" 49859      47
## mxy               grouped_df  14007880 [1] "13.4 Mb" 45503      52
## sxy                     list  13968744 [1] "13.3 Mb"   118      NA
## m                      ggmap  13116000 [1] "12.5 Mb"  1280    1280
```

```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1728381   92.4    3205452  171.2   3205452  171.2
## Vcells 162396088 1239.0  305914654 2334.0 265376812 2024.7
```


![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->



![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

## Parameter Summary

```
##   parameter         par        mean       lower       upper
## 1  alpha_mu alpha_mu[1] -2.42457635 -3.29843295 -1.74781476
## 2  alpha_mu alpha_mu[2] -1.49429763 -1.71709984 -1.25777321
## 3     gamma    gamma[1]  1.33042798  1.22304637  1.43671316
## 4     gamma    gamma[2]  0.19623052  0.18885202  0.19981976
## 5     theta    theta[1]  0.01671501 -0.01960704  0.04981802
## 6     theta    theta[2]  6.20915101  6.17413375  6.24091698
```

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

Compared to CMLRR regions

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-28-2.png)<!-- -->

### Per Animal


##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

##Behavioral description

##Location of Behavior



# Overlap with Krill Fishery


#Time spent in grid cell

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-33-2.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->



##Traveling

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-36-2.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-39-2.png)<!-- -->


![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-43-1.png)<!-- -->


```
##                           Type      Size    PrettySize    Rows Columns
## pc                      tbl_df 125835184  [1] "120 Mb" 2407750      10
## data                      list  98589376   [1] "94 Mb"       9      NA
## argos                    array  64822160 [1] "61.8 Mb"      41      15
## obs                      array  64822160 [1] "61.8 Mb"      41      15
## ssm   SpatialPolygonsDataFrame  60340504 [1] "57.5 Mb"      17       6
## j                        array  32418856 [1] "30.9 Mb"      41      15
## csmm  SpatialPolygonsDataFrame  26291800 [1] "25.1 Mb"       8       6
## b       SpatialPointsDataFrame  16418080 [1] "15.7 Mb"   46421      47
## mdat                data.frame  16339200 [1] "15.6 Mb"   49859      47
## sxy                       list  13823352 [1] "13.2 Mb"      41      NA
```

```
##            used  (Mb) gc trigger  (Mb)  max used   (Mb)
## Ncells  2501438 133.6    4703850 251.3   4703850  251.3
## Vcells 46143113 352.1  125302641 956.0 305914654 2334.0
```
