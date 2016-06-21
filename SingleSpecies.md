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



```
  [1] sink("Bayesian/Multi_RW.jags")                                                                                                  
  [2] cat("                                                                                                                           
  [3]     model{                                                                                                                      
  [4]                                                                                                                                 
  [5]     #Constants                                                                                                                  
  [6]     pi <- 3.141592653589                                                                                                        
  [7]                                                                                                                                 
  [8]     ##argos observation error##                                                                                                 
  [9]     argos_prec[1:2,1:2] <- inverse(argos_sigma*argos_cov[,])                                                                    
 [10]                                                                                                                                 
 [11]     #Constructing the covariance matrix                                                                                         
 [12]     argos_cov[1,1] <- 1                                                                                                         
 [13]     argos_cov[1,2] <- sqrt(argos_alpha) * rho                                                                                   
 [14]     argos_cov[2,1] <- sqrt(argos_alpha) * rho                                                                                   
 [15]     argos_cov[2,2] <- argos_alpha                                                                                               
 [16]                                                                                                                                 
 [17]     for(i in 1:ind){                                                                                                            
 [18]       for(g in 1:tracks[i]){                                                                                                    
 [19]                                                                                                                                 
 [20]         ###First Step###                                                                                                        
 [21]         ## Priors for first true location                                                                                       
 [22]         #for lat long                                                                                                           
 [23]         y[i,g,1,1:2] ~ dmnorm(argos[i,g,1,1,1:2],argos_prec)                                                                    
 [24]                                                                                                                                 
 [25]         #First movement - random walk.                                                                                          
 [26]         y[i,g,2,1:2] ~ dmnorm(y[i,g,1,1:2],iSigma)                                                                              
 [27]                                                                                                                                 
 [28]         ###First Behavioral State###                                                                                            
 [29]         state[i,g,1] ~ dcat(lambda[]) ## assign state for first obs                                                             
 [30]                                                                                                                                 
 [31]         #Process Model for movement                                                                                             
 [32]         for(t in 2:(steps[i,g]-1)){                                                                                             
 [33]                                                                                                                                 
 [34]         #Behavioral State at time T                                                                                             
 [35]         logit(phi[i,g,t,1]) <- lalpha[i,state[i,g,t-1]] + lbeta[i,state[i,g,t-1]] * ocean[i,g,t]                                
 [36]         phi[i,g,t,2] <- 1-phi[i,g,t,1]                                                                                          
 [37]         state[i,g,t] ~ dcat(phi[i,g,t,])                                                                                        
 [38]                                                                                                                                 
 [39]         #Turning covariate                                                                                                      
 [40]         #Transition Matrix for turning angles                                                                                   
 [41]         T[i,g,t,1,1] <- cos(theta[state[i,g,t]])                                                                                
 [42]         T[i,g,t,1,2] <- (-sin(theta[state[i,g,t]]))                                                                             
 [43]         T[i,g,t,2,1] <- sin(theta[state[i,g,t]])                                                                                
 [44]         T[i,g,t,2,2] <- cos(theta[state[i,g,t]])                                                                                
 [45]                                                                                                                                 
 [46]         #Correlation in movement change                                                                                         
 [47]         d[i,g,t,1:2] <- y[i,g,t,] + gamma[state[i,g,t]] * T[i,g,t,,] %*% (y[i,g,t,1:2] - y[i,g,t-1,1:2])                        
 [48]                                                                                                                                 
 [49]         #Gaussian Displacement                                                                                                  
 [50]         y[i,g,t+1,1:2] ~ dmnorm(d[i,g,t,1:2],iSigma)                                                                            
 [51]       }                                                                                                                         
 [52]                                                                                                                                 
 [53]     #Final behavior state                                                                                                       
 [54]     logit(phi[i,g,steps[i,g],1]) <- lalpha[i,state[i,g,steps[i,g]-1]] + lbeta[i,state[i,g,steps[i,g]-1]] * ocean[i,g,steps[i,g]]
 [55]     phi[i,g,steps[i,g],2] <- 1-phi[i,g,steps[i,g],1]                                                                            
 [56]     state[i,g,steps[i,g]] ~ dcat(phi[i,g,steps[i,g],])                                                                          
 [57]                                                                                                                                 
 [58]     ##\tMeasurement equation - irregular observations                                                                           
 [59]     # loops over regular time intervals (t)                                                                                     
 [60]                                                                                                                                 
 [61]     for(t in 2:steps[i,g]){                                                                                                     
 [62]                                                                                                                                 
 [63]     # loops over observed locations within interval t                                                                           
 [64]     for(u in 1:idx[i,g,t]){                                                                                                     
 [65]       zhat[i,g,t,u,1:2] <- (1-j[i,g,t,u]) * y[i,g,t-1,1:2] + j[i,g,t,u] * y[i,g,t,1:2]                                          
 [66]                                                                                                                                 
 [67]         #for each lat and long                                                                                                  
 [68]           #argos error                                                                                                          
 [69]           argos[i,g,t,u,1:2] ~ dmnorm(zhat[i,g,t,u,1:2],argos_prec)                                                             
 [70]           }                                                                                                                     
 [71]         }                                                                                                                       
 [72]       }                                                                                                                         
 [73]     }                                                                                                                           
 [74]     ###Priors###                                                                                                                
 [75]                                                                                                                                 
 [76]     #Process Variance                                                                                                           
 [77]     iSigma ~ dwish(R,2)                                                                                                         
 [78]     Sigma <- inverse(iSigma)                                                                                                    
 [79]                                                                                                                                 
 [80]     ##Mean Angle                                                                                                                
 [81]     tmp[1] ~ dbeta(10, 10)                                                                                                      
 [82]     tmp[2] ~ dbeta(10, 10)                                                                                                      
 [83]                                                                                                                                 
 [84]     # prior for theta in 'traveling state'                                                                                      
 [85]     theta[1] <- (2 * tmp[1] - 1) * pi                                                                                           
 [86]                                                                                                                                 
 [87]     # prior for theta in 'foraging state'                                                                                       
 [88]     theta[2] <- (tmp[2] * pi * 2)                                                                                               
 [89]                                                                                                                                 
 [90]     ##Move persistance                                                                                                          
 [91]     # prior for gamma (autocorrelation parameter) in state 1                                                                    
 [92]     gamma[1] ~ dbeta(5,2)                                                                                                       
 [93]                                                                                                                                 
 [94]     # prior for gamma in state 2                                                                                                
 [95]     gamma[2] ~ dbeta(2,5)                                                                                                       
 [96]                                                                                                                                 
 [97]     ##Behavioral States                                                                                                         
 [98]     # Following lunn 2012 p85                                                                                                   
 [99]                                                                                                                                 
[100]     #Hierarchical structure                                                                                                     
[101]     #Intercepts                                                                                                                 
[102]     lalpha_mu[1] ~ dnorm(0,0.386)                                                                                               
[103]     lalpha_mu[2] ~ dnorm(0,0.386)                                                                                               
[104]                                                                                                                                 
[105]     #Variance                                                                                                                   
[106]     lalpha_tau[1] ~ dt(0,1,1)I(0,)                                                                                              
[107]     lalpha_tau[2] ~ dt(0,1,1)I(0,)                                                                                              
[108]                                                                                                                                 
[109]     #Slopes                                                                                                                     
[110]     lbeta_mu[1] ~ dnorm(0,0.386)                                                                                                
[111]     lbeta_mu[2] ~ dnorm(0,0.386)                                                                                                
[112]                                                                                                                                 
[113]     #Variance                                                                                                                   
[114]     lbeta_tau[1] ~ dt(0,1,1)I(0,)                                                                                               
[115]     lbeta_tau[2] ~ dt(0,1,1)I(0,)                                                                                               
[116]                                                                                                                                 
[117]     #For each individual                                                                                                        
[118]     for(i in 1:ind){                                                                                                            
[119]       # prob of being in state 1 at t, given in state 1 at t-1                                                                  
[120]       #Individual Intercept                                                                                                     
[121]       lalpha[i,1] ~ dnorm(lalpha_mu[1],lalpha_tau[1])                                                                           
[122]       logit(alpha[i,1]) <- lalpha[i,1]                                                                                          
[123]                                                                                                                                 
[124]       #effect of ocean on traveling -> traveling                                                                                
[125]       lbeta[i,1] ~ dnorm(lbeta_mu[1],lbeta_tau[1])                                                                              
[126]       logit(beta[i,1]) <- lbeta[i,1]                                                                                            
[127]                                                                                                                                 
[128]       #Prob of transition to state 1 given state 2 at t-1                                                                       
[129]       lalpha[i,2] ~ dnorm(lalpha_mu[2],lalpha_tau[2])                                                                           
[130]       logit(alpha[i,2]) <- lalpha[i,2]                                                                                          
[131]                                                                                                                                 
[132]       #effect of ocean on feeding -> traveling                                                                                  
[133]       lbeta[i,2] ~ dnorm(lbeta_mu[2],lbeta_tau[2])                                                                              
[134]       logit(beta[i,2]) <- lbeta[i,2]                                                                                            
[135]                                                                                                                                 
[136]     }                                                                                                                           
[137]                                                                                                                                 
[138]     #Probability of behavior switching                                                                                          
[139]     lambda[1] ~ dbeta(1,1)                                                                                                      
[140]     lambda[2] <- 1 - lambda[1]                                                                                                  
[141]                                                                                                                                 
[142]     ##Argos priors##                                                                                                            
[143]     #longitudinal argos error                                                                                                   
[144]     argos_sigma ~ dunif(0,10)                                                                                                   
[145]                                                                                                                                 
[146]     #latitidunal argos error                                                                                                    
[147]     argos_alpha~dunif(0,10)                                                                                                     
[148]                                                                                                                                 
[149]     #correlation in argos error                                                                                                 
[150]     rho ~ dunif(-1, 1)                                                                                                          
[151]                                                                                                                                 
[152]                                                                                                                                 
[153]     }"                                                                                                                          
[154]     ,fill=TRUE)                                                                                                                 
[155] sink()                                                                                                                          
```


