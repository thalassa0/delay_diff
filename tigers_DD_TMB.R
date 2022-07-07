#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# Tigers
# author: Fay Helidoniotis
# code is indexed: dashes '----' are used to identify headings
# code that is indexed is preceded by '## ---- ' to make it a code chunk that latex can read in
# ctl shift o  (letter o) to get the index of the headings to appear to the right

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# PART1Preparation----

# Warnings: 
# when running standardisation model in using glm etc make sure the dataset is not a tibble from tidyverse
# always include na.rm = TRUE when using the sum function  
# when reading a file using read.csv  include , header = TRUE)
# when saving file using write.csv, include , row.names = FALSE  and na="" (value of NA as blank)
# when running RODBC package R needs to be in 64 bit
# the 'tails' of the CPUE trends are known to go up in the last years of data: a retrospective analysis will show this

# Example DD_TMB ----
# had to run the following lines twice 1st time didn't work
install.packages("remotes")  #reststart R enter yes
remotes::install_github("tcarruth/MSEtool") 
install.packages("DD_TMB")
source("C:/A/TMB/DD_TMB.r")

library(MSEtool)
library(TMB)
library(openxlsx)
library(RODBC)
library(tidyverse)




snapper <- read.data.file(DLMtool::Red_snapper)
?read.data.file
class?Data

DataInit("MyData")
DLMDataDir()


res <- DD_TMB(Data = DLMtool::Red_snapper)
str(DLMtool::Red_snapper)
DLMtool::Red_snapper@CV_AddInd

#lets see wat example looks like
plot(as.vector(DLMtool::Red_snapper@Ind), type='l') # looks weird

?MSEtool
DLMtool::userguide()
?DLMtool
?Data-class
browseVignettes("MSEtool")
?template
?DD_TMB



# Provide starting values
start <- list(R0 = 1, h = 0.95)
res <- DD_TMB(Data = DLMtool::Red_snapper, start = start)

summary(res@SD) # Parameter estimates

plot(res)



https://cran.r-project.org/web/packages/MSEtool/vignettes/Delay_difference.html


?DD_TMB  ('then click on data-class')
#Required data for DD_TMB 
#DD_TMB: Cat, Ind, Mort, L50, vbK, vbLinf, vbt0, wla, wlb, MaxAge
#DD_SS: Cat, Ind, Mort, L50, vbK, vbLinf, vbt0, wla, wlb, MaxAge
# Cat: Total annual catches. Matrix of nsim rows and nyears columns. Non-negative real numbers
# Ind: Relative total abundance index. Matrix of nsim rows and nyears columns. Non-negative real numbers
# Mort: Natural mortality rate. Vector nsim long. Positive real numbers
# L50: Length at 50 percent maturity (cm)
# vbK: vB k
# vbLin: vbLinf
# vbt0: Coefficient of variation in age at length zero. Vector nsim long. Positive real numbers
# wla: Weight-Length parameter alpha. Vector nsim long. Positive real numbers
# wlb: Weight-Length parameter beta. Vector nsim long. Positive real numbers

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#START

#dirpath <- "C:/A/DelayDiff/"
dirpath <- "C:/A/trawl/Tiger_endeavour/"

# get data ----

#catch
prawn_c <- read.csv(paste0(dirpath,'tigerscentralFP.txt'), header = TRUE)
prawn_n <- read.csv(paste0(dirpath,'tigersnorthFP.txt'), header = TRUE)
#annual
prawn_n_y <- tapply(prawn_n$tiger/1000,prawn_n$year, sum, na.rm = TRUE)
prawn_n_y <- as.vector(prawn_n_y)

prawn_n_m <- tapply(prawn_n$tiger/1000,list(prawn_n$year,prawn_n$month), sum, na.rm = TRUE)
prawn_n_m <- as.data.frame(prawn_n_m)
prawn_n_m_long <- prawn_n_m  %>%
  pivot_longer(cols = c(1:12), names_to = "month")
dim(prawn_n_m_long)
prawn_n_m_long[2]

#cpue
channel1 <- odbcConnectExcel2007(paste0(dirpath,"Workbook.xlsx"))
sqlTables(channel1)
cpue_n_m <- sqlFetch(channel1, "north", colnames = F) 		#selecting whole table
close(channel1)

cpue_n_m_long <- cpue_n_m  %>%
  pivot_longer(cols = c(2:13), names_to = "month")

cpue_n_m_long <-as.data.frame(cpue_n_m_long)
dim(cpue_n_m_long)
cpue_n_m_long[3]

# cpue_n <- read.csv(paste0(dirpath,"prawncpue_north.csv"))
# cpue_n <- cpue_n[,2] 
# cpue_n[1] <- 0
# plot(cpue_n, type = 'l')

as.matrix(as.vector(prawn_n_m_long[,2]))

#--create data file for TMB
tigerprawns<-new('Data')
#tigerprawns<-Red_snapper
str(tigerprawns)
tigerprawns@Name <- 'tigerprawns'
#tigerprawns@Cat <- t(as.matrix(prawn_n_y))  #length(t(as.matrix(prawn_n_y)))
tigerprawns@Cat <- t(as.matrix(as.vector(prawn_n_m_long[,2])))  #length(t(as.matrix(prawn_n_y)))
tigerprawns@CV_Cat <- t(matrix(rep(0.2,384)))
#tigerprawns@Ind <- t(as.matrix(cpue_n))  #length(t(as.matrix(cpue_n)))
tigerprawns@Ind <- t(matrix(cpue_n_m_long[,3]))  #length(t(as.matrix(cpue_n)))
tigerprawns@CV_Ind <- t(matrix(rep(0.2,384)))
#tigerprawns@Mort <- 0.85
tigerprawns@Mort <- 0.18
tigerprawns@CV_Mort <- 0.2
tigerprawns@L50 <- 3.5  #cm
tigerprawns@CV_L50 <- 0.1
tigerprawns@vbK <- 0.164
tigerprawns@CV_vbK <- 0.008025013
tigerprawns@vbLinf <- 6 #cm
tigerprawns@CV_vbLinf <- 0.0003246147
tigerprawns@vbt0 <- -0.395  #default from red_snapper
tigerprawns@CV_vbt0 <- 0.007772152
tigerprawns@wla <- 0.0026
tigerprawns@CV_wla <- 0.1
tigerprawns@wlb <- 2.67
tigerprawns@CV_wlb <- 0.1
tigerprawns@MaxAge <- 24  #had to cheat and made it 3 years instead of 2 years otherwise it wouldn't work
tigerprawns@LHYear <- 384
tigerprawns@Units <- 'tonnes'
tigerprawns@MPeff <- 1
tigerprawns@steep <- 0.4
tigerprawns@CV_steep <- 0.1
tigerprawns@Year <- 1:384  #length(1988:2019)

tigerprawns <- as.data.frame(tigerprawns)

write.csv(tigerprawns, paste0(dirpath,"tigerprawns.csv"))

write.xlsx(tigerprawns, paste0(dirpath,"tigerprawns.csv"))




start <- list(R0 = 0.1, h = 0.07)
res <- DD_TMB(Data = tigerprawns, start = start)

summary(res@SD) # Parameter estimates
summary(res)

# Sumamrize ALL
print(summary(res))


plot(res)

summary(tigerprawns, wait=TRUE, rmd=TRUE)






