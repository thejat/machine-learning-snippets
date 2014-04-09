#Source: ks: KDE for Bivariate data by Tarn Duong, 2013-07-05
library(ks)
set.seed(8092)
samp <- 200 #number of observations
mus <- rbind(c(-2,2),c(0,0),c(2,-2))#centers of the gaussians
Sigmas <- rbind(diag(2),matrix(c(0.8,-0.72,-0.72,.8),nrow=2),diag(2))#the three covariance matrices
cwt <- 3/11 #parameter between (0,1) used to set weights on the three gaussians
props <- c((1-cwt)/2, cwt,(1-cwt)/2) #the weights, adding up to 1
x <- rmvnorm.mixt(n=samp,mu=mus,Sigma=Sigmas,props=props)

Hpi1 <- Hpi(x=x)
Hpi2 <- Hpi.diag(x=x)

fhat.pi1 <- kde(x=x,H=Hpi1)
fhat.pi2 <- kde(x=x,H=Hpi2)

plot(x)
plot(fhat.pi1)
plot(fhat.pi2)
