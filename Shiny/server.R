library(shiny)
library(mapview)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  
  #Read in data
  d<-read.csv("WhaleDat.csv")
  
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
  
  #Base map
  m<-leaflet() %>% addTiles() 
  
  #By Year
    dinfo<-d %>% distinct(Animal) %>% select(Animal,Year)
    spl<-SpatialLinesDataFrame(data,dinfo)
    
    #Associate points data
    spp<-SpatialPointsDataFrame(data=d,cbind(d$x,d$y),proj4string=CRS("+proj=longlat +datum=WGS84"))
    
    #points
    #m <- leaflet() %>% addTiles() %>% addMarkers(data=spp,lng=~x,lat=~x,clusterId = ~Animal,clusterOptions = markerClusterOptions())
    
    binpal <- colorBin("RdYlBu", dinfo$Year, 6, pretty = FALSE)

  m <- leaflet() %>% addTiles() %>% addPolylines(data=spl,color=~binpal(Year),popup=~as.character(Animal),weight=2)
  output$mymap <- renderLeaflet(m)
}
