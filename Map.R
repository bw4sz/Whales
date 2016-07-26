library(raster)
library(reshape2)
library(ggplot2)
library(survival)
library(MASS)
library(ggmap)
library(dplyr)
library(chron)
library(gridExtra)
library(stringr)
library(R2jags)
library(move)

mxy<-read.csv("C:/Users/Ben/Downloads/Antarctic Humpback overlap with krill fisheries .csv")

#standardize column names to match the simulation
#Create an animal tag.
mxy <- as(mxy, "data.frame")
mxy$Animal<-mxy$individual.local.identifier
mxy$x<-mxy$location.long
mxy$y<-mxy$location.lat

#set datestamp
mxy$timestamp<-as.POSIXct(mxy$timestamp,format="%Y-%m-%d %H:%M:%S.000")

#remove empty timestamps
mxy<-mxy[!is.na(mxy$timestamp),]
mxy<-mxy[!is.na(mxy$x),]

mxy<-mxy[mxy$x < -40 & mxy$x > -80,]

#crop by extent
d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy)

#Plot
pp<-coordinates(d)
m <- get_map(location=c(-90,-100,-40,12),source="google",zoom=3,scale=2,maptype="satellite")
ggmap(m)+geom_path(data=mxy, aes(x=x, y=y,col=as.factor(Animal)),size=.5) + labs(col="Whale") + scale_color_discrete(guide="none") + theme_inset()
ggsave("Figures/AllDistribution.jpeg",dpi=600,height=5,width=5)

#Just the ongoing whales

live<-mxy[mxy$Animal %in% c("131133","131127","131136"),]
d<-SpatialPointsDataFrame(cbind(live$x,live$y),data=live)

#Plot
pp<-coordinates(d)
m <- get_googlemap(center=c(-61,-64),source="google",zoom=6,scale=2,maptype="satellite",style = c('element:labels|visibility:off'))
ggmap(m)+geom_path(data=live[live$x > -65,], aes(x=x, y=y,col=as.factor(Animal)),size=.5) + labs(col="Whale") + scale_color_discrete(guide="none") + facet_wrap(~Animal) + theme_inset()
ggsave("Figures/LiveTags.jpeg",dpi=600,height=6,width=7)

krill<-read.csv("InputData/CCAMLR_aggregated_catch_C1.csv")


r<-raster(ext=extent(c(-70,-55,-67,-54)))
temp <- get_map(location=bbox(r),source="google",zoom=5,maptype="satellite",color = "bw",scale = 2)

krill$catch<-krill$C1KRIcatchKG/1000
p<-ggmap(temp) 
p<-p + geom_path(data=mxy, aes(x=x, y=y,group=Animal),size=.3,col="springgreen4",alpha=0.5) + geom_point(data=krill,aes(x=GridMidpointDegreeLon,y=GridMidpointHalfDegreeLat,size=catch)) + scale_size(range=c(1,10))
p<-p +  labs(size="Krill Catch (Metric Tons)") 
p
ggsave("Figures/KrillTracks.jpeg",dpi=600,height=5,width=5)

#mxy<-as.data.frame(d)
