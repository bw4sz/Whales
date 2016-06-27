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

![](SingleSpecies_files/figure-html/unnamed-chunk-14-1.png)<!-- -->![](SingleSpecies_files/figure-html/unnamed-chunk-14-2.png)<!-- -->




```
##      user    system   elapsed 
##    15.889     0.826 10408.522
```

##Chains
![](SingleSpecies_files/figure-html/unnamed-chunk-17-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-18-1.png)<!-- -->

###Compare to priors

![](SingleSpecies_files/figure-html/unnamed-chunk-19-1.png)<!-- -->

##Prediction - environmental function

![](SingleSpecies_files/figure-html/unnamed-chunk-20-1.png)<!-- -->

#Behavioral Prediction



##Spatial Prediction

### Per Animal

```
## $`1`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-1.png)<!-- -->

```
## 
## $`2`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-2.png)<!-- -->

```
## 
## $`3`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-3.png)<!-- -->

```
## 
## $`4`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-4.png)<!-- -->

```
## 
## $`5`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-5.png)<!-- -->

```
## 
## $`6`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-6.png)<!-- -->

```
## 
## $`7`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-7.png)<!-- -->

```
## 
## $`8`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-8.png)<!-- -->

```
## 
## $`9`
```

![](SingleSpecies_files/figure-html/unnamed-chunk-22-9.png)<!-- -->

##Log Odds of Feeding
![](SingleSpecies_files/figure-html/unnamed-chunk-23-1.png)<!-- -->

##Autocorrelation in behavior

![](SingleSpecies_files/figure-html/unnamed-chunk-24-1.png)<!-- -->

##Behavioral description

## Predicted behavior duration
![](SingleSpecies_files/figure-html/unnamed-chunk-25-1.png)<!-- -->

![](SingleSpecies_files/figure-html/unnamed-chunk-26-1.png)<!-- -->

##Location of Behavior



Global Plotting

![](SingleSpecies_files/figure-html/unnamed-chunk-28-1.png)<!-- -->

###Proportional Hazards

Survival analysis typically examines the relationship between time to death as a function of covariates. From this we can get the instantaneous rate of death at time t f(t), which is the cumulative distribution of the likelihood of death.

Let T represent survival time.

$$ P(t) = Pr(T<t)$$ 
with a pdf
$$p(t) = \frac{dP(t)}{dt}$$

The instantaneous risk of death at time t (h(t)), conditional on survival to that time:

$$ h(t) = \lim{\Delta_t\to 0} \frac{Pr[(t<T<t + \Delta_t)]|T>t}{\Delta t}$$

with covariates:
$$log (h_i(t)) = \alpha + \beta_i *x$$

The cox model has no intercept, making it semi-parametric
$$ log(h_i(t)) = h_0(t) + \beta_1 * x$$

![](SingleSpecies_files/figure-html/unnamed-chunk-29-1.png)<!-- -->


```
##             used  (Mb) gc trigger   (Mb)  max used   (Mb)
## Ncells   1842953  98.5   27854852 1487.7  43523207 2324.4
## Vcells 128192733 978.1  968765433 7391.1 901491842 6877.9
```
