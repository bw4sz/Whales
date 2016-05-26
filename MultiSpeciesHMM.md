# Antarctic Whale Project: MultiSpecies Simulation
Ben Weinstein  
`r Sys.time()`  





#Abstract
I simulated correlated random walks with similar properties to previous marine pinnepid studies. The virtue of the simulation is that we can build complexity slowly. At each step we can verify that the model captures the true, known, relationship. Once we have developed a model that satisfies our aims, we can then apply it to the observed data.

## Current State

A dynamic correlated random walk with two states (traveling, feeding) that are a function of local environmental conditions. There are multiple individuals whose covariates are drawn from a group level mean.

## To add
* Observation Error
* Posterior Model Checks
* Seasonal Variation
** Variation in process error (Breed 2012)
** Variation in diel?

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

###Behavioral States

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

###Environment

Behavioral states are a function of local environmental conditions. The first environmental condition is ocean depth. I then build a function for preferential foraging in shallow waters.

It generally follows the form, conditional on behavior at t -1:

$$Behavior_t \sim Multinomial([\phi_{traveling},\phi_{foraging}])$$
$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}} + \beta_1 * Ocean_{y[t,]}$$
$$logit(\phi_{foraging}) = \alpha_{Behavior_{t-1}} + \beta_2 * Ocean_{y[t,]}$$



#Simulation

Values come from Jonsen (2005) and Jonsen (2016) fit for foraging seals.

##Behavioral States
### Traveling
$$\gamma_1 = 0.9 = \text{Strong Movement Persistence}$$
$$\theta_1 = 0 = \text{No preference in turns}$$

### Foraging
$$\gamma_2 = 0.1 = \text{Weak Movement Persistence}$$
$$\theta_2 = pi = \text{Many reversals in turns}$$

Essentially, whales travel long straight distances to find food sources, but then stay in those patches for a long time. 

### Environment
Whales tend to travel in deep habitats, slighlty weaker effect of ocean depth. The importance of this effect varies by individual.

$$\alpha_{i,1,1} \sim Normal(-2,0.2)$$
$$\beta_{i,1,1} \sim Normal(1,0.1)$$

$$\alpha_{i,2,1} \sim Normal(-2,0.2)$$
$$\beta_{i,2,1} \sim Normal(1,0.1)$$

The intercept alpha determines the crossing point, i.e the depth at which a foraging whale is likely to begin foraging. Here is set to be around 2000m water following 
[dive profile based on Stimpert (2012).](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0051214)

This is easiest to understand graphically.



