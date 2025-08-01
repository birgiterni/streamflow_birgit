## random walk with 1000 data points

## streamflow = log(streamflow)

data <- list(y = streamflow,
             n = length(streamflow),      ## data
             x_ic = mean(streamflow, na.rm = TRUE),
             tau_ic = 100, ## initial condition prior
             a_obs = 1,
             r_obs = 1,           ## obs error prior
             a_add = 1,
             r_add = 1            ## process error prior
)


nchain = 3
init <- list()
for(i in 1:nchain){
  ##  y.samp = sample(y,length(y),replace=TRUE)
  init[[i]] <- list(tau_add = 1 / var(diff(streamflow), na.rm= TRUE),  ## initial guess on process precision
                    tau_obs = 5 / var(streamflow, na.rm= TRUE) )     ## initial guess on obs precision
}


j.model   <- jags.model (file = "random_walk.jags",
                         data = data,
                         inits = init,
                         n.chains = 3)


## burn-in
jags.out   <- coda.samples (model = j.model,
                            variable.names = c("tau_add","tau_obs"),
                            n.iter = 1000)
plot(jags.out)
#dic.samples(j.model, 2000)



jags.out   <- coda.samples (model = j.model,
                            variable.names = c("x","tau_add","tau_obs"),
                            n.iter = 10000)



### plot hindcasts and observations

tt = seq(1, length(streamflow))       ## adjust to zoom in and out
out <- as.matrix(jags.out)         ## convert from coda to matrix  
x.cols <- grep("^x",colnames(out)) ## grab all columns that start with the letter x
ci <- apply(out[,x.cols],2,quantile,c(0.025,0.5,0.975)) ## model was fit on log scale

plot(tt, ci[2,], type = 'n', ylab="Flu Index", ylim = c(-3, 3), las = 1)
## adjust x-axis label to be monthly if zoomed
# if(diff(time.rng) < 100){ 
#   axis.Date(1, at=seq(time[time.rng[1]],time[time.rng[2]],by='month'), format = "%Y-%m")
# }
ecoforecastR::ciEnvelope(tt, ci[1,], ci[3,], 
                         col=ecoforecastR::col.alpha("lightBlue",0.75))
points(tt, streamflow, pch="+", cex=0.5)




