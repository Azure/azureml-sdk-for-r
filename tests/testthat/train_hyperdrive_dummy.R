library(azureml)

run <- get_current_run()

args <- commandArgs()
number_1 <- as.numeric(args[2])
log_metric_to_run("First Number", number_1, run)
number_2 <- as.numeric(args[4])
log_metric_to_run("Second Number", number_2, run)

sum <- number_1 + number_2
log_metric_to_run("Sum", sum, run)