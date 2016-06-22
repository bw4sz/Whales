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
 [20]         ## Priors for first true location                                                                                       
 [21]         #for lat long                                                                                                           
 [22]         y[i,g,1,1:2] ~ dmnorm(argos[i,g,1,1,1:2],argos_prec)                                                                    
 [23]                                                                                                                                 
 [24]         #First movement - random walk.                                                                                          
 [25]         y[i,g,2,1:2] ~ dmnorm(y[i,g,1,1:2],iSigma)                                                                              
 [26]                                                                                                                                 
 [27]         ###First Behavioral State###                                                                                            
 [28]         state[i,g,1] ~ dcat(lambda[]) ## assign state for first obs                                                             
 [29]                                                                                                                                 
 [30]         #Process Model for movement                                                                                             
 [31]         for(t in 2:(steps[i,g]-1)){                                                                                             
 [32]                                                                                                                                 
 [33]         #Behavioral State at time T                                                                                             
 [34]         logit(phi[i,g,t,1]) <- lalpha[i,state[i,g,t-1]] + lbeta[i,state[i,g,t-1]] * ocean[i,g,t]                                
 [35]         phi[i,g,t,2] <- 1-phi[i,g,t,1]                                                                                          
 [36]         state[i,g,t] ~ dcat(phi[i,g,t,])                                                                                        
 [37]                                                                                                                                 
 [38]         #Turning covariate                                                                                                      
 [39]         #Transition Matrix for turning angles                                                                                   
 [40]         T[i,g,t,1,1] <- cos(theta[state[i,g,t]])                                                                                
 [41]         T[i,g,t,1,2] <- (-sin(theta[state[i,g,t]]))                                                                             
 [42]         T[i,g,t,2,1] <- sin(theta[state[i,g,t]])                                                                                
 [43]         T[i,g,t,2,2] <- cos(theta[state[i,g,t]])                                                                                
 [44]                                                                                                                                 
 [45]         #Correlation in movement change                                                                                         
 [46]         d[i,g,t,1:2] <- y[i,g,t,] + gamma[state[i,g,t]] * T[i,g,t,,] %*% (y[i,g,t,1:2] - y[i,g,t-1,1:2])                        
 [47]                                                                                                                                 
 [48]         #Gaussian Displacement                                                                                                  
 [49]         y[i,g,t+1,1:2] ~ dmnorm(d[i,g,t,1:2],iSigma)                                                                            
 [50]       }                                                                                                                         
 [51]                                                                                                                                 
 [52]     #Final behavior state                                                                                                       
 [53]     logit(phi[i,g,steps[i,g],1]) <- lalpha[i,state[i,g,steps[i,g]-1]] + lbeta[i,state[i,g,steps[i,g]-1]] * ocean[i,g,steps[i,g]]
 [54]     phi[i,g,steps[i,g],2] <- 1-phi[i,g,steps[i,g],1]                                                                            
 [55]     state[i,g,steps[i,g]] ~ dcat(phi[i,g,steps[i,g],])                                                                          
 [56]                                                                                                                                 
 [57]     ##\tMeasurement equation - irregular observations                                                                           
 [58]     # loops over regular time intervals (t)                                                                                     
 [59]                                                                                                                                 
 [60]     for(t in 2:steps[i,g]){                                                                                                     
 [61]                                                                                                                                 
 [62]     # loops over observed locations within interval t                                                                           
 [63]     for(u in 1:idx[i,g,t]){                                                                                                     
 [64]       zhat[i,g,t,u,1:2] <- (1-j[i,g,t,u]) * y[i,g,t-1,1:2] + j[i,g,t,u] * y[i,g,t,1:2]                                          
 [65]                                                                                                                                 
 [66]         #for each lat and long                                                                                                  
 [67]           #argos error                                                                                                          
 [68]           argos[i,g,t,u,1:2] ~ dmnorm(zhat[i,g,t,u,1:2],argos_prec)                                                             
 [69]           }                                                                                                                     
 [70]         }                                                                                                                       
 [71]       }                                                                                                                         
 [72]     }                                                                                                                           
 [73]     ###Priors###                                                                                                                
 [74]                                                                                                                                 
 [75]     #Process Variance                                                                                                           
 [76]     iSigma ~ dwish(R,2)                                                                                                         
 [77]     Sigma <- inverse(iSigma)                                                                                                    
 [78]                                                                                                                                 
 [79]     ##Mean Angle                                                                                                                
 [80]     tmp[1] ~ dbeta(10, 10)                                                                                                      
 [81]     tmp[2] ~ dbeta(10, 10)                                                                                                      
 [82]                                                                                                                                 
 [83]     # prior for theta in 'traveling state'                                                                                      
 [84]     theta[1] <- (2 * tmp[1] - 1) * pi                                                                                           
 [85]                                                                                                                                 
 [86]     # prior for theta in 'foraging state'                                                                                       
 [87]     theta[2] <- (tmp[2] * pi * 2)                                                                                               
 [88]                                                                                                                                 
 [89]     ##Move persistance                                                                                                          
 [90]     # prior for gamma (autocorrelation parameter) in state 1                                                                    
 [91]     gamma[1] ~ dbeta(5,2)                                                                                                       
 [92]                                                                                                                                 
 [93]     # prior for gamma in state 2                                                                                                
 [94]     gamma[2] ~ dbeta(2,5)                                                                                                       
 [95]                                                                                                                                 
 [96]     ##Behavioral States                                                                                                         
 [97]     # Following lunn 2012 p85                                                                                                   
 [98]                                                                                                                                 
 [99]     #Hierarchical structure                                                                                                     
