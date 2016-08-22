#Download sea ice data

#Readme: https://nsidc.org/data/seaice_index/more-about-monthly.html
library(stringr)
library(rgdal)
library(maptools)
library(raster)
library(ggmap)
library(scales)
library(broom)
library(sp)
library(rgeos)

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

  rp<-readShapePoly(shp[[a]])
  #define projection
  stere <- "+proj=stere +lat_0=-90 +lat_ts=70 +lon_0=0 +datum=WGS84 +units=m"
  proj4string(rp)<-stere

  #0 width buffer
  #rp <- gBuffer(rp, byid=TRUE, width=0)
  #crop
  e<-extent(-3455516,-757334.6,66739.71,2200756)*1.1
  rmask<-raster(rp,ext=e)
  rmask<-disaggregate(rmask,10)
  rasP<-rasterize(rp,rmask)
  #presence of ice
  rasP <- projectRaster(rasP,crs=CRS("+proj=longlat +ellps=WGS84"))
  rasP<-rasP>0
  pols[[a]]<-rasP
  
  #name the layers
  #get naming structure
  s<-str_match(shp[[a]],"S_(\\d+)_")[,2]
  yr<-as.numeric(substring(s,0,4))
  mn<-as.numeric(substring(s,5,6))
  names(pols[[a]])<-paste(month.abb[mn],yr,sep="_")
}
spols<-stack(pols)
#writeindividaul raster
writeRaster(spols,"InputData/MonthlyIceRaster",overwrite=T)

#temp <- get_map(location=bbox(e),source="google",zoom=3,maptype="satellite",color = "bw",scale = 2)
#ggmap(temp) + labs(fill="Month")+ geom_tile(data=sf.df,aes(x=long,y=lat,group=group,fill=Month),alpha=0.5) + facet_wrap(~Year) + scale_fill_gradient2(low=muted("blue"),mid="red",high=muted("blue"),midpoint=6,breaks=seq(0,12,3)) + theme(axis.text.x=element_blank(),axis.text.y=element_blank()) + labs(x="",y="")

#ggmap(temp) + labs(fill="Month")+ geom_polygon(data=sf.df,aes(x=long,y=lat,group=group,fill=Month),alpha=0.5) + facet_wrap(~Year) + scale_fill_gradient2(low=muted("blue"),mid="red",high=muted("blue"),midpoint=6,breaks=seq(0,12,3)) + theme(axis.text.x=element_blank(),axis.text.y=element_blank()) + labs(x="",y="")
#ggmap(temp) + labs(fill="Year")+ geom_polygon(data=sf.df,aes(x=long,y=lat,group=group,fill=Year),alpha=0.5) + facet_wrap(~Month) + theme(axis.text.x=element_blank(),axis.text.y=element_blank()) + labs(x="",y="")

#ggsave("Figures/SeaIceYear.jpeg",dpi=400,height=7,width=10)
#write.csv(sf.df,"InputData/SeaIce_AllYears.csv")


#as individual polygons
#read
shp<-list.files("InputData/SeaIce",pattern="v2.shp",full.names=T)
polygonlist<-list()
for(a in 1:length(shp)){
  
  rp<-readShapePoly(shp[[a]])
  #define projection
  stere <- "+proj=stere +lat_0=-90 +lat_ts=70 +lon_0=0 +datum=WGS84 +units=m"
  proj4string(rp)<-stere
  
  #0 width buffer
  rp <- gBuffer(rp, byid=TRUE, width=0)
  #crop
  e<-extent(-3455516,-757334.6,66739.71,2200756)*1.1
  crp<-crop(rp,e)
  plot(tcrp<-spTransform(crp,CRS("+proj=longlat +ellps=WGS84")))

  #name the layers
  #get naming structure
  s<-str_match(shp[[a]],"S_(\\d+)_")[,2]
  yr<-as.numeric(substring(s,0,4))
  mn<-as.numeric(substring(s,5,6))
  polygonlist[[a]]<-fortify(tcrp)
  names(polygonlist)[[a]]<-paste(month.abb[mn],yr,sep="_")
}

#write each
for(x in 1:length(polygonlist)){
  write.csv(polygonlist[[x]],paste("C:/Users/Ben/Documents/Whales/InputData/SeaIce/",names(polygonlist)[[x]],"LatLong.csv",sep=""))
}
