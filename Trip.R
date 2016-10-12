library(trip)
d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy,proj4string=CRS("+proj=longlat +datum=WGS84"))
dat<-trip(d,c("timestamp","Animal"))
plot(dat)
#20km per hour
sdat<-speedfilter(dat,max.speed = 37.04)
dat$Filter<-sdat

a<-data.frame(dat) %>% filter(Filter==T)
write.csv(a,"InputData/FilteredData.csv")
