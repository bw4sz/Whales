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

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-15-2.png)<!-- -->




```
##    user  system elapsed 
##    7.59    1.98  721.53
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

## Parameter Summary

```
## Source: local data frame [10 x 5]
## Groups: parameter [?]
## 
##    parameter         par        mean        lower     upper
##       (fctr)      (fctr)       (dbl)        (dbl)     (dbl)
## 1   alpha_mu alpha_mu[1] -0.44303551 -1.423679364 0.5805069
## 2   alpha_mu alpha_mu[2] -1.14376315 -2.672146881 0.6464894
## 3    beta_mu  beta_mu[1]  1.41583867  0.007649658 3.1736136
## 4    beta_mu  beta_mu[2] -0.84532843 -3.007136813 1.2617881
## 5   beta2_mu beta2_mu[1]  0.01204272 -0.010428040 0.0413007
## 6   beta2_mu beta2_mu[2]  0.24417297  0.009622728 1.5948765
## 7      gamma    gamma[1]  0.76683668  0.673227895 0.8725330
## 8      gamma    gamma[2]  0.08570841  0.006092957 0.2397559
## 9      theta    theta[1]  0.03464441 -0.044631522 0.1112320
## 10     theta    theta[2]  2.98914301  2.024057146 4.1284917
```

![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

##Behavior and environment

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-22-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-23-2.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-25-3.png)<!-- -->

##Log Odds of Feeding

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration


![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->

#Environmental Prediction - Probability of feeding



## Bathymetry

### When traveling
![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

### When Feeding

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-35-2.png)<!-- -->

## Distance to coast

### When traveling
![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

### When Feeding

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-37-2.png)<!-- -->

##All variables

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-38-2.png)<!-- -->

#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->



```
##            used  (Mb) gc trigger  (Mb)  max used  (Mb)
## Ncells  1593267  85.1    6177917 330.0   7722397 412.5
## Vcells 54181255 413.4  116950954 892.3 115361949 880.2
```
