# Antarctic Whale Project: Simulation
Ben Weinstein  
May 5th, 2016  





#Abstract
I simulated correlated random walks with similar properties to previous marine pinnepid studies. The virtue of the simulation is that we can build complexity slowly. At each step we can verify that the model captures the true, known, relationship. Once we have developed a model that satisfies our aims, we can then apply it to the observed data.

## To add
* Add coastline?
* Hierarchical variance among individuals
* Observation Error
* Posterior Model Checks

#Correlated random walk

*Process Model*

$$ d_{t} \sim T*d_{t-1} + Normal(0,\Sigma)$$
$$ x_t = x_{t-1} + d_{t} $$

## Parameters

$$\theta = \text{Mean turning angle}$$
$$\gamma = \text{Move persistence} $$

For both behaviors process variance is:
$$ \sigma_{latitude} = 0.1$$
$$ \sigma_{longitude} = 0.1$$


###Behavioral States

$$ Behavior_1 = \text{traveling}$$
$$ Behavior_2 = \text{foraging}$$

$$ \alpha_{1,1} = \text{Probability of remaining traveling when traveling}$$
$$\alpha_{2,1} = \text{Probability of switching from feeding to traveling}$$

$$\begin{matrix}
  \alpha_{1,1} & 1-\alpha_{1,1} \\
  \alpha_{2,1} & 1-\alpha_{2,1} \\
\end{matrix}
$$

###Environment

Behavioral states are a function of local environmental conditions. The first environmental condition is ocean depth. I then build a function for preferential foraging in shallow waters.

It generally follows the form, conditional on behavior at t -1:

$$Behavior_t \sim Multinomial([\phi_{traveling},\phi_{foraging}])$$
$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}} + \beta_1 * Ocean_{y[t-1,]}$$
$$logit(\phi_{foraging}) = \alpha_{Behavior_{t-1}} + \beta_2 * Ocean_{y[t-1,]}$$




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
Whales tend to travel in deep habitats
$$\alpha_1 = -1$$
$$\beta_1=1$$

Whales tend to forage in shallow habitats
$$\alpha_1 = -1$$
$$\beta_2=1$$

The intercept alpha determines the crossing point, i.e the depth at which a foraging whale is likely to begin foraging. Here is set to be around 200m water following 
[dive profile based on Stimpert (2012).](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0051214)

This is easiest to understand graphically.



