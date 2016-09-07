# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  









#Descriptive Statistics


![](SingleSpecies_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

##By Month

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

##Environment

Behavioral states are a function of local environmental conditions. The first environmental condition is ocean depth. I then build a function for preferential foraging in shallow waters.

It generally follows the form, conditional on behavior at t -1:

$$Behavior_t \sim Multinomial([\phi_{traveling},\phi_{foraging}])$$

With the probability of switching states:

$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}} + \beta_{Month,1} * Ocean_{y[t,]} + \beta_{Month,2} * Coast_{y[t,]}$$

$$logit(\phi_{foraging}) = \alpha_{Behavior_{t-1}} $$

Following Bestley in preferring to describe the switch into feeding, but no estimating the resumption of traveling.

The effect of the environment is temporally variable such that

$$ \beta_{Month,2} \sim ~ Normal(\beta_{\mu},\beta_\tau)$$




##Continious tracks

The transmitter will often go dark for 10 to 12 hours, due to weather, right in the middle of an otherwise good track. The model requires regular intervals to estimate the turning angles and temporal autocorrelation. As a track hits one of these walls, call it the end of a track, and begin a new track once the weather improves. We can remove any micro-tracks that are less than three days.
Specify a duration, calculate the number of tracks and the number of removed points. Iteratively.





How did the filter change the extent of tracks?

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-16-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-17-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-17-2.png)<!-- -->


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
    logit(phi[i,g,t,1]) <- alpha_mu[state[i,g,t-1]] + beta[Month[i,g,t-1],state[i,g,t-1]] * ocean[i,g,t] + beta2[Month[i,g,t-1],state[i,g,t-1]] * coast[i,g,t]
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
    logit(phi[i,g,steps[i,g],1]) <- alpha_mu[state[i,g,steps[i,g]-1]] + beta[Month[i,g,steps[i,g]-1],state[i,g,steps[i,g]-1]] * ocean[i,g,steps[i,g]] + beta2[Month[i,g,steps[i,g]-1],state[i,g,steps[i,g]-1]] * coast[i,g,steps[i,g]]
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
    gamma[2] ~ dbeta(1.5, 5)		## gamma for state 2
    dev ~ dbeta(1,1)			## a random deviate to ensure that gamma[1] > gamma[2]
    gamma[1] <- gamma[2] + dev 		## gamma for state 1
    
    
    #Monthly Covaraites
    for(x in 1:Months){
    beta[x,1]~dnorm(beta_mu[1],beta_tau[1])
    beta[x,2]<-0
    beta2[x,1]~dnorm(beta2_mu[1],beta2_tau[1])
    beta2[x,2]<-0
    }
    
    ##Behavioral States
    
    #Hierarchical structure across motnhs
    #Intercepts
    alpha_mu[1] ~ dnorm(0,0.386)
    alpha_mu[2] ~ dnorm(0,0.386)
    
    #Variance
    alpha_tau[1] ~ dt(0,1,1)I(0,)
    alpha_tau[2] ~ dt(0,1,1)I(0,)
    
    #Slopes
    ## Ocean Depth
    beta_mu[1] ~ dnorm(0,0.386)
    beta_mu[2] = 0
    
    # Distance coast
    beta2_mu[1] ~ dnorm(0,0.386)
    beta2_mu[2] = 0
    
    #Monthly Variance
    #Ocean
    beta_tau[1] ~ dt(0,1,1)I(0,)
    beta_tau[2] = 0
    
    #Coast
    beta2_tau[1] ~ dt(0,1,1)I(0,)
    beta2_tau[2]  = 0
    
    
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
##       user     system    elapsed 
##    425.838      2.132 142562.746
```



##Chains

```
##                         Type      Size    PrettySize  Rows Columns
## jagM          rjags.parallel 473946664  [1] "452 Mb"     6      NA
## data                    list  74728304 [1] "71.3 Mb"    11      NA
## argos                  array  47265240 [1] "45.1 Mb"    34      21
## obs                    array  47265240 [1] "45.1 Mb"    34      21
## mdat              data.frame  26066656 [1] "24.9 Mb" 57230      57
## j                      array  23640224 [1] "22.5 Mb"    34      21
## d     SpatialPointsDataFrame  22387960 [1] "21.4 Mb" 49938      64
## oxy               data.frame  21585864 [1] "20.6 Mb" 49938      64
## sxy                     list  18067424 [1] "17.2 Mb"   188      NA
## mxy               grouped_df  16758528   [1] "16 Mb" 34484      69
```

```
##             used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1640746  87.7    3205452  171.2   3205452  171.2
## Vcells 110859996 845.8  205553718 1568.3 205553518 1568.3
```

```
##            used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells  1500843  80.2    3205452  171.2   3205452  171.2
## Vcells 18261485 139.4  164442974 1254.7 205553518 1568.3
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

## Parameter Summary

