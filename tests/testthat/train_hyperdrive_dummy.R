library(azuremlsdk)

args <- commandArgs(trailingOnly = TRUE)
number_1 <- args[2]
log_metric_to_run("First Number", number_1)
number_2 <- args[4]
log_metric_to_run("Second Number", number_2)

sum <- as.numeric(number_1) + as.numeric(number_2)
log_metric_to_run("Sum", sum)