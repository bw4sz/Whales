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
##   204.147     1.929 20357.483
```

##Chains


![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

## Parameter Summary

```
##    parameter         par        mean        lower        upper
## 1   alpha_mu alpha_mu[1] -0.14725725 -0.746611440  0.519538886
## 2   alpha_mu alpha_mu[2] -1.33391653 -1.711710777 -0.937617992
## 3       beta   beta[1,1] -0.29321451 -2.052809220  1.705876273
## 4       beta   beta[2,1] -1.10306694 -2.840356574  0.385954680
## 5       beta   beta[3,1] -1.48401440 -3.315457353 -0.055105711
## 6       beta   beta[4,1] -1.02911051 -2.481916185  0.468334203
## 7       beta   beta[5,1] -0.85856058 -2.507672949  1.063369828
## 8       beta   beta[1,2]  0.00000000  0.000000000  0.000000000
## 9       beta   beta[2,2]  0.00000000  0.000000000  0.000000000
## 10      beta   beta[3,2]  0.00000000  0.000000000  0.000000000
## 11      beta   beta[4,2]  0.00000000  0.000000000  0.000000000
## 12      beta   beta[5,2]  0.00000000  0.000000000  0.000000000
## 13     beta2  beta2[1,1]  0.03034329  0.007065914  0.056778669
## 14     beta2  beta2[2,1]  0.02233401  0.003238084  0.041784264
## 15     beta2  beta2[3,1]  0.01186955 -0.006723299  0.034159201
## 16     beta2  beta2[4,1]  0.01531102 -0.006181894  0.038765993
## 17     beta2  beta2[5,1]  0.19918268  0.061024231  0.426803818
## 18     beta2  beta2[1,2]  0.00000000  0.000000000  0.000000000
## 19     beta2  beta2[2,2]  0.00000000  0.000000000  0.000000000
## 20     beta2  beta2[3,2]  0.00000000  0.000000000  0.000000000
## 21     beta2  beta2[4,2]  0.00000000  0.000000000  0.000000000
## 22     beta2  beta2[5,2]  0.00000000  0.000000000  0.000000000
## 23  beta2_mu beta2_mu[1]  0.05700984 -0.062343226  0.216961805
## 24  beta2_mu beta2_mu[2]  0.00000000  0.000000000  0.000000000
## 25   beta_mu  beta_mu[1] -0.87621417 -2.041546162  0.370461512
## 26   beta_mu  beta_mu[2]  0.00000000  0.000000000  0.000000000
## 27     gamma    gamma[1]  0.89310694  0.865165270  0.923107083
## 28     gamma    gamma[2]  0.01327744  0.001717653  0.033330391
## 29     theta    theta[1] -0.02157768 -0.045969462  0.004041057
## 30     theta    theta[2]  2.99787193  1.691750249  4.515600592
```

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

#Behavior and environment

##Hierarchical 

### Ocean Depth
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-25-2.png)<!-- -->

### Distance to Coast
![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-26-2.png)<!-- -->

###Interaction

![](SingleSpecies_files/figure-html/unnamed-chunk-27-1.png)<!-- -->

## By Month

### Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-28-2.png)<!-- -->

Just the probability of feeding when traveling.

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->

### Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-30-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-30-2.png)<!-- -->

Zooming in on the top right plot.
![](SingleSpecies_files/figure-html/unnamed-chunk-31-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-31-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-34-1.png)<!-- -->


### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-8.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-9.png)<!-- -->

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-10.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-11.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-12.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-13.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-14.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-15.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-35-16.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration



![](SingleSpecies_files/figure-html/unnamed-chunk-40-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging across time



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-43-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

##All variables

![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->

# Overlap with Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-46-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-47-1.png)<!-- -->

## By Month





## Change in foraging areas

January verus May

Red = Better Foraging in Jan
Blue = Better Foraging in May

![](SingleSpecies_files/figure-html/unnamed-chunk-50-1.png)<!-- -->

## Monthly Overlap with Krill Fishery

![](SingleSpecies_files/figure-html/unnamed-chunk-51-1.png)<!-- -->



```
##             used   (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1762129   94.2    9556851  510.4  24262664 1295.8
## Vcells 261572963 1995.7  803012048 6126.5 920553407 7023.3
```
