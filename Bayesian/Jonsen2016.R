simTrack <- function(T = 100, theta = c(0, pi), gamma = c(0.95, 0.1),
                      alpha = c(0.9, 0.2), Sigma = matrix(c(5,0,0,5),2,2)){
  require(mvtnorm)
  start.date = strptime(format(Sys.time(), "%d/%m/%y %H:%M:%S"),
                        "%d/%m/%y %H:%M:%S", tz = "GMT")
  Y = X = matrix(NA, T, 2)
  TdX = matrix(NA, T-1, 2)
  X.mn = matrix(NA, T-1, 2)
  b = c()
  mu = c()
  tau.x = c()
  tau.y = c()
  nu.x = c()
  nu.y = c()
  X[1, ] = c(0,0) 
  #randomize starting step, random walk.
  X[2, ] = rmvnorm(1, X[1,], Sigma)
  b[1] = 1
  for(i in 2:(T-1)){
    b[i] = sample(1:2, 1, prob=c(alpha[b[i-1]],1-alpha[b[i-1]]), replace=TRUE)
    TdX[i,1] = cos(theta[b[i]]) * (X[i,1] - X[i-1,1]) +
      sin(theta[b[i]]) * (X[i,2] - X[i-1,2])
    TdX[i,2] = -sin(theta[b[i]]) * (X[i,1] - X[i-1,1]) +
      cos(theta[b[i]]) * (X[i,2] - X[i-1,2])
    X.mn[i,] = X[i,] + TdX[i,] * gamma[b[i]]
    X[i+1,] = rmvnorm(1, X.mn[i,], Sigma)
  }
  
  b[T] = sample(1:2, 1, prob=c(alpha[b[T-1]],1-alpha[b[T-1]]), replace=TRUE)
  ## time interval is nominally 1 h
  dates = seq(start.date, start.date + (T-1) * 3600, by=3600)
  simdat = data.frame(date=dates, x=X[,1], y = X[,2], b, theta=theta[b], gamma=gamma[b])
  simdat
}