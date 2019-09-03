library(azureml)

args <- commandArgs()

number_1 <- args[2]
log_metric_to_run("First Number", number_1, get_current_run())
number_2 <- args[4]
log_metric_to_run("Second Number", number_2, get_current_run())

sum <- as.numeric(number_1) + as.numeric(number_2)

cat(sum)
log_metric_to_run("Sum", sum, get_current_run())