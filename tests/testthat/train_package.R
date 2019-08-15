# check if ggplot is already installed
library("ggplot")

library(azureml)

log_metric_to_run("test_metric", 0, get_current_run())