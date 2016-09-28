library(shiny)
library(mapview)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  
  #Read in data
  d<-read.csv("WhaleDat.csv")
  
  #ice data
  
  ##Base map
  wrapper <- function(df) {
    df  %>% select(x,y) %>% as.data.frame %>% Line %>% list %>% return
  }
  
  
  filteredData<-reactive({
    
    #filter based on slider
    #year
    if(input$year=="All"){yr<-c(2012:2016)} else{yr<-input$year}
    #Month
    if(input$month=="All"){mn<-month.name} else{mn<-input$month}
    
    y <-  d %>% group_by(Animal) %>% filter(Year %in% yr,Month %in% mn) %>%
      do(res = wrapper(.))
    
    #break if there is no data
    if(nrow(y)==0){return(NULL)}
    
    # and now assign IDs (since we can't do that inside dplyr easily)
    ids = 1:dim(y)[1]
    data<-SpatialLines(
      mapply(x = y$res, ids = ids, FUN = function(x,ids) {Lines(x,ID=ids)})
      ,proj4string=CRS("+proj=longlat +datum=WGS84"))
    
    dinfo<-d %>% filter(Year %in% yr, Month %in% mn) %>% distinct(Animal) 
    spl<-SpatialLinesDataFrame(data,dinfo)
    
    return(spl)
  })
  
  
  m <- leaflet(d) %>% addTiles() %>% fitBounds(~min(x),~min(y),~max(x),~max(y))
observe({
  
  
  #check if there is data for the month year combination
  addD<-filteredData()
  
  #color new data
  pal<-colorFactor(topo.colors(10),addD$Animal)
  
  if(is.null(addD)){
    #clear screen
    leafletProxy("mymap",data=addD) %>% clearShapes()
  }else{
    #add tracks
    proxy<-leafletProxy("mymap",data=addD) %>% clearShapes() %>% addPolylines(popup=~as.character(Animal),color=~pal(Animal),weight=2)  
  }
})
  output$mymap <- renderLeaflet(m)
  }
