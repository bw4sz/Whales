library(shiny)
library(mapview)
library(maptools)
library(dplyr)
library(htmltools)

server <- function(input, output, session) {
  
  #Read in data
  d<-read.csv("FilteredData.csv",row.names=1)
  
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
    
    if(input$ind=="All"){i<-unique(d$Animal)} else{i<-input$ind}
    
    #get order
    
    y <-  d %>% group_by(Animal) %>% filter(Year %in% yr,Month %in% mn,Animal %in% i) %>%
      do(res = wrapper(.)) %>% arrange(Animal)
    
    #keep order
    
    
    #break if there is no data
    if(nrow(y)==0){return(NULL)}
    
    # and now assign IDs (since we can't do that inside dplyr easily)
    ids = 1:dim(y)[1]
    data<-SpatialLines(
      mapply(x = y$res, ids = ids, FUN = function(x,ids) {Lines(x,ID=ids)})
      ,proj4string=CRS("+proj=longlat +datum=WGS84"))
    
    dinfo<-d %>% group_by(Animal) %>% filter(Year %in% yr,Month %in% mn,Animal %in% i) %>% distinct() %>% arrange(Animal) %>% as.data.frame() 
    spl<-SpatialLinesDataFrame(sl=data,data=dinfo)
    
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
  #if only one animal is plotted, add points.
  if(length(unique(addD$Animal))==1){
    
    #get spatial points for that animal
    ll<-d %>% filter(Animal %in% unique(addD$Animal)) %>% as.data.frame() 
    ll<-SpatialPointsDataFrame(cbind(ll$x,ll$y),data=ll)

    #add timestamp points
    proxy<-leafletProxy("mymap") %>% clearShapes() %>% addPolylines(data=addD,color=~pal(Animal),weight=4)  %>% addCircles(data=ll,popup=~as.character(timestamp),weight = 4, radius=60, 
                                                                                    color="#000000", stroke = TRUE, fillOpacity = 0.8)  
    
  }
})
  output$mymap <- renderLeaflet(m)
  }