```
##     user   system  elapsed 
##   47.034    1.485 2330.062
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

##Prediction - environmental function

![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-8.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-9.png)<!-- -->


### Per Track

```
## $`1.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

```
## 
## $`2.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-2.png)<!-- -->

```
## 
## $`3.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-3.png)<!-- -->

```
## 
## $`4.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-4.png)<!-- -->

```
## 
## $`5.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-5.png)<!-- -->

```
## 
## $`6.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-6.png)<!-- -->

```
## 
## $`7.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-7.png)<!-- -->

```
## 
## $`8.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-8.png)<!-- -->

```
## 
## $`9.1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-9.png)<!-- -->

```
## 
## $`1.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-10.png)<!-- -->

```
## 
## $`2.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-11.png)<!-- -->

```
## 
## $`3.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-12.png)<!-- -->

```
## 
## $`4.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-13.png)<!-- -->

```
## 
## $`7.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-14.png)<!-- -->

```
## 
## $`8.2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-15.png)<!-- -->

```
## 
## $`1.3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-16.png)<!-- -->

```
## 
## $`2.3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-17.png)<!-- -->

```
## 
## $`3.3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-18.png)<!-- -->

```
## 
## $`4.3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-19.png)<!-- -->

```
## 
## $`7.3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-20.png)<!-- -->

