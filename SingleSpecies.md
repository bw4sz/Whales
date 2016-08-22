# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  







#Descriptive Statistics


![](SingleSpecies_files/figure-html/unnamed-chunk-5-1.png)<!-- -->

##By Month

![](SingleSpecies_files/figure-html/unnamed-chunk-6-1.png)<!-- -->

##Distance

![](SingleSpecies_files/figure-html/unnamed-chunk-7-1.png)<!-- -->

##Time 
![](SingleSpecies_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

##Velocity
![](SingleSpecies_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

##Angles

![](SingleSpecies_files/figure-html/unnamed-chunk-10-1.png)<!-- -->

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

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-16-2.png)<!-- -->




```
##    user  system elapsed 
##    3.40    1.07  569.49
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

## Parameter Summary

```
##    parameter         par        mean      lower       upper
## 1   alpha_mu alpha_mu[1]  0.04170323 -2.0849442  1.93988456
## 2   alpha_mu alpha_mu[2] -2.09712431 -2.5594583 -1.65644853
## 3       beta   beta[1,1]  0.43669426 -4.5154874  5.45778878
## 4       beta   beta[2,1] -0.65838844 -4.3739706  4.27935201
## 5       beta   beta[3,1] -0.75737450 -5.7257015  3.53424348
## 6       beta   beta[4,1] -0.98824406 -6.2889485  5.05834278
## 7       beta   beta[5,1]  0.58427779 -3.4140069  7.73322418
## 8       beta   beta[1,2]  0.00000000  0.0000000  0.00000000
## 9       beta   beta[2,2]  0.00000000  0.0000000  0.00000000
## 10      beta   beta[3,2]  0.00000000  0.0000000  0.00000000
## 11      beta   beta[4,2]  0.00000000  0.0000000  0.00000000
## 12      beta   beta[5,2]  0.00000000  0.0000000  0.00000000
## 13   beta_mu  beta_mu[1] -0.50306330 -3.8227467  1.61570122
## 14   beta_mu  beta_mu[2]  0.00000000  0.0000000  0.00000000
## 15     beta2  beta2[1,1] -0.20569353 -2.8149914  1.15827751
## 16     beta2  beta2[2,1] -1.34711477 -3.0127374  0.08369686
## 17     beta2  beta2[3,1] -1.46778481 -3.1803814 -0.10024932
## 18     beta2  beta2[4,1] -1.47172362 -3.3687022 -0.06242552
## 19     beta2  beta2[5,1] -1.24035145 -3.7578076 -0.04579139
## 20     beta2  beta2[1,2]  0.00000000  0.0000000  0.00000000
## 21     beta2  beta2[2,2]  0.00000000  0.0000000  0.00000000
## 22     beta2  beta2[3,2]  0.00000000  0.0000000  0.00000000
## 23     beta2  beta2[4,2]  0.00000000  0.0000000  0.00000000
## 24     beta2  beta2[5,2]  0.00000000  0.0000000  0.00000000
## 25  beta2_mu beta2_mu[1] -0.86409758 -2.3779644  0.27909916
## 26  beta2_mu beta2_mu[2]  0.00000000  0.0000000  0.00000000
## 27     gamma    gamma[1]  1.41668749  1.3129662  1.49326071
## 28     gamma    gamma[2]  0.48078888  0.4243989  0.53356526
## 29     theta    theta[1] -0.21274252 -0.3107730 -0.09008332
## 30     theta    theta[2]  6.09495083  6.0125447  6.15892884
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

#Behavior and environment

##Hierarchical 

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-24-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

###Interaction

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

## By Month

### Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

Just the probability of feeding when traveling.

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

### Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-29-2.png)<!-- -->

Zooming in on the top right plot.
![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-30-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->


### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-34-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-34-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-34-4.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration



![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging across time



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-43-1.png)<!-- -->

##All variables

![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

# Overlap with Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-46-1.png)<!-- -->

## By Month





## Change in foraging areas

January verus May

Red = Better Foraging in Jan
Blue = Better Foraging in May

![](SingleSpecies_files/figure-html/unnamed-chunk-49-1.png)<!-- -->

## Monthly Overlap with Krill Fishery

![](SingleSpecies_files/figure-html/unnamed-chunk-50-1.png)<!-- -->



```
##            used  (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells  1638706  87.6    5684620 303.6  5684620 303.6
## Vcells 34416789 262.6   67014777 511.3 67014777 511.3
```
