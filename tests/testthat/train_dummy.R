# check if ggplot2 and dplyr are already installed
library("ggplot2")
library("dplyr")

library(azuremlsdk)

log_metric_to_run("test_metric", 0.5)
