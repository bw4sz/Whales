library(ggplot2)
library(gridExtra)
te<-function(step_length=4,hr="4 hours",mintime=12){
  #read data
  mdat<-read.csv("InputData/FilteredData.csv",row.names=1)
  #standardize column names to match the simulation
  #Create an animal tag.
  mxy <- as(mdat, "data.frame")
  mxy$Animal<-mxy$individual.local.identifier
  mxy$x<-mxy$location.long
  mxy$y<-mxy$location.lat
  
  #make sure to remove minke whales, should be already gone, but justfor safety
  minke<-c("131117","131118","131120","154184")
  mxy<-mxy[!mxy$individual.local.identifier %in% minke,]
  
  #grab set of animals
  #mxy<-mxy[mxy$Animal %in% c("131143","131142"),]
  
  #empty coordinates
  mxy<-mxy[!is.na(mxy$x),]
  
  #crop by extent
  d<-SpatialPointsDataFrame(cbind(mxy$x,mxy$y),data=mxy,proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  cropoly<-readShapePoly("InputData/CutPolygon.shp",proj4string=CRS("+proj=longlat +datum=WGS84"))
  
  b<-d[!is.na(d %over% cropoly)[,2],]
  
  mxy<-b@data
  
  #set datestamp
  mxy$timestamp<-as.POSIXct(mxy$timestamp)
  
  #month and year columns
  mxy$Month<-months(mxy$timestamp)
  mxy$Year<-years(mxy$timestamp)
  
  #Only austral sping and summer
  mxy<-mxy[mxy$Month %in% month.name[1:7],]
  
  #remove empty timestamps
  mxy<-mxy[!is.na(mxy$timestamp),]
  
  #remove duplicates
  mxy<-mxy[!duplicated(data.frame(mxy$timestamp,mxy$Animal)),]
  mxy<-mxy[!mxy$ETOPO1.Elevation>0,]
  
  
  ##Time is the beginning of the first point.
  step_length=step_length
  
  sxy<-split(mxy,mxy$Animal)
  
  #time diff function
  timed<-function(d,step_length){
    d$j[1]<-0
    for (x in 2:nrow(d)){
      d$j[x]<-as.numeric(difftime(as.POSIXct(d$timestamp[x]),as.POSIXct(d$timestamp[x-1]),units="mins"))/(step_length*60)
    }
    
    #Split out track endings
    ends<-c(1,which(d$j>1),nrow(d))
    
    for(w in 2:length(ends)){
      d[ends[w-1]:ends[w],"Track"]<-w-1
    }
    
    #remove tracks that are shorter than three days
    track_time<-d %>% group_by(Track) %>% summarize(mt=difftime(max(as.POSIXct(timestamp)),min(as.POSIXct(timestamp)),units="hours")) %>% filter(mt>=mintime) %>% .$Track
    
    d<-d[d$Track %in% track_time,]
    
    #renumber the tracks
    d$Track<-as.numeric(as.factor(d$Track))
    return(d)
  }
  
  sxy<-lapply(sxy,timed,step_length=step_length)
  
  #Format matrices for jags
  mxy<-rbind_all(sxy)
  
  ######recode whales
  #mxy$Animal<-as.numeric(as.factor(mxy$Animal))
  
  sxy<-split(mxy,list(mxy$Animal,mxy$Track),drop=TRUE)
  
  sxy<-lapply(sxy,function(x){
    #How many observations in each step length segment
    x$step<-as.numeric(cut(as.POSIXct(x$timestamp),hr))
    return(x)
  })
  
  mxy<-rbind_all(sxy)
  
  #refactor animal
  mxy$Animal<-as.numeric(as.factor(mxy$Animal))
  
  print(paste("nrows =",nrow(mxy)))
  print(paste("individuals",length(unique(mxy$Animal))))
  cl<-rainbow(100)
  cl<-sample(cl)
  p<-ggplot() + geom_path(data=mxy, aes(x=x, y=y,group=1),size=0.1,col="black") + labs(col="step")
  p<-p+geom_path(data=mxy, aes(x=x, y=y,col=as.numeric(step),group=paste(Track,step)),size=1) + labs(x="",y="") + theme(axis.text.x=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank(),axis.ticks.x=element_blank()) + scale_color_gradientn(colours = cl) + theme_bw() + facet_wrap(~Animal,scales="free") 
  print(p)
  return(p)
}

p6<-te(step_length = 9,hr="9 hours",12)