![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

```
## null device 
##           1
```

### Multiple trajectories.
![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-6-2.png)<!-- -->

#Model Fitting

The goal of the model is to capture the true parameter we simulated above. As we increase complexity, we will be able to monitor the validity of our approach.


```
##   [1] sink("Bayesian/Multi_RW.jags")                                                                                  
##   [2] cat("                                                                                                           
##   [3]     model{                                                                                                      
##   [4]                                                                                                                 
##   [5]     #Constants                                                                                                  
##   [6]     pi <- 3.141592653589                                                                                        
##   [7]                                                                                                                 
##   [8]     for(i in 1:ind){                                                                                            
##   [9]                                                                                                                 
##  [10]     ###First Step###                                                                                            
##  [11]                                                                                                                 
##  [12]     ## Priors for first location                                                                                
##  [13]     #for lat long                                                                                               
##  [14]     for(k in 1:2){                                                                                              
##  [15]       y[i,1,k] ~ dnorm(argos[i,1,k],itau2.prior)                                                                
##  [16]     }                                                                                                           
##  [17]                                                                                                                 
##  [18]     #First movement - random walk.                                                                              
##  [19]     y[i,2,1:2] ~ dmnorm(y[i,1,1:2],iSigma)                                                                      
##  [20]                                                                                                                 
##  [21]     ###First Behavioral State###                                                                                
##  [22]     state[i,1] ~ dcat(lambda[]) ## assign state for first obs                                                   
##  [23]                                                                                                                 
##  [24]     #Process Model for movement                                                                                 
##  [25]     for(t in 2:(steps[i]-1)){                                                                                   
##  [26]                                                                                                                 
##  [27]     #Behavioral State at time T                                                                                 
##  [28]     logit(phi[i,t,1]) <- lalpha[i,state[i,t-1]] + lbeta[i,state[i,t-1]] * ocean[i,t]                            
##  [29]     phi[i,t,2] <- 1-phi[i,t,1]                                                                                  
##  [30]     state[i,t] ~ dcat(phi[i,t,])                                                                                
##  [31]                                                                                                                 
##  [32]     #Turning covariate                                                                                          
##  [33]     #Transition Matrix for turning angles                                                                       
##  [34]     T[i,t,1,1] <- cos(theta[state[i,t]])                                                                        
##  [35]     T[i,t,1,2] <- (-sin(theta[state[i,t]]))                                                                     
##  [36]     T[i,t,2,1] <- sin(theta[state[i,t]])                                                                        
##  [37]     T[i,t,2,2] <- cos(theta[state[i,t]])                                                                        
##  [38]                                                                                                                 
##  [39]     #Correlation in movement change                                                                             
##  [40]     d[i,t,1:2] <- y[i,t,] + gamma[state[i,t]] * T[i,t,,] %*% (y[i,t,1:2] - y[i,t-1,1:2])                        
##  [41]                                                                                                                 
##  [42]     #Gaussian Displacement                                                                                      
##  [43]     y[i,t+1,1:2] ~ dmnorm(d[i,t,1:2],iSigma)                                                                    
##  [44]     }                                                                                                           
##  [45]                                                                                                                 
##  [46]     #Final behavior state                                                                                       
##  [47]     logit(phi[i,steps[i],1]) <- lalpha[i,state[i,steps[i]-1]] + lbeta[i,state[i,steps[i]-1]] * ocean[i,steps[i]]
##  [48]     phi[i,steps[i],2] <- 1-phi[i,steps[i],1]                                                                    
##  [49]     state[i,steps[i]] ~ dcat(phi[i,steps[i],])                                                                  
##  [50]                                                                                                                 
##  [51]     ##\tMeasurement equation - irregular observations                                                            
##  [52]     for(t in 2:steps[i]){\t\t\t\t\t# loops over regular time intervals (t)                                           
##  [53]         zhat[i,t,1:2] <- (1-j[i,t]) * y[i,t-1,1:2] + j[i,t] * y[i,t,1:2]                                        
##  [54]       #for lat and long                                                                                         
##  [55]       for (k in 1:2){                                                                                           
##  [56]         #argos error.                                                                                           
##  [57]         argos[i,t,k] ~ dnorm(zhat[i,t,k],itau2.prior)                                                           
##  [58]         }                                                                                                       
##  [59]       }\t                                                                                                        
##  [60]     }                                                                                                           
##  [61]                                                                                                                 
##  [62]     ###Priors###                                                                                                
##  [63]                                                                                                                 
##  [64]     #Process Variance                                                                                           
##  [65]     iSigma ~ dwish(R,2)                                                                                         
##  [66]     Sigma <- inverse(iSigma)                                                                                    
##  [67]                                                                                                                 
##  [68]     ##Mean Angle                                                                                                
##  [69]     tmp[1] ~ dbeta(10, 10)                                                                                      
##  [70]     tmp[2] ~ dbeta(10, 10)                                                                                      
##  [71]                                                                                                                 
##  [72]     # prior for theta in 'traveling state'                                                                      
##  [73]     theta[1] <- (2 * tmp[1] - 1) * pi                                                                           
##  [74]                                                                                                                 
##  [75]     # prior for theta in 'foraging state'                                                                       
##  [76]     theta[2] <- (tmp[2] * pi * 2)                                                                               
##  [77]                                                                                                                 
##  [78]     ##Move persistance                                                                                          
##  [79]     # prior for gamma (autocorrelation parameter) in state 1                                                    
##  [80]     gamma[1] ~ dbeta(5,2)                                                                                       
##  [81]                                                                                                                 
##  [82]     # prior for gamma in state 2                                                                                
##  [83]     gamma[2] ~ dbeta(2,5)                                                                                       
##  [84]                                                                                                                 
##  [85]     ##Behavioral States                                                                                         
##  [86]     # Following lunn 2012 p85                                                                                   
##  [87]                                                                                                                 
##  [88]     #Hierarchical structure                                                                                     
##  [89]     #Intercepts                                                                                                 
##  [90]     lalpha_mu[1] ~ dnorm(0,0.386)                                                                               
##  [91]     lalpha_mu[2] ~ dnorm(0,0.386)                                                                               
##  [92]                                                                                                                 
##  [93]     #Variance                                                                                                   
##  [94]     lalpha_tau[1] ~ dt(0,1,1)I(0,)                                                                              
##  [95]     lalpha_tau[2] ~ dt(0,1,1)I(0,)                                                                              
##  [96]                                                                                                                 
##  [97]     #Slopes                                                                                                     
##  [98]     lbeta_mu[1] ~ dnorm(0,0.386)                                                                                
##  [99]     lbeta_mu[2] ~ dnorm(0,0.386)                                                                                
## [100]                                                                                                                 
## [101]     #Variance                                                                                                   
## [102]     lbeta_tau[1] ~ dt(0,1,1)I(0,)                                                                               
## [103]     lbeta_tau[2] ~ dt(0,1,1)I(0,)                                                                               
## [104]                                                                                                                 
## [105]     #For each individual                                                                                        
## [106]     for(i in 1:ind){                                                                                            
## [107]       # prob of being in state 1 at t, given in state 1 at t-1                                                  
## [108]       #Individual Intercept                                                                                     
## [109]       lalpha[i,1] ~ dnorm(lalpha_mu[1],lalpha_tau[1])                                                           
## [110]       logit(alpha[i,1]) <- lalpha[i,1]                                                                          
## [111]                                                                                                                 
## [112]       #effect of ocean on traveling -> traveling                                                                
## [113]       lbeta[i,1] ~ dnorm(lbeta_mu[1],lbeta_tau[1])                                                              
## [114]       logit(beta[i,1]) <- lbeta[i,1]                                                                            
## [115]                                                                                                                 
## [116]       #Prob of transition to state 1 given state 2 at t-1                                                       
## [117]       lalpha[i,2] ~ dnorm(lalpha_mu[2],lalpha_tau[2])                                                           
## [118]       logit(alpha[i,2]) <- lalpha[i,2]                                                                          
## [119]                                                                                                                 
## [120]       #effect of ocean on feeding -> traveling                                                                  
## [121]       lbeta[i,2] ~ dnorm(lbeta_mu[2],lbeta_tau[2])                                                              
## [122]       logit(beta[i,2]) <- lbeta[i,2]                                                                            
## [123]                                                                                                                 
## [124]     }                                                                                                           
## [125]                                                                                                                 
## [126]     #Probability of behavior switching                                                                          
## [127]     lambda[1] ~ dbeta(1,1)                                                                                      
## [128]     lambda[2] <- 1 - lambda[1]                                                                                  
## [129]                                                                                                                 
## [130]     ##Argos priors##                                                                                            
## [131]     itau2.prior ~ dunif(0,10)                                                                                   
## [132]                                                                                                                 
## [133]     }"                                                                                                          
## [134]     ,fill=TRUE)                                                                                                 
## [135] sink()
```

##Chains
![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

###Compare to priors

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

##Prediction - environmental function

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-11-1.png)<!-- -->

#Behavioral Prediction

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-12-1.png)<!-- -->![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-12-2.png)<!-- -->

