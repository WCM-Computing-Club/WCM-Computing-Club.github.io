
library(devtools)
library(roxygen2)

document()

setwd("..")

install("JihuiLee")

library("JihuiLee")

?cool_summary
?cute_scatterplot


devtools::install_github("jihuilee/JihuiLee", force = TRUE)
