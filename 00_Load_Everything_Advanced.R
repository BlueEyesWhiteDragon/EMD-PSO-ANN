### 载入需要的包
library("zoo")
library("forecast")
library("fUnitRoots")
library("EMD")
library("pso")

### 测试一下乱码

### 研究一下高阶版加载文件
### 自定义函数文件夹位置
FOLDER_PATH = paste(getwd(), "/SDF", sep = "")

### 获得所有自定义函数的绝对路径
sdfVec = list.files(path = FOLDER_PATH, full.names = T, pattern = "*.[R|r]$")

### 载入自定义函数
for(i in 1:length(sdfVec)) {
  source(sdfVec[i], encoding = "utf-8")
}

### 导入数据
FILE_PATH = paste(getwd(), "/DATA/", sep = "")
FILE_NAME = "整合后数据.csv"
FILE = paste(FILE_PATH, FILE_NAME, sep = '')
DATA = read.table(FILE, header = T, sep = ',')

### 提取各列
year = as.matrix(DATA[1])
month = as.matrix(DATA[2])
day = as.matrix(DATA[3])
maxTemperatureByDay = as.matrix(DATA[4])
minTemperatureByDay = as.matrix(DATA[5])

### 绘制每日最高温度曲线图
# par(mfrow = c(1,1))
# 生成横轴序列
# t = seq(as.Date("2011-01-01"), length = nData, by = "day")
# 转为时间序列
# maxT = zoo(maxTemperatureByDay, t)
# plot(maxT)