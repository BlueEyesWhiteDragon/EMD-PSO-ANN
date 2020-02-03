nData = nrow(maxTemperatureByDay)
nUse = 360
nPredict = 30

obsSeries = as.vector(maxTemperatureByDay[(nData - nPredict + 1):nData, ])

predRbfSeries = as.vector(infoRbf_360_30_3_4_1$testPredMat)

predPsoRbfSeries = as.vector(infoPsoRbf_360_30_3_4_1$testPredMatPSO)

predEmdPsoRbfSeries = as.vector(infoEmdPsoRbf1A_360_30_3_4_1$testPredMat)

par(mfrow = c(1, 1), mar = c(3, 3, 1, 1), mgp = c(1.5, 0.5, 0))

plot(obsSeries, type = "b", lwd = 2, pch = 16, main = NULL, ylab = "温度(℃)", xlab = "天数(天)")

lines(predRbfSeries, type = "b", lwd = 2, pch = 1, lty = 5)

lines(predPsoRbfSeries, type = "b", lwd = 2, pch = 2, lty = 3)

lines(predEmdPsoRbfSeries, type = "b", lwd = 2, pch = 5, lty = 1)

### PSO-RBF vs EMD-PSO-RBF
par(mfrow = c(1, 1), mar = c(3, 3, 1, 1), mgp = c(1.5, 0.5, 0))
plot(obsSeries, type = "b", lwd = 2, pch = 16, main = NULL, ylab = "温度(℃)", xlab = "天数(天)")
lines(predPsoRbfSeries, type = "b", lwd = 2, pch = 2, lty = 3)
lines(predEmdPsoRbfSeries, type = "b", lwd = 2, pch = 5, lty = 6)

### 绘制PSO“适应度-迭代次数曲线”
par(mfrow = c(1, 1), mar = c(3, 3, 1, 1), mgp = c(1.5, 0.5, 0))
plot(infoPsoRbf_360_30_3_4_1$psoResult$stats$error, type = "b", ylab = "适应度", xlab = "迭代次数", xaxt = "n")
at = as.vector(5*seq(0,6))
labels = as.vector(5*at)
axis(side = 1, at = at, labels = labels)

### 绘制训练序列的emd分解图
emdList1A = getEmdList1A(maxTemperatureByDay, nPredict, nUse)
try = emdList1A$emdList[[1]]

par(mfrow=c(try$nimf+1, 1), mar=c(1,3,0.5,0.5))
rangeimf <- range(try$imf)
for(i in 1:try$nimf) {
  plot(try$imf[,i], type="l", xlab="", ylab=paste(i, "-th IMF", sep=""), ylim=rangeimf, main = NULL, lwd = 2); abline(h=0)
}
par(mar = c(1.5,3,0.5,0.5))
plot(try$residue, xlab="", ylab="residue", main=NULL, type="l", lwd = 2)
box()
