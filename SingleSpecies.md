# Antarctic Whale Project: Single Species
Ben Weinstein  
`r Sys.time()`  







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

![](SingleSpecies_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-15-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-15-2.png)<!-- -->





```
##     user   system  elapsed 
##  197.631    1.976 6391.325
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-18-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

## Parameter Summary

```
## Source: local data frame [12 x 5]
## Groups: parameter [?]
## 
##    parameter         par          mean        lower       upper
##       (fctr)      (fctr)         (dbl)        (dbl)       (dbl)
## 1   alpha_mu alpha_mu[1]  0.4994257493 -0.119244348  1.11470312
## 2   alpha_mu alpha_mu[2] -1.9759865331 -2.561190955 -1.44140957
## 3   beta2_mu beta2_mu[1]  0.0177734219  0.006279414  0.03012112
## 4   beta2_mu beta2_mu[2]  0.0000000000  0.000000000  0.00000000
## 5   beta3_mu beta3_mu[1]  0.0060298574 -0.001263055  0.01349180
## 6   beta3_mu beta3_mu[2]  0.0000000000  0.000000000  0.00000000
## 7    beta_mu  beta_mu[1] -0.9159653731 -1.756814177 -0.10724389
## 8    beta_mu  beta_mu[2]  0.0000000000  0.000000000  0.00000000
## 9      gamma    gamma[1]  0.8794301200  0.835756888  0.91506098
## 10     gamma    gamma[2]  0.0734836347  0.006255442  0.13873853
## 11     theta    theta[1]  0.0004216938 -0.024421321  0.02432177
## 12     theta    theta[2]  5.2415578174  2.862968098  5.98749529
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

##Behavior and environment

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-23-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-24-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->


### Per Animal

```
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-2.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-3.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-4.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-5.png)<!-- -->

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-6.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-7.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-8.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-9.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-10.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-11.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-28-12.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration


![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->


##All variables


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-39-2.png)<!-- -->


#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->



```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1759740   94.0    5750464  307.2   8985100  479.9
## Vcells 237448968 1811.6  465418839 3550.9 464037574 3540.4
```