[100]     #Intercepts                                                                                                                 
[101]     lalpha_mu[1] ~ dnorm(0,0.386)                                                                                               
[102]     lalpha_mu[2] ~ dnorm(0,0.386)                                                                                               
[103]                                                                                                                                 
[104]     #Variance                                                                                                                   
[105]     lalpha_tau[1] ~ dt(0,1,1)I(0,)                                                                                              
[106]     lalpha_tau[2] ~ dt(0,1,1)I(0,)                                                                                              
[107]                                                                                                                                 
[108]     #Slopes                                                                                                                     
[109]     lbeta_mu[1] ~ dnorm(0,0.386)                                                                                                
[110]     lbeta_mu[2] ~ dnorm(0,0.386)                                                                                                
[111]                                                                                                                                 
[112]     #Variance                                                                                                                   
[113]     lbeta_tau[1] ~ dt(0,1,1)I(0,)                                                                                               
[114]     lbeta_tau[2] ~ dt(0,1,1)I(0,)                                                                                               
[115]                                                                                                                                 
[116]     #For each individual                                                                                                        
[117]     for(i in 1:ind){                                                                                                            
[118]       # prob of being in state 1 at t, given in state 1 at t-1                                                                  
[119]       #Individual Intercept                                                                                                     
[120]       lalpha[i,1] ~ dnorm(lalpha_mu[1],lalpha_tau[1])                                                                           
[121]       logit(alpha[i,1]) <- lalpha[i,1]                                                                                          
[122]                                                                                                                                 
[123]       #effect of ocean on traveling -> traveling                                                                                
[124]       lbeta[i,1] ~ dnorm(lbeta_mu[1],lbeta_tau[1])                                                                              
[125]       logit(beta[i,1]) <- lbeta[i,1]                                                                                            
[126]                                                                                                                                 
[127]       #Prob of transition to state 1 given state 2 at t-1                                                                       
[128]       lalpha[i,2] ~ dnorm(lalpha_mu[2],lalpha_tau[2])                                                                           
[129]       logit(alpha[i,2]) <- lalpha[i,2]                                                                                          
[130]                                                                                                                                 
[131]       #effect of ocean on feeding -> traveling                                                                                  
[132]       lbeta[i,2] ~ dnorm(lbeta_mu[2],lbeta_tau[2])                                                                              
[133]       logit(beta[i,2]) <- lbeta[i,2]                                                                                            
[134]                                                                                                                                 
[135]     }                                                                                                                           
[136]                                                                                                                                 
[137]     #Probability of behavior switching                                                                                          
[138]     lambda[1] ~ dbeta(1,1)                                                                                                      
[139]     lambda[2] <- 1 - lambda[1]                                                                                                  
[140]                                                                                                                                 
[141]     ##Argos priors##                                                                                                            
[142]     #longitudinal argos error                                                                                                   
[143]     argos_sigma ~ dunif(0,10)                                                                                                   
[144]                                                                                                                                 
[145]     #latitidunal argos error                                                                                                    
[146]     argos_alpha~dunif(0,10)                                                                                                     
[147]                                                                                                                                 
[148]     #correlation in argos error                                                                                                 
[149]     rho ~ dunif(-1, 1)                                                                                                          
[150]                                                                                                                                 
[151]                                                                                                                                 
[152]     }"                                                                                                                          
[153]     ,fill=TRUE)                                                                                                                 
[154] sink()                                                                                                                          
```


```
##      user    system   elapsed 
##   130.667     2.626 11640.817
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

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-10.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-11.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-12.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-13.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-14.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-15.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-16.png)<!-- -->

