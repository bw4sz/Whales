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
##  1350.585     6.543 74276.170
```

##Chains


![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->




![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

## Parameter Summary

```
##    parameter         par         mean        lower         upper
## 1   alpha_mu alpha_mu[1] -0.293451174 -0.806702071  0.1358820567
## 2   alpha_mu alpha_mu[2] -1.528233450 -1.882607729 -1.1609695098
## 3       beta   beta[1,1]  0.266502681 -0.976187762  1.4885335464
## 4       beta   beta[2,1] -0.282060362 -1.404995015  0.6052905549
## 5       beta   beta[3,1]  0.420818327 -0.365476354  1.1637208103
## 6       beta   beta[4,1]  0.387767466 -0.375100908  1.2317937295
## 7       beta   beta[5,1]  0.400383137 -1.153769778  1.5639176455
## 8       beta   beta[6,1]  0.194803814 -1.545564449  1.7163936354
## 9       beta   beta[1,2]  0.000000000  0.000000000  0.0000000000
## 10      beta   beta[2,2]  0.000000000  0.000000000  0.0000000000
## 11      beta   beta[3,2]  0.000000000  0.000000000  0.0000000000
## 12      beta   beta[4,2]  0.000000000  0.000000000  0.0000000000
## 13      beta   beta[5,2]  0.000000000  0.000000000  0.0000000000
## 14      beta   beta[6,2]  0.000000000  0.000000000  0.0000000000
## 15     beta2  beta2[1,1]  0.017325698  0.002925333  0.0335490794
## 16     beta2  beta2[2,1]  0.016609239  0.003851263  0.0310109340
## 17     beta2  beta2[3,1]  0.004607113 -0.006453386  0.0153889846
## 18     beta2  beta2[4,1]  0.014839781  0.001452640  0.0286230046
## 19     beta2  beta2[5,1]  0.053829294  0.004112717  0.2046698586
## 20     beta2  beta2[6,1]  0.033459543 -0.060517109  0.1989150829
## 21     beta2  beta2[1,2]  0.000000000  0.000000000  0.0000000000
## 22     beta2  beta2[2,2]  0.000000000  0.000000000  0.0000000000
## 23     beta2  beta2[3,2]  0.000000000  0.000000000  0.0000000000
## 24     beta2  beta2[4,2]  0.000000000  0.000000000  0.0000000000
## 25     beta2  beta2[5,2]  0.000000000  0.000000000  0.0000000000
## 26     beta2  beta2[6,2]  0.000000000  0.000000000  0.0000000000
## 27  beta2_mu beta2_mu[1]  0.021914695 -0.011381467  0.0769331025
## 28  beta2_mu beta2_mu[2]  0.000000000  0.000000000  0.0000000000
## 29   beta_mu  beta_mu[1]  0.215616132 -0.660868507  0.9920253193
## 30   beta_mu  beta_mu[2]  0.000000000  0.000000000  0.0000000000
## 31     gamma    gamma[1]  0.902882918  0.857082544  0.9425765276
## 32     gamma    gamma[2]  0.099915001  0.021423116  0.1528077520
## 33     theta    theta[1] -0.022700510 -0.043614793 -0.0005158225
## 34     theta    theta[2]  0.596110903  0.263395566  1.5542154641
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

Just mean estimate.

![](SingleSpecies_files/figure-html/unnamed-chunk-32-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-32-2.png)<!-- -->

#Behavioral Prediction



###Correlation in posterior switching and state



##Spatial Prediction

![](SingleSpecies_files/figure-html/unnamed-chunk-35-1.png)<!-- -->

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-8.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-9.png)<!-- -->

```
## 
## $`10`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-10.png)<!-- -->

```
## 
## $`11`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-11.png)<!-- -->

```
## 
## $`12`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-12.png)<!-- -->

```
## 
## $`13`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-13.png)<!-- -->

```
## 
## $`14`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-14.png)<!-- -->

```
## 
## $`15`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-15.png)<!-- -->

```
## 
## $`16`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-16.png)<!-- -->

```
## 
## $`17`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-17.png)<!-- -->

```
## 
## $`18`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-18.png)<!-- -->

```
## 
## $`19`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-19.png)<!-- -->

```
## 
## $`20`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-20.png)<!-- -->

```
## 
## $`21`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-21.png)<!-- -->

```
## 
## $`22`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-22.png)<!-- -->

```
## 
## $`23`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-23.png)<!-- -->

```
## 
## $`24`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-24.png)<!-- -->

```
## 
## $`25`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-25.png)<!-- -->

```
## 
## $`26`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-26.png)<!-- -->

```
## 
## $`27`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-27.png)<!-- -->

```
## 
## $`28`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-28.png)<!-- -->

```
## 
## $`29`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-29.png)<!-- -->

```
## 
## $`30`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-30.png)<!-- -->

```
## 
## $`31`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-31.png)<!-- -->

```
## 
## $`32`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-32.png)<!-- -->

```
## 
## $`33`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-33.png)<!-- -->

```
## 
## $`34`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-34.png)<!-- -->

```
## 
## $`35`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-35.png)<!-- -->

```
## 
## $`36`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-36.png)<!-- -->

```
## 
## $`37`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-37.png)<!-- -->

```
## 
## $`38`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-38.png)<!-- -->

```
## 
## $`39`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-36-39.png)<!-- -->

##Log Odds of Foraging

### Ocean Depth

![](SingleSpecies_files/figure-html/unnamed-chunk-37-1.png)<!-- -->

### Distance From Coast

![](SingleSpecies_files/figure-html/unnamed-chunk-38-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-39-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration



![](SingleSpecies_files/figure-html/unnamed-chunk-41-1.png)<!-- -->

##Location of Behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-42-1.png)<!-- -->

#Environmental Prediction - Probability of Foraging across time



## Bathymetry

![](SingleSpecies_files/figure-html/unnamed-chunk-44-1.png)<!-- -->

## Distance to coast

![](SingleSpecies_files/figure-html/unnamed-chunk-45-1.png)<!-- -->

##All variables

![](SingleSpecies_files/figure-html/unnamed-chunk-46-1.png)<!-- -->

# Overlap with Krill Fishery
![](SingleSpecies_files/figure-html/unnamed-chunk-47-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-48-1.png)<!-- -->

## By Month





## Change in foraging areas

Jan verus May

Red = Better Foraging in Jan
Blue = Better Foraging in May

![](SingleSpecies_files/figure-html/unnamed-chunk-51-1.png)<!-- -->

### Variance in monthly suitability

![](SingleSpecies_files/figure-html/unnamed-chunk-52-1.png)<!-- -->

### Mean suitability

![](SingleSpecies_files/figure-html/unnamed-chunk-53-1.png)<!-- -->

## Monthly Overlap with Krill Fishery

![](SingleSpecies_files/figure-html/unnamed-chunk-54-1.png)<!-- -->



```
##             used   (Mb) gc trigger    (Mb)   max used    (Mb)
## Ncells   1995786  106.6   20802690  1111.0   40630256  2169.9
## Vcells 551274068 4205.9 1537507796 11730.3 1918645931 14638.2
```
