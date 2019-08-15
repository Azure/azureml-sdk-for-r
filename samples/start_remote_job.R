# This example runs an R script on an existing compute.
# Assumes that the script setup.R has been run prior to this example being run.
devtools::install_github('https://github.com/Azure/azureml-sdk-for-r')

library("azureml")

# Workspace subscription, name etc.
ws <- load_workspace_from_config(".")

ds <- get_default_datastore(ws)

target_path <- "irisdata"
upload_files_to_azure_datastore(ds, list("./iris.csv"),
                                target_path = target_path, overwrite = TRUE)

# define estimator
data_reference <- create_data_reference(ds, path_on_datastore = target_path)
path <- get_data_reference_path_in_compute(data_reference)

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target))
{
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws, cluster_name = cluster_name,
                                       vm_size = vm_size, max_nodes = 1)
}

est <- create_estimator(source_directory = ".", entry_script = "train.R",
                        script_params = list("--data_folder" = path),
                        compute_target = compute_target,
                        inputs = list(data_reference))

experiment_name <- "train-r-script-on-remote-vm"
exp <- get_or_create_experiment(ws, experiment_name)

run <- submit_experiment(est, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
