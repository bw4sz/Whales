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

Look at the observations were defined into tracks.

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
    phi[i,g,t,1] <- alpha_mu[state[i,g,t-1]] 
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
    phi[i,g,steps[i,g],1] <- alpha_mu[state[i,g,steps[i,g]-1]] 
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

    gamma[1] ~ dbeta(5,2)		## gamma for state 2
    dev ~ dunif(0,0.75)			## a random deviate to ensure that gamma[1] > gamma[2]
    gamma[2] <- gamma[1] * dev


    ##Behavioral States
    
    #Intercepts
    alpha_mu[1] ~ dbeta(1,1)
    alpha_mu[2] ~ dbeta(1,1)
    
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
##    1.625    0.044 1530.679
```



##Chains

```
##                         Type     Size    PrettySize  Rows Columns
## jagM          rjags.parallel 27839432 [1] "26.5 Mb"     6      NA
## mdat              data.frame 16339200 [1] "15.6 Mb" 49859      47
## m                      ggmap 13116192 [1] "12.5 Mb"  1280    1280
## b     SpatialPointsDataFrame  6303360    [1] "6 Mb"  8680      47
## data                    list  4056064  [1] "3.9 Mb"     9      NA
## mxy               grouped_df  2687208  [1] "2.6 Mb"  8676      52
## argos                  array  2647752  [1] "2.5 Mb"     5       5
## obs                    array  2647752  [1] "2.5 Mb"     5       5
## sxy                     list  2503728  [1] "2.4 Mb"     9      NA
## d     SpatialPointsDataFrame  2409144  [1] "2.3 Mb"  8680      47
```

```
##            used (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells  1554884 83.1    2637877 140.9  2637877 140.9
## Vcells 12421152 94.8   35613660 271.8 44509618 339.6
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->



![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

Look at the convergence of phi, just for an example

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

Overall relationship between phi and state, nice test of convergence.

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

## Parameter Summary

```
##   parameter         par       mean        lower      upper
## 1  alpha_mu alpha_mu[1] 0.78447565  0.604950773 0.92867766
## 2  alpha_mu alpha_mu[2] 0.18734226  0.059905914 0.39891959
## 3     gamma    gamma[1] 0.71848539  0.644721850 0.80429121
## 4     gamma    gamma[2] 0.04265901  0.001979177 0.10235927
## 5     theta    theta[1] 0.02804210 -0.019224032 0.07542159
## 6     theta    theta[2] 2.76478213  1.501835377 4.08880947
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

#Behavioral Prediction



Relationship between phi and state

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-31-2.png)<!-- -->

## By individual

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-32-2.png)<!-- -->

Overlay phi and state

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

## Compared to CMLRR regions

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

##Location of Behavior



# Overlap with Krill Fishery


#Time spent in grid cell



![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->





## ARS



![](SingleSpecies_files/figure-html/unnamed-chunk-43-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-43-2.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-43-3.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-46-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-47-1.png)<!-- -->


```
##                         Type     Size    PrettySize   Rows Columns
## pc                    tbl_df 16588208 [1] "15.8 Mb" 316800      10
## mdat              data.frame 16339200 [1] "15.6 Mb"  49859      47
## temp                   ggmap 13116288 [1] "12.5 Mb"   1280    1280
## b     SpatialPointsDataFrame  6303360    [1] "6 Mb"   8680      47
## a                     tbl_df  4267272  [1] "4.1 Mb" 106400       7
## data                    list  4056064  [1] "3.9 Mb"      9      NA
## mxy               data.frame  2882472  [1] "2.7 Mb"   8507      59
## argos                  array  2647752  [1] "2.5 Mb"      5       5
## obs                    array  2647752  [1] "2.5 Mb"      5       5
## d     SpatialPointsDataFrame  2409144  [1] "2.3 Mb"   8680      47
```

```
##            used (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells  1617084 86.4    2637877 140.9  2637877 140.9
## Vcells 10572870 80.7   34269113 261.5 44509618 339.6
```
