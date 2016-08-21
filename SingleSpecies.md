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
##      user    system   elapsed 
##   198.285     1.609 10921.344
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

## Parameter Summary

```
## Source: local data frame [38 x 5]
## Groups: parameter [?]
## 
##    parameter         par        mean      lower      upper
##       (fctr)      (fctr)       (dbl)      (dbl)      (dbl)
## 1   alpha_mu alpha_mu[1]  0.01804063 -0.6497932  0.6681658
## 2   alpha_mu alpha_mu[2] -1.64435281 -2.2552399 -1.0862936
## 3       beta   beta[1,1] -0.17076594 -1.8039178  1.9217257
## 4       beta   beta[2,1] -1.52161389 -3.9871033 -0.1261102
## 5       beta   beta[3,1] -1.52250167 -3.7409450  0.2167110
## 6       beta   beta[4,1] -1.00901508 -2.5238436  0.5069955
## 7       beta   beta[5,1] -0.56553751 -2.5615299  1.6717656
## 8       beta   beta[9,1] -0.34906997 -1.8973933  2.0421645
## 9       beta  beta[10,1] -1.23708135 -3.5817598  1.1308879
## 10      beta   beta[1,2]  0.00000000  0.0000000  0.0000000
## ..       ...         ...         ...        ...        ...
```

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

#Behavior and environment

##Hierarchical 

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-24-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

## By Month

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-26-2.png)<!-- -->

### Mean Estimates Only
![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

### As facets
![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-28-2.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->


#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->


### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-8.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-9.png)<!-- -->

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-10.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-11.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-12.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-13.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-14.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-15.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-33-16.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->


##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration

Needs to be indexed by month.



![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->

##All variables


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-43-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-43-2.png)<!-- -->


#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->



```
##             used   (Mb) gc trigger   (Mb)   max used    (Mb)
## Ncells   1773940   94.8   20145734 1075.9   39347138  2101.4
## Vcells 311452879 2376.2 1083541430 8266.8 1383093853 10552.2
```
