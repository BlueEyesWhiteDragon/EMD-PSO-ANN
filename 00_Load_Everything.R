### 载入需要的包
library("zoo")
library("forecast")
library("fUnitRoots")
library("EMD")
library("pso")

### 载入自定义函数
source(".//EMD-PSO-ANN//SDF-calError.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-fitness.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-fitnessPSO.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList1.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList1A.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList1B.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList1C.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdList1D.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo1.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo1A.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo1B.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo1C.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getEmdPsoRbfInfo1D.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getImfPredResult.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getPredictionResult.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getPsoRbfInfo.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getRbfInfo.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-optRbfStructure.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-reshapeData.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-segmentData.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-setHeightByNType.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-isWhiteNoise.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-isStationary.R", encoding = "utf-8")
source(".//EMD-PSO-ANN//SDF-getArimaInfo.R", encoding = "utf-8")

### 导入数据
FILE_PATH = "G://00JGW//PostGraduate//00毕业论文//03处理后的数据//www.tianqihoubao.com//"
FILE_NAME = "整合后数据.csv"
FILE = paste(FILE_PATH, FILE_NAME, sep = '')
DATA = read.table(FILE, header = T, sep = ',')

### 提取各列
year = as.matrix(DATA[1]) # 年
month = as.matrix(DATA[2]) # 月
day = as.matrix(DATA[3]) # 日
maxTemperatureByDay = as.matrix(DATA[4]) # 每日最高温度
minTemperatureByDay = as.matrix(DATA[5]) # 每日最低温度

### 绘制每日最高温度曲线图
# par(mfrow = c(1,1))
# 生成横轴序列
# t = seq(as.Date("2011-01-01"), length = nData, by = "day")
# 转为时间序列
# maxT = zoo(maxTemperatureByDay, t)
# plot(maxT)