```
##    parameter         par         mean        lower        upper
## 1   alpha_mu alpha_mu[1] -0.587529796 -1.015184420 -0.152447154
## 2   alpha_mu alpha_mu[2] -1.563433562 -1.936021183 -1.231049424
## 3       beta   beta[1,1] -0.471920667 -1.819158184  0.920936875
## 4       beta   beta[2,1] -0.799143679 -2.216653731  0.221961056
## 5       beta   beta[3,1]  0.020219959 -1.139794932  0.931900321
## 6       beta   beta[4,1]  0.383622121 -0.566287958  1.565239780
## 7       beta   beta[5,1] -0.188857597 -1.370726940  1.285232410
## 8       beta   beta[6,1] -0.132707742 -2.129637079  1.674876693
## 9       beta   beta[1,2]  0.000000000  0.000000000  0.000000000
## 10      beta   beta[2,2]  0.000000000  0.000000000  0.000000000
## 11      beta   beta[3,2]  0.000000000  0.000000000  0.000000000
## 12      beta   beta[4,2]  0.000000000  0.000000000  0.000000000
## 13      beta   beta[5,2]  0.000000000  0.000000000  0.000000000
## 14      beta   beta[6,2]  0.000000000  0.000000000  0.000000000
## 15     beta2  beta2[1,1]  0.025974964  0.010584399  0.045291144
## 16     beta2  beta2[2,1]  0.020849719  0.008934419  0.035986856
## 17     beta2  beta2[3,1]  0.017808854  0.004823071  0.030612541
## 18     beta2  beta2[4,1]  0.022402314  0.008914916  0.039013603
## 19     beta2  beta2[5,1]  0.095173797  0.031976100  0.177862765
## 20     beta2  beta2[6,1]  0.009560674 -0.152089119  0.116002149
## 21     beta2  beta2[1,2]  0.000000000  0.000000000  0.000000000
## 22     beta2  beta2[2,2]  0.000000000  0.000000000  0.000000000
## 23     beta2  beta2[3,2]  0.000000000  0.000000000  0.000000000
## 24     beta2  beta2[4,2]  0.000000000  0.000000000  0.000000000
## 25     beta2  beta2[5,2]  0.000000000  0.000000000  0.000000000
## 26     beta2  beta2[6,2]  0.000000000  0.000000000  0.000000000
## 27  beta2_mu beta2_mu[1]  0.032250858 -0.018777087  0.091527106
## 28  beta2_mu beta2_mu[2]  0.000000000  0.000000000  0.000000000
## 29   beta_mu  beta_mu[1] -0.148457488 -1.080190552  0.839051942
## 30   beta_mu  beta_mu[2]  0.000000000  0.000000000  0.000000000
## 31     gamma    gamma[1]  0.929247370  0.895830063  0.959317558
## 32     gamma    gamma[2]  0.170241902  0.133220235  0.206685932
## 33     theta    theta[1] -0.027871011 -0.052277094 -0.006148731
## 34     theta    theta[2]  0.226868230  0.141164584  0.320152731
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

#Behavior and environment

##Hierarchical 

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-28-2.png)<!-- -->

###Interaction

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

## By Month

### Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-30-2.png)<!-- -->

Just the probability of feeding when traveling.

![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

Just mean estimate.

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-32-2.png)<!-- -->

### Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-33-2.png)<!-- -->

Zooming in on the top right plot.
![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-34-2.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-34-3.png)<!-- -->

Just mean estimate.

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-35-2.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

### Per Animal


##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

##Behavioral description

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging across time



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->

##All variables

![](SingleSpecies_files/figure-html/unnamed-chunk-46-1.png)<!-- -->

# Overlap with Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-47-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-48-1.png)<!-- -->

## By Month





## Change in foraging areas

Jan verus May

Red = Better Foraging in Jan
Blue = Better Foraging in May

![](SingleSpecies_files/figure-html/unnamed-chunk-51-1.png)<!-- -->

### Variance in monthly suitability

![](SingleSpecies_files/figure-html/unnamed-chunk-52-1.png)<!-- -->

### Mean suitability

![](SingleSpecies_files/figure-html/unnamed-chunk-53-1.png)<!-- -->

## Monthly Overlap with Krill Fishery

![](SingleSpecies_files/figure-html/unnamed-chunk-54-1.png)<!-- -->



```
##                           Type     Size    PrettySize    Rows Columns
## pc                      tbl_df 90898112 [1] "86.7 Mb" 1613600      12
## mdat                data.frame 26066656 [1] "24.9 Mb"   57230      57
## d       SpatialPointsDataFrame 22387960 [1] "21.4 Mb"   49938      64
## oxy                 data.frame 21585864 [1] "20.6 Mb"   49938      64
## sxy                       list 18067424 [1] "17.2 Mb"     188      NA
## mxy                 data.frame 15224248 [1] "14.5 Mb"   32477      70
## temp                     ggmap 13116048 [1] "12.5 Mb"    1280    1280
## allplot             grouped_df  2710232  [1] "2.6 Mb"   52056       7
## msp     SpatialPointsDataFrame  1823384  [1] "1.7 Mb"   32477       5
## coast                    array  1087976    [1] "1 Mb"      34      21
```

```
##            used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells  1630073  87.1    6860029  366.4  14442815  771.4
## Vcells 33767586 257.7  207377168 1582.2 405033533 3090.2
```