![](HMM_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

```
## null device 
##           1
```

### Multiple trajectories.
![](HMM_files/figure-html/unnamed-chunk-6-1.png)<!-- -->![](HMM_files/figure-html/unnamed-chunk-6-2.png)<!-- -->

#Model Fitting

The goal of the model is to capture the true parameter we simulated above. As we increase complexity, we will be able to monitor the validity of our approach.


```
##  [1] sink("Bayesian/RW.jags")                                                      
##  [2] cat("                                                                         
##  [3]     model{                                                                    
##  [4]                                                                               
##  [5]     #Constants                                                                
##  [6]     pi <- 3.141592653589                                                      
##  [7]                                                                               
##  [8]     ###First Step###                                                          
##  [9]     #First movement - random walk.                                            
## [10]     y[2,1:2] ~ dmnorm(y[1,1:2],iSigma)                                        
## [11]                                                                               
## [12]     ###First Behavioral State###                                              
## [13]     state[1] ~ dcat(lambda[]) ## assign state for first obs                   
## [14]                                                                               
## [15]     #Process Model for movement                                               
## [16]     for(t in 2:(steps-1)){                                                    
## [17]                                                                               
## [18]       #Turning covariate                                                      
## [19]       #Transition Matrix for turning angles                                   
## [20]       T[t,1,1] <- cos(theta[state[t]])                                        
## [21]       T[t,1,2] <- (-sin(theta[state[t]]))                                     
## [22]       T[t,2,1] <- sin(theta[state[t]])                                        
## [23]       T[t,2,2] <- cos(theta[state[t]])                                        
## [24]                                                                               
## [25]       #Behavioral State at time T                                             
## [26]       logit(phi[t,1]) <- alpha[state[t-1]] + beta[state[t-1]] * ocean[t-1]    
## [27]       phi[t,2] <- 1-phi[t,1]                                                  
## [28]       state[t] ~ dcat(phi[t,])                                                
## [29]                                                                               
## [30]       #Correlation in movement change                                         
## [31]       d[t,1:2] <- y[t,] + gamma[state[t]] * T[t,,] %*% (y[t,1:2] - y[t-1,1:2])
## [32]                                                                               
## [33]       #Gaussian Displacement                                                  
## [34]       y[t+1,1:2] ~ dmnorm(d[t,1:2],iSigma)                                    
## [35]                                                                               
## [36]     }                                                                         
## [37]                                                                               
## [38]     #Priors                                                                   
## [39]     #Process Variance                                                         
## [40]     iSigma ~ dwish(R,2)                                                       
## [41]     Sigma <- inverse(iSigma)                                                  
## [42]                                                                               
## [43]     ##Mean Angle                                                              
## [44]     tmp[1] ~ dbeta(10, 10)                                                    
## [45]     tmp[2] ~ dbeta(10, 10)                                                    
## [46]                                                                               
## [47]     # prior for theta in 'traveling state'                                    
## [48]     theta[1] <- (2 * tmp[1] - 1) * pi                                         
## [49]                                                                               
## [50]     # prior for theta in 'foraging state'                                     
## [51]     theta[2] <- (tmp[2] * pi * 2)                                             
## [52]                                                                               
## [53]     ##Move persistance                                                        
## [54]     # prior for gamma (autocorrelation parameter) in state 1                  
## [55]     gamma[1] ~ dbeta(5,2)                                                     
## [56]                                                                               
## [57]     # prior for gamma in state 2                                              
## [58]     gamma[2] ~ dbeta(2,5)                                                     
## [59]                                                                               
## [60]     ##Behavioral States                                                       
## [61]     # Following lunn 2012 p85                                                 
## [62]                                                                               
## [63]     # prob of being in state 1 at t, given in state 1 at t-1                  
## [64]     lalpha[1] ~ dnorm(0,0.386)                                                
## [65]     logit(alpha[1]) <- lalpha[1]                                              
## [66]                                                                               
## [67]     lbeta[1] ~ dnorm(0,0.386)                                                 
## [68]     logit(beta[1]) <- lbeta[1]                                                
## [69]                                                                               
## [70]     # prob of being in state 1 at t, given in state 2 at t-1                  
## [71]     lalpha[2] ~ dnorm(0,0.386)                                                
## [72]     logit(alpha[2]) <- lalpha[2]                                              
## [73]                                                                               
## [74]     lbeta[2] ~ dnorm(0,0.386)                                                 
## [75]     logit(beta[2]) <- lbeta[2]                                                
## [76]                                                                               
## [77]     #Probability of behavior switching                                        
## [78]     lambda[1] ~ dbeta(1,1)                                                    
## [79]     lambda[2] <- 1 - lambda[1]                                                
## [80]                                                                               
## [81]     }"                                                                        
## [82]     ,fill=TRUE)                                                               
## [83] sink()
```

```
## Compiling model graph
##    Resolving undeclared variables
##    Allocating nodes
## Graph information:
##    Observed stochastic nodes: 249
##    Unobserved stochastic nodes: 259
##    Total graph size: 67270
## 
## Initializing model
```

```
##    user  system elapsed 
## 4354.43    3.23 4461.55
```

##Chains
![](HMM_files/figure-html/unnamed-chunk-8-1.png)<!-- -->![](HMM_files/figure-html/unnamed-chunk-8-2.png)<!-- -->

##Posteriors

![](HMM_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

Compare to priors

![](HMM_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

##Prediction - environmental function



![](HMM_files/figure-html/unnamed-chunk-12-1.png)<!-- -->

##Prediction - spatial location



Point Density




