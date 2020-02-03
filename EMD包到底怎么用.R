### boundary = "none"
nData <- nrow(maxTemperatureByDay)
xt2 <- maxTemperatureByDay[1:nData, 1]
tt2 <- seq(1, nData)
try <- emd(xt2, tt2, boundary = "none")
par(mfrow=c(try$nimf+2, 1), mar=c(2,1,2,1))
rangeimf <- range(try$imf)
plot(xt2, type = "l", xlab="", ylab="", main = "none")
for(i in 1:try$nimf) {
  plot(tt2, try$imf[,i], type="l", xlab="", ylab="", ylim=rangeimf,
       main=paste(i, "-th IMF", sep="")); abline(h=0)
}
plot(tt2, try$residue, xlab="", ylab="", main="residue", type="l", axes=FALSE);
box()
par(mfrow = c(1,1))


### boundary = "wave"
nData <- nrow(maxTemperatureByDay)
xt2 <- maxTemperatureByDay[1:nData, 1]
tt2 <- seq(1, nData)
try <- emd(xt2, tt2, boundary = "wave")
par(mfrow=c(try$nimf+2, 1), mar=c(2,1,2,1))
rangeimf <- range(try$imf)
plot(xt2, type = "l", xlab="", ylab="", main = "wave")
for(i in 1:try$nimf) {
  plot(tt2, try$imf[,i], type="l", xlab="", ylab="", ylim=rangeimf,
       main=paste(i, "-th IMF", sep="")); abline(h=0)
}
plot(tt2, try$residue, xlab="", ylab="", main="residue", type="l", axes=FALSE);
box()
par(mfrow = c(1,1))


### boundary = "symmetric"
nData <- nrow(maxTemperatureByDay)
xt2 <- maxTemperatureByDay[1:nData, 1]
tt2 <- seq(1, nData)
try <- emd(xt2, tt2, boundary = "symmetric")
par(mfrow=c(try$nimf+2, 1), mar=c(2,1,2,1))
rangeimf <- range(try$imf)
plot(xt2, type = "l", xlab="", ylab="", main = "symmetric")
for(i in 1:try$nimf) {
  plot(tt2, try$imf[,i], type="l", xlab="", ylab="", ylim=rangeimf,
       main=paste(i, "-th IMF", sep="")); abline(h=0)
}
plot(tt2, try$residue, xlab="", ylab="", main="residue", type="l", axes=FALSE);
box()
par(mfrow = c(1,1))


### boundary = "periodic"
nData <- nrow(maxTemperatureByDay)
xt2 <- maxTemperatureByDay[1:nData, 1]
tt2 <- seq(1, nData)
try <- emd(xt2, tt2, boundary = "periodic")
par(mfrow=c(try$nimf+2, 1), mar=c(2,1,2,1))
rangeimf <- range(try$imf)
plot(xt2, type = "l", xlab="", ylab="", main = "periodic")
for(i in 1:try$nimf) {
  plot(tt2, try$imf[,i], type="l", xlab="", ylab="", ylim=rangeimf,
       main=paste(i, "-th IMF", sep="")); abline(h=0)
}
plot(tt2, try$residue, xlab="", ylab="", main="residue", type="l", axes=FALSE);
box()
par(mfrow = c(1,1))


### boundary = "evenodd"
nData <- nrow(maxTemperatureByDay)
xt2 <- maxTemperatureByDay[1:nData, 1]
tt2 <- seq(1, nData)
try <- emd(xt2, tt2, boundary = "evenodd")
par(mfrow=c(try$nimf+2, 1), mar=c(2,1,2,1))
rangeimf <- range(try$imf)
plot(xt2, type = "l", xlab="", ylab="", main = "evenodd")
for(i in 1:try$nimf) {
  plot(tt2, try$imf[,i], type="l", xlab="", ylab="", ylim=rangeimf,
       main=paste(i, "-th IMF", sep="")); abline(h=0)
}
plot(tt2, try$residue, xlab="", ylab="", main="residue", type="l", axes=FALSE);
box()
par(mfrow = c(1,1))