```
## 
## $`17`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-17.png)<!-- -->

```
## 
## $`18`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-18.png)<!-- -->

```
## 
## $`19`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-19.png)<!-- -->

```
## 
## $`20`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-20.png)<!-- -->

```
## 
## $`21`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-21.png)<!-- -->

```
## 
## $`22`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-22.png)<!-- -->

```
## 
## $`23`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-23.png)<!-- -->

```
## 
## $`24`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-24.png)<!-- -->

```
## 
## $`25`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-25.png)<!-- -->

```
## 
## $`26`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-26.png)<!-- -->

```
## 
## $`27`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-27.png)<!-- -->

```
## 
## $`28`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-28.png)<!-- -->

```
## 
## $`29`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-29.png)<!-- -->

```
## 
## $`30`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-30.png)<!-- -->

```
## 
## $`31`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-31.png)<!-- -->

##Log Odds of Feeding
![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

##Location of Behavior



Global Plotting

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

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
## Call:
## coxph(formula = Surv(time = feedr$hours, event = feedr$status, 
##     type = "right") ~ feedr$Animal)
## 
##   n= 527988, number of events= 509519 
## 
##                     coef exp(coef)  se(coef)        z Pr(>|z|)    
## feedr$Animal10 -0.608163  0.544350  0.006065 -100.282  < 2e-16 ***
## feedr$Animal11  0.812528  2.253597  0.006006  135.293  < 2e-16 ***
## feedr$Animal12 -0.840694  0.431411  0.030729  -27.359  < 2e-16 ***
## feedr$Animal13 -0.550772  0.576505  0.026514  -20.773  < 2e-16 ***
## feedr$Animal14 -0.497888  0.607813  0.017281  -28.812  < 2e-16 ***
## feedr$Animal15  0.162137  1.176022  0.016272    9.964  < 2e-16 ***
## feedr$Animal16 -0.728115  0.482818  0.016983  -42.874  < 2e-16 ***
## feedr$Animal17 -0.475245  0.621733  0.023478  -20.242  < 2e-16 ***
## feedr$Animal18  1.239468  3.453776  0.071395   17.361  < 2e-16 ***
## feedr$Animal19 -0.374375  0.687719  0.020812  -17.988  < 2e-16 ***
## feedr$Animal2   0.648994  1.913615  0.008411   77.159  < 2e-16 ***
## feedr$Animal20 -0.277504  0.757673  0.021986  -12.622  < 2e-16 ***
## feedr$Animal21 -0.791020  0.453382  0.009059  -87.319  < 2e-16 ***
## feedr$Animal22  0.170786  1.186237  0.007073   24.146  < 2e-16 ***
## feedr$Animal23  0.773271  2.166843  0.013474   57.391  < 2e-16 ***
## feedr$Animal24  0.306399  1.358524  0.021581   14.197  < 2e-16 ***
## feedr$Animal25  0.313100  1.367658  0.012791   24.478  < 2e-16 ***
## feedr$Animal26 -0.696144  0.498504  0.013063  -53.291  < 2e-16 ***
## feedr$Animal27  0.155010  1.167670  0.007368   21.039  < 2e-16 ***
## feedr$Animal28  0.217012  1.242358  0.011909   18.223  < 2e-16 ***
## feedr$Animal29 -0.566186  0.567687  0.010653  -53.149  < 2e-16 ***
## feedr$Animal3  -0.805941  0.446667  0.007835 -102.863  < 2e-16 ***
## feedr$Animal30  0.336989  1.400724  0.006665   50.560  < 2e-16 ***
## feedr$Animal31 -1.011815  0.363558  0.019013  -53.217  < 2e-16 ***
## feedr$Animal4   0.175971  1.192403  0.009431   18.658  < 2e-16 ***
## feedr$Animal5  -0.107773  0.897831  0.020726   -5.200 1.99e-07 ***
## feedr$Animal6  -0.381651  0.682734  0.006466  -59.027  < 2e-16 ***
## feedr$Animal7  -0.393270  0.674847  0.008354  -47.074  < 2e-16 ***
## feedr$Animal8  -0.085336  0.918204  0.022243   -3.836 0.000125 ***
## feedr$Animal9   0.307940  1.360619  0.006601   46.649  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##                exp(coef) exp(-coef) lower .95 upper .95
## feedr$Animal10    0.5443     1.8371    0.5379    0.5509
## feedr$Animal11    2.2536     0.4437    2.2272    2.2803
## feedr$Animal12    0.4314     2.3180    0.4062    0.4582
## feedr$Animal13    0.5765     1.7346    0.5473    0.6073
## feedr$Animal14    0.6078     1.6452    0.5876    0.6288
## feedr$Animal15    1.1760     0.8503    1.1391    1.2141
## feedr$Animal16    0.4828     2.0712    0.4670    0.4992
## feedr$Animal17    0.6217     1.6084    0.5938    0.6510
## feedr$Animal18    3.4538     0.2895    3.0028    3.9725
## feedr$Animal19    0.6877     1.4541    0.6602    0.7164
## feedr$Animal2     1.9136     0.5226    1.8823    1.9454
## feedr$Animal20    0.7577     1.3198    0.7257    0.7910
## feedr$Animal21    0.4534     2.2056    0.4454    0.4615
## feedr$Animal22    1.1862     0.8430    1.1699    1.2028
## feedr$Animal23    2.1668     0.4615    2.1104    2.2248
## feedr$Animal24    1.3585     0.7361    1.3023    1.4172
## feedr$Animal25    1.3677     0.7312    1.3338    1.4024
## feedr$Animal26    0.4985     2.0060    0.4859    0.5114
## feedr$Animal27    1.1677     0.8564    1.1509    1.1847
## feedr$Animal28    1.2424     0.8049    1.2137    1.2717
## feedr$Animal29    0.5677     1.7615    0.5560    0.5797
## feedr$Animal3     0.4467     2.2388    0.4399    0.4536
## feedr$Animal30    1.4007     0.7139    1.3825    1.4191
## feedr$Animal31    0.3636     2.7506    0.3503    0.3774
## feedr$Animal4     1.1924     0.8386    1.1706    1.2146
## feedr$Animal5     0.8978     1.1138    0.8621    0.9351
## feedr$Animal6     0.6827     1.4647    0.6741    0.6914
## feedr$Animal7     0.6748     1.4818    0.6639    0.6860
## feedr$Animal8     0.9182     1.0891    0.8790    0.9591
## feedr$Animal9     1.3606     0.7350    1.3431    1.3783
## 
## Concordance= 0.681  (se = 0.001 )
## Rsquare= 0.189   (max possible= 1 )
## Likelihood ratio test= 110589  on 30 df,   p=0
## Wald test            = 110911  on 30 df,   p=0
## Score (logrank) test = 119797  on 30 df,   p=0
```

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->


```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   2260109  120.8    5295264  282.8   8273852  441.9
## Vcells 323021570 2464.5  543981803 4150.3 543506273 4146.7
```
