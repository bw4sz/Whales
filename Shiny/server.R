library(shiny)
library(mapview)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  d<-read.csv("WhaleDat.csv")
  
  d<-d %>% filter(Animal %in% c("112699","121207","131151"))

  wrapper <- function(df) {
    df  %>% select(x,y) %>% as.data.frame %>% Line %>% list %>% return
  }
  
  y <-  d %>% group_by(Animal) %>%
    do(res = wrapper(.)) 
  
  # and now assign IDs (since we can't do that inside dplyr easily)
  ids = 1:dim(y)[1]
  data<-SpatialLines(
    mapply(x = y$res, ids = ids, FUN = function(x,ids) {Lines(x,ID=ids)})
  ,proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  #Associate line data - data doesn't quite work
  spl<-SpatialLinesDataFrame(data,d)
  spp<-SpatialPointsDataFrame(data=d,cbind(d$x,d$y),proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  #points
  m <- leaflet() %>% addTiles() %>% addMarkers(data=spp,lng=~x,lat=~x,clusterId = ~Animal,clusterOptions = markerClusterOptions())
  output$mymap <- renderLeaflet(m)
    #renderMapview(mapview(data,zcol="Year")) %>% addMarkers(d,lng = ~x, lat=~y,group=~Animal)
}
