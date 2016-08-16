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






##Chains





![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-21-1.png)<!-- -->

## Parameter Summary

```
## Source: local data frame [10 x 5]
## Groups: parameter [?]
## 
##    parameter         par         mean        lower       upper
##       (fctr)      (fctr)        (dbl)        (dbl)       (dbl)
## 1   alpha_mu alpha_mu[1] -0.103215640 -0.490325435  0.29199978
## 2   alpha_mu alpha_mu[2] -1.904981407 -2.248892795 -1.60045543
## 3   beta2_mu beta2_mu[1]  0.013312685  0.006518188  0.02095765
## 4   beta2_mu beta2_mu[2]  0.000000000  0.000000000  0.00000000
## 5    beta_mu  beta_mu[1]  0.057361361 -0.280008251  0.42291913
## 6    beta_mu  beta_mu[2]  0.000000000  0.000000000  0.00000000
## 7      gamma    gamma[1]  0.918619110  0.883886602  0.95598347
## 8      gamma    gamma[2]  0.156189282  0.114589957  0.19577542
## 9      theta    theta[1] -0.005646154 -0.027453333  0.01590594
## 10     theta    theta[2]  0.227316050  0.135579065  0.34660730
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

### Per Animal

```
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-2.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-3.png)<!-- -->

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-4.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-5.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-6.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-7.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-8.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-9.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-10.png)<!-- -->

```
## 
## $`17`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-11.png)<!-- -->

```
## 
## $`18`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-12.png)<!-- -->

```
## 
## $`19`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-13.png)<!-- -->

```
## 
## $`20`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-14.png)<!-- -->

```
## 
## $`21`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-15.png)<!-- -->

```
## 
## $`22`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-16.png)<!-- -->

```
## 
## $`23`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-17.png)<!-- -->

```
## 
## $`24`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-18.png)<!-- -->

```
## 
## $`25`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-19.png)<!-- -->

```
## 
## $`26`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-20.png)<!-- -->

```
## 
## $`27`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-21.png)<!-- -->

```
## 
## $`28`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-22.png)<!-- -->

```
## 
## $`29`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-23.png)<!-- -->

```
## 
## $`30`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-24.png)<!-- -->

```
## 
## $`31`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-25.png)<!-- -->

```
## 
## $`32`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-26.png)<!-- -->

```
## 
## $`33`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-27.png)<!-- -->

```
## 
## $`34`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-28.png)<!-- -->

```
## 
## $`35`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-29.png)<!-- -->

```
## 
## $`36`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-30.png)<!-- -->

```
## 
## $`37`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-31.png)<!-- -->

```
## 
## $`38`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-32.png)<!-- -->

```
## 
## $`39`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-27-33.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

###Interaction

No estimate of uncertainty.
![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration


![](SingleSpecies_files/figure-html/unnamed-chunk-33-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->


##All variables


```
## [[1]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

```
## 
## [[2]]
```

![](SingleSpecies_files/figure-html/unnamed-chunk-38-2.png)<!-- -->


#Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->



```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1672039   89.3    5526984  295.2   9275080  495.4
## Vcells 143288754 1093.3  352644449 2690.5 352365889 2688.4
```
