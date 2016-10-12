library(maps)
library(ggplot2)
library(raster)

#east west
u<-raster("C:/Users/Ben/Downloads/u-20150101000000000-0-0.tif")
plot(u)
map(add=T)

um<-raster("C:/Users/Ben/Downloads/um-20150101000000000-0-0.tif")
plot(um)
map(add=T)

#north south
v<-raster("C:/Users/Ben/Downloads/v-20150101000000000-0-0.tif")
plot(v)
map(add=T)

vm<-raster("C:/Users/Ben/Downloads/vm-20150101000000000-0-0.tif")
plot(vm)
map(add=T)
