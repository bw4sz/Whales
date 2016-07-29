#Download sea ice data

#Readme: https://nsidc.org/data/seaice_index/more-about-monthly.html
library(stringr)
library(rgdal)
library(maptools)
library(raster)
library(ggmap)
library(broom)
library(sp)

#Build the url
pols<-list()

Months<-month.abb
MonthNums=c("01","02","03","04","05","06","07","08","09","10","11",'12')
Years=seq(2012,2016,1)

#construct urls
urls<-list()
for(y in 1:length(Years)){
  yearurls<-list()
  for(x in 1:length(Months)){
    yearurls[[x]]<-paste('ftp://sidads.colorado.edu/DATASETS/NOAA/G02135/shapefiles/',Months[x],'/shp_extent/extent_S_',paste(Years[y],MonthNums[x],sep=""),'_polygon_v2.zip',sep="")
  }
  urls[[y]]<-yearurls
}
urls<-unlist(urls)


for(x in 1:length(urls)){

fl<-paste("InputData/SeaIce/",str_match(urls[[x]],"extent_S_(\\d+)")[,2],sep="")
download.file(urls[[x]],destfile=paste(fl,".zip",sep=""))

#unzip
unzip(zipfile=paste(fl,".zip",sep=""),exdir="./InputData/SeaIce")
}

#read
shp<-list.files("InputData/SeaIce",pattern=".shp",full.names=T)
pols<-list()
for(a in 1:length(shp)){

  r<-readShapePoly(shp[[a]])
  #define projection
  stere <- "+proj=stere +lat_0=-90 +lat_ts=-71 +lon_0=0 +datum=WGS84 +units=m"
  proj4string(r)<-stere
  rp <- spTransform(r, CRS("+proj=longlat +ellps=WGS84"))
  
  #get naming structure
  s<-str_match(shp[[a]],"S_(\\d+)_")[,2]
  yr<-as.numeric(substring(s,0,4))
  mn<-as.numeric(substring(s,5,6))
  rp$Combo<-paste(yr,mn,sep="_")
  rp$Year<-yr
  rp$Month<-mn
  pols[[a]]<-rp
}

#super ugly code to replace duplicate IDs.
v=1
npols<-list()
for(x in 1:length(pols)){
  tid<-spChFIDs(pols[[x]],as.character(v:(v+nrow(pols[[x]]@data)-1)))
  tid@data$id<-rownames(tid@data)
  npols[[x]]<-tid
  v=v+nrow(pols[[x]]@data)
}

bpols<-do.call(rbind,npols)

#turn to data.frame and bind
rpf<-tidy(bpols)
sf.df <- merge(rpf, bpols@data, by="id")

#overlay
temp <- get_map(location=bbox(p)*1.1,source="google",zoom=4,maptype="satellite",color = "bw",scale = 1)

ggmap(temp) + labs(fill="Month")+ geom_polygon(data=sf.df,aes(x=long,y=lat,group=group,fill=Month),linetype="dashed",size=1,alpha=0.2) + facet_wrap(~Year) + scale_color_continuous(low="black",high="blue")

write.csv(sf.df,"InputData/SeaIce_AllYears.csv")
