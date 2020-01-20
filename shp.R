#create shapefile

toexport<-mxy %>% select(Animal=individual.local.identifier,Track,step,jStep,x,y,timestamp,argos.lc,Behavior=phistate)
pts<-SpatialPointsDataFrame(cbind(toexport$x,toexport$y),toexport)

library(rgdal)
writeOGR(obj=pts, dsn="Figures", layer="Humpbacks", driver="ESRI Shapefile") # this is in geographical projection
