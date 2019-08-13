# run setup.R prior to running this script
library("azureml")

ws <- load_workspace_from_config(".")
ds <- get_default_datastore(ws)

target_path <- "irisdata"
upload_files_to_azure_datastore(ds, list("./iris.csv"),
                                target_path = target_path, overwrite = TRUE)

data_reference <- create_data_reference(ds, path_on_datastore = target_path)
data_references <- list(data_reference)

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target))
{
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws, cluster_name = cluster_name, vm_size = vm_size, max_nodes = 1)
}

# define script run config
arguments <- list("--data_folder", get_data_reference_path_in_compute(data_reference))

src <- create_script_run_config(source_directory = ".", script="train.R", arguments = arguments,
                                target = compute_target, data_references = data_references)

experiment_name <- "train-r-script-on-remote-amlcompute"
exp <- get_or_create_experiment(ws, experiment_name)

run <- submit_experiment(src, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)

# delete cluster
delete_aml_compute(compute_target)
