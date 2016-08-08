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
##    1.14    0.82 4967.68
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
## 1   alpha_mu alpha_mu[1]  0.15850923 -2.426521782 2.8687277
## 2   alpha_mu alpha_mu[2] -0.10317151 -2.659930484 2.4678933
## 3    beta_mu  beta_mu[1] -0.16856077 -2.916843809 2.5324019
## 4    beta_mu  beta_mu[2]  0.05641406 -2.661354296 2.5631347
## 5   beta2_mu beta2_mu[1]  1.26286808  0.119688264 3.1223079
## 6   beta2_mu beta2_mu[2] -0.06213651 -2.810762191 2.6921116
## 7      gamma    gamma[1]  0.67462206  0.578269645 0.7892604
## 8      gamma    gamma[2]  0.07852240  0.005470758 0.2390765
## 9      theta    theta[1]  0.03130182 -0.081801795 0.1503395
## 10     theta    theta[2]  3.09333466  1.880035402 4.1999799
```

![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

##Behavior and environment

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-22-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-23-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state

![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

##Spatial Prediction

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-2.png)<!-- -->

##Log Odds of Feeding

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration


![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

#Environmental Prediction - Probability of feeding



## Bathymetry

### When traveling
![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

### When Feeding

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-36-2.png)<!-- -->

## Distance to coast

### When traveling
![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

### When Feeding

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-38-2.png)<!-- -->

##All variables

### When traveling


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-39-2.png)<!-- -->

###When Feeding


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-40-2.png)<!-- -->

#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->



```
##            used  (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells  1598859  85.4    4948733 264.3  6861544 366.5
## Vcells 33037914 252.1   80471834 614.0 69145031 527.6
```
