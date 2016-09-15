#Source script to run model

runModel<-function(variable_name,mxy){
  
  #cut data to only include presences
  cmxy<-mxy %>% filter(!is.na(paste(variable_name)))

  #total number of steps per track/animal
  steps_all<-cmxy %>% group_by(Animal,Track) %>% summarize(n=length(unique(Step)))
  
  # give each step a label
  cmxy<-cmxy %>% group_by(Animal,Track,Step) %>% mutate(jStep=1:n())
  
  #Cast time array
  j<-acast(cmxy,Animal~Track~Step~jStep,value.var="j")
  
  #how many observations per individual in each Step
  mxy$Step<-factor(cmxy$Step,levels=1:max(steps_all$n))
  idx<-melt(table(cmxy$Animal,cmxy$Track,cmxy$Step))
  colnames(idx)<-c("Animal","Track","Step","jStep")
  idx<-acast(data=idx,Animal~Track~Step)
  
  #month array
  cmxy$MonthF<-as.numeric(factor(cmxy$Month,levels=month.name))
  
  MonthA<-acast(cmxy,Animal~Track~Step,value.var="MonthF",fun.aggregate = min)
  MonthA[!is.finite(MonthA)]<-NA
  
  #Individuals
  ind=length(unique(cmxy$Animal))
  
  #tracks per indivudal
  tracks<-cmxy %>% group_by(Animal) %>% summarize(tracks=length(unique(Track))) %>% .$tracks
  
  #steps per track
  steps<-acast(steps_all,Animal~Track,value.var="n")
  
  #obs array
  obs<-melt(cmxy,measure.vars=c("x","y"))
  obs<-acast(obs,Animal~Track~Step~jStep~variable)
  
  #make ocean a matrix -> MEAN VALUE -> will this yield a jags error on empty cells?
  variable<-acast(cmxy,Animal~Track~Step,value.var=variable_name,fun.aggregate = mean)
  
  #source jags file
  source("Bayesian/MultiSpecies.R")
  
  #prior cov shape
  R <- diag(c(1,1))
  data=list(argos=obs,steps=steps,R=R,variable=variable,ind=ind,j=j,idx=idx,tracks=tracks,Month=MonthA,Months=max(MonthA,na.rm=T))
  
  #paramters to track
  pt<-c("theta","gamma","alpha_mu","beta_mu","beta")
  
  system.time(jagM<-jags.parallel(model.file = "Bayesian/Multi_RW.jags",data=data,n.chains=2,parameters.to.save=pt,n.iter=5000,n.burnin=4700,n.thin=2,DIC=FALSE))

  #delete jags objects
  rm(data)
  rm(obs)
  rm(j)
  gc()
  
  #bind chains
  pc<-melt(jagM$BUGSoutput$sims.array)
  
  rm(jagM)
  gc()
  
  colnames(pc)<-c("Draw","chain","par","value")
  
  #extract parameter name
  pc$parameter<-data.frame(str_match(pc$par,"(\\w+)"))[,-1]
  
  #Extract index
  splitpc<-split(pc,pc$parameter)
  
  #single index
  splitpc[c("alpha_mu","beta_mu","gamma","theta")]<-lapply(splitpc[c("alpha_mu","beta_mu","gamma","theta")],function(x){
    sv<-data.frame(str_match(x$par,"(\\w+)\\[(\\d+)]"))[,3]
    pc<-data.frame(x,Behavior=sv)
    return(pc)
  })
  
  ## double index
  splitpc[c("beta")]<-lapply(splitpc[c("beta")],function(x){
    sv<-data.frame(str_match(x$par,"(\\w+)\\[(\\d+),(\\d+)]"))[,3:4]      
    colnames(sv)<-c("MonthF","Behavior")
    setp<-data.frame(x,sv)
    #get month name
    mindex<-cmxy %>% ungroup() %>% select(MonthF,Month) %>% distinct()
    setp<-merge(setp,mindex,by="MonthF")
    return(setp)
  })
  
  #bind all matrices back together
  pc<-rbind_all(splitpc)
  rm(splitpc)
  return(pc)
}

#memory function

# improved list of objects
.ls.objects <- function (pos = 1, pattern, order.by,
                         decreasing=FALSE, head=FALSE, n=5) {
  napply <- function(names, fn) sapply(names, function(x)
    fn(get(x, pos = pos)))
  names <- ls(pos = pos, pattern = pattern)
  obj.class <- napply(names, function(x) as.character(class(x))[1])
  obj.mode <- napply(names, mode)
  obj.type <- ifelse(is.na(obj.class), obj.mode, obj.class)
  obj.prettysize <- napply(names, function(x) {
    capture.output(format(utils::object.size(x), units = "auto")) })
  obj.size <- napply(names, object.size)
  obj.dim <- t(napply(names, function(x)
    as.numeric(dim(x))[1:2]))
  vec <- is.na(obj.dim)[, 1] & (obj.type != "function")
  obj.dim[vec, 1] <- napply(names, length)[vec]
  out <- data.frame(obj.type, obj.size, obj.prettysize, obj.dim)
  names(out) <- c("Type", "Size", "PrettySize", "Rows", "Columns")
  if (!missing(order.by))
    out <- out[order(out[[order.by]], decreasing=decreasing), ]
  if (head)
    out <- head(out, n)
  out
}

# shorthand
lsos <- function(..., n=10) {
  .ls.objects(..., order.by="Size", decreasing=TRUE, head=TRUE, n=n)
}


dplot<-function(a1,beta=c(0,0),x=0){
  
  #transition from Traveling to Foraging
  y<-1-inv.logit(a1[1]+beta[1]*x)
  d12<-data.frame(x,y,State="Foraging",Begin="Traveling")
  
  return(d12)
}
