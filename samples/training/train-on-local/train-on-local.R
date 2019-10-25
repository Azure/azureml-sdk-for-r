# run setup.R to setup workspace for the first time
# set working directory to current file location prior to running this script
library("azuremlsdk")

ws <- load_workspace_from_config()

# define estimator
est <- estimator(source_directory = ".",
                 entry_script = "train.R",
                 compute_target = "local",
                 cran_packages = c("caret"))

# initialize experiment
experiment_name <- "train-r-script-on-local"
exp <- experiment(ws, experiment_name)

# start run and display the run details
run <- submit_experiment(exp, est)
view_run_details(run)
wait_for_run_completion(run, show_output = TRUE)

# get the run metrics
metrics <- get_run_metrics(run)
metrics

# delete cluster
delete_compute(compute_target)
