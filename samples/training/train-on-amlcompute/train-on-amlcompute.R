# run setup.R to setup workspace for the first time
# set working directory to current file location prior to running this script
library("azureml")

ws <- load_workspace_from_config()

ds <- get_default_datastore(ws)

# upload iris data to the datastore
target_path <- "irisdata"
upload_files_to_datastore(ds,
                          list("./iris.csv"),
                          target_path = target_path,
                          overwrite = TRUE)

# create aml compute
cluster_name <- "gpu-std-nc6"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       max_nodes = 1)
}

# define estimator
est <- estimator(source_directory = ".",
                 entry_script = "train.R",
                 script_params = list("--data_folder" = ds$path(target_path)),
                 compute_target = compute_target,
                 cran_packages = c("caret", "optparse", "e1071"))

run_config <- est$run_config
run_config$environment$python$conda_dependencies$set_python_version("3.6.9")
run_config$environment$python$conda_dependencies$add_channel("r")
#run_config$environment$python$conda_dependencies$add_conda_package("r-essentials")
#run_config$environment$python$conda_dependencies$add_conda_package("r-remotes")
run_config$environment$python$user_managed_dependencies <- FALSE
run_config$environment$docker$base_image <- "ninhu/r-base:cpu"
run_config$environment$docker$base_image_registry$address <- NULL


experiment_name <- "train-r-script-on-amlcompute"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(exp, est)
view_run_details(run)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# delete cluster
delete_compute(compute_target)
