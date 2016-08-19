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

$$logit(\phi_{traveling}) = \alpha_{Behavior_{t-1}} + \beta_1 * Ocean_{y[t,]} + \beta_2 * Coast_{y[t,]}$$

$$logit(\phi_{foraging}) = \alpha_{Behavior_{t-1}} $$

Following Bestley in preferring to describe the switch into feeding, but no estimating the resumption of traveling.



##Continious tracks

The transmitter will often go dark for 10 to 12 hours, due to weather, right in the middle of an otherwise good track. The model requires regular intervals to estimate the turning angles and temporal autocorrelation. As a track hits one of these walls, call it the end of a track, and begin a new track once the weather improves. We can remove any micro-tracks that are less than three days.
Specify a duration, calculate the number of tracks and the number of removed points. Iteratively.





How did the filter change the extent of tracks?

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-16-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-16-2.png)<!-- -->




```
##    user  system elapsed 
##    0.74    0.08   87.64
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

## Parameter Summary

```
## Source: local data frame [26 x 5]
## Groups: parameter [?]
## 
##    parameter         par          mean     lower     upper
##       (fctr)      (fctr)         (dbl)     (dbl)     (dbl)
## 1   alpha_mu alpha_mu[1] -0.0003793991 -2.261512  2.472842
## 2   alpha_mu alpha_mu[2] -2.2292549743 -3.522244 -1.069620
## 3       beta   beta[1,1]  0.5646368637 -2.726495  3.452911
## 4       beta   beta[2,1]  0.4208344778 -2.158011  3.679897
## 5       beta   beta[3,1]  0.1466245109 -1.717353  2.292239
## 6       beta   beta[4,1]  0.5352721566 -2.252437  4.088838
## 7       beta   beta[1,2]  0.0000000000  0.000000  0.000000
## 8       beta   beta[2,2]  0.0000000000  0.000000  0.000000
## 9       beta   beta[3,2]  0.0000000000  0.000000  0.000000
## 10      beta   beta[4,2]  0.0000000000  0.000000  0.000000
## ..       ...         ...           ...       ...       ...
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

##Behavior and environment

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-24-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->


### Per Animal

```
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration


![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->


##All variables


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

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->



```
##            used  (Mb) gc trigger  (Mb) max used  (Mb)
## Ncells  1609682  86.0    5115198 273.2  7992498 426.9
## Vcells 26262520 200.4   66993564 511.2 61597591 470.0
```
