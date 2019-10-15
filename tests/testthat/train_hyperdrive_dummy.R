library(azuremlsdk)

run <- get_current_run()

args <- commandArgs(trailingOnly = TRUE)
number_1 <- args[2]
log_metric_to_run("First Number", number_1, run)
number_2 <- args[4]
log_metric_to_run("Second Number", number_2, run)

sum <- as.numeric(number_1) + as.numeric(number_2)
log_metric_to_run("Sum", sum, run)