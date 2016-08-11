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
##     user   system  elapsed 
##   65.319    1.017 3016.548
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
##    parameter         par        mean        lower       upper
##       (fctr)      (fctr)       (dbl)        (dbl)       (dbl)
## 1   alpha_mu alpha_mu[1]  0.18686476 -0.477695553  0.84426024
## 2   alpha_mu alpha_mu[2] -1.32560305 -2.196233546 -0.44821156
## 3   beta2_mu beta2_mu[1]  0.03085365  0.006390853  0.07377277
## 4   beta2_mu beta2_mu[2]  0.00000000  0.000000000  0.00000000
## 5    beta_mu  beta_mu[1] -0.45799199 -1.579297335  0.60744608
## 6    beta_mu  beta_mu[2]  0.00000000  0.000000000  0.00000000
## 7      gamma    gamma[1]  0.82633463  0.764444270  0.88488753
## 8      gamma    gamma[2]  0.03672513  0.002259508  0.09928076
## 9      theta    theta[1] -0.07137679 -0.121370627 -0.02756943
## 10     theta    theta[2]  3.54659271  2.334293211  4.53076393
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

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-26-8.png)<!-- -->

##Log Odds of Foraging

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

#Environmental Prediction - Probability of Foraging



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->


##All variables


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-37-2.png)<!-- -->


#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->



```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1688630   90.2    7974897  426.0   9968622  532.4
## Vcells 140300114 1070.5  267200524 2038.6 267080658 2037.7
```
