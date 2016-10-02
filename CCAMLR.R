library(maptools)
library(mapview)
library(webshot)
library(stringr)
ccamlr<-readShapePoly("InputData/SSMU_2013/CROPCCAMLR.shp")
#remove tiny polygons
area <- lapply(ccamlr@polygons, function(x) sapply(x@Polygons, function(y) y@area))
quantile(unlist(area))

mainPolys <- lapply(area, function(x) which(x > 1))
mainPolys <- mainPolys[]
for(i in 1:length(mainPolys)){
  if(length(mainPolys[[i]]) >= 1 && mainPolys[[i]][1] >= 1){
    ccamlr@polygons[[i]]@Polygons <- ccamlr@polygons[[i]]@Polygons[mainPolys[[i]]]
    ccamlr@polygons[[i]]@plotOrder <- 1:length(ccamlr@polygons[[i]]@Polygons)
  }
}

proj4string(ccamlr)<-c("+proj=longlat")
pal <- colorRampPalette(brewer.pal(length(ccamlr$SSMUname), "Accent"))
mapviewOptions(legend.pos = "bottomright")

#format names
ccamlr$Unit<-ccamlr$SSMUname
ccamlr$Unit<-gsub(x=ccamlr$Unit,pattern="Antarctic Peninsula ",rep="")

ggmap(m)+ geom_polygon(data=fccamlr,aes(x=long,y=lat,fill=id),col="black",size=1) + scale_fill_brewer(palette="Accent") + labs(fill="Unit")
ggsave("Figures/CCAMLRmap.jpeg")
m2<-mapview(ccamlr,legend=T,zcol="Unit",color=pal,alpha.regions=0.75,layer.name="Unit")
saveWidget(m2@map, "CCAMLR.html", selfcontained = FALSE)
webshot::webshot("CCAMLR.html", file = "Figures/CAMMLR.png",cliprect = "viewport")
