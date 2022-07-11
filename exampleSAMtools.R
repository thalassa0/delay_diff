library(SAMtool)

res <- DD_TMB(x = 3, Data = MSEtool::SimulatedData)
# Provide starting values
start <- list(h = 0.95)
res <- DD_TMB(x = 3, Data = MSEtool::SimulatedData, start = start)
indat <- MSEtool::SimulatedData
str(indat)
plot(indat@Ind[1,],type ='b')
#plot(indat@Ind[3,])
lines(res@Obs_Index,col = "red")
res@Obs_Index 
str(res)

output <- DD_TMB(Data = MSEtool::SimulatedData)
plot(output)

plot(indat@Ind[1,],type ='b')
lines(output@TMB_report$Ipred,col="red")