##Autocorrelation in behavior

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

##Phase prediction
![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-14-2.png)<!-- -->

##Behavioral description

###Average time in phase

To calculate this, while propogating uncertainty, we can either save the state variable in jags, or draw multinomial draws from phi. Here we recreate it from phi.

* For each draw, create a behavioral sequence, calulate the average runs for each behavior

## Failure time analysis

* Fit a curve to the runs as a function of time to get 'patch time'
* the curve could be a function of temporal covariates.
* per draw? How to get confidence intervals?
* cox regression - see jenica allen and jeff diez.

## Predicted Run Length
![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-16-1.png)<!-- -->

###Proportional Hazards

Survival analysis typically examines the relationship between time to death as a function of covariates. From this we can get the instantaneous rate of death at time t f(t), which is the cumulative distribution of the liklihood of death.

Let T represent survival time.

$$ P(t) = Pr(T<t)$$ 
with a pdf
$$p(t) = \frac{dP(t)}{dt}$$

The instantaneous risk of death at time t, confitional on survival to that time:

$$log (h_i(t)) = \alpha + \beta_i *x$$

The cox model has no intercept, making it semi-parametric
$$ log(h_i(t)) = h_0(t) + \beta_1 * x$$


```
## Call:
## coxph(formula = Surv(time = feedr$runs, event = feedr$status) ~ 
##     feedr$Animal)
## 
##   n= 4782, number of events= 4782 
## 
##                  coef exp(coef) se(coef)      z Pr(>|z|)    
## feedr$Animal2 0.36260   1.43706  0.04633  7.826    5e-15 ***
## feedr$Animal3 0.14017   1.15047  0.04391  3.192  0.00141 ** 
## feedr$Animal4 0.59759   1.81774  0.04640 12.879  < 2e-16 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
##               exp(coef) exp(-coef) lower .95 upper .95
## feedr$Animal2     1.437     0.6959     1.312     1.574
## feedr$Animal3     1.150     0.8692     1.056     1.254
## feedr$Animal4     1.818     0.5501     1.660     1.991
## 
## Concordance= 0.576  (se = 0.012 )
## Rsquare= 0.042   (max possible= 1 )
## Likelihood ratio test= 205.2  on 3 df,   p=0
## Wald test            = 207.2  on 3 df,   p=0
## Score (logrank) test = 210.6  on 3 df,   p=0
```

![](MultiSpeciesHMM_files/figure-html/unnamed-chunk-17-1.png)<!-- -->