```
## 
## $`2.4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-21.png)<!-- -->

```
## 
## $`4.4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-22.png)<!-- -->

```
## 
## $`7.4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-23.png)<!-- -->

```
## 
## $`2.5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-24.png)<!-- -->

```
## 
## $`4.5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-25.png)<!-- -->

```
## 
## $`7.5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-26.png)<!-- -->

```
## 
## $`2.6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-27.png)<!-- -->

```
## 
## $`4.6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-28.png)<!-- -->

```
## 
## $`7.6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-29.png)<!-- -->

```
## 
## $`2.7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-30.png)<!-- -->

```
## 
## $`4.7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-31.png)<!-- -->

```
## 
## $`2.8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-32.png)<!-- -->

```
## 
## $`4.8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-33.png)<!-- -->

```
## 
## $`2.9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-34.png)<!-- -->

```
## 
## $`4.9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-35.png)<!-- -->

```
## 
## $`2.10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-36.png)<!-- -->

```
## 
## $`4.10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-37.png)<!-- -->

```
## 
## $`2.11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-38.png)<!-- -->

```
## 
## $`4.11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-39.png)<!-- -->

```
## 
## $`2.12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-40.png)<!-- -->

```
## 
## $`4.12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-41.png)<!-- -->

```
## 
## $`2.13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-42.png)<!-- -->

```
## 
## $`4.13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-43.png)<!-- -->

```
## 
## $`4.14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-44.png)<!-- -->

```
## 
## $`4.15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-45.png)<!-- -->

```
## 
## $`4.16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-46.png)<!-- -->

```
## 
## $`4.17`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-47.png)<!-- -->

```
## 
## $`4.18`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-48.png)<!-- -->

```
## 
## $`4.19`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-49.png)<!-- -->

```
## 
## $`4.20`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-50.png)<!-- -->

```
## 
## $`4.21`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-51.png)<!-- -->

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

Just the West Antarctic Penisula

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

###Proportional Hazards

TODO: NEEDS TO ACCOUNT FOR CENSORED DATA! 

Survival analysis typically examines the relationship between time to death as a function of covariates. From this we can get the instantaneous rate of death at time t f(t), which is the cumulative distribution of the likelihood of death.

Let T represent survival time.

$$ P(t) = Pr(T<t)$$ 
with a pdf
$$p(t) = \frac{dP(t)}{dt}$$

The instantaneous risk of death at time t (h(t)), conditional on survival to that time:

$$ h(t) = \lim{\Delta_t\to 0} \frac{Pr[(t<T<t + \Delta_t)]|T>t}{\Delta t}$$

with covariates:
$$log (h_i(t)) = \alpha + \beta_i *x$$

The cox model has no intercept, making it semi-parametric
$$ log(h_i(t)) = h_0(t) + \beta_1 * x$$




```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1630692   87.1    5295264  282.8   8273852  441.9
## Vcells 342186930 2610.7  671329130 5121.9 627329149 4786.2
```
