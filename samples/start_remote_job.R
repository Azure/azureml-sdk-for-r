# This example runs an R script on an existing compute.
# Assumes that the script setup.R has been run prior to this example being run.
devtools::install_github('https://github.com/Azure/azureml-sdk-for-r')

library("azureml")

cluster_name <- Sys.getenv('CLUSTER_NAME', unset = '<CLUSTER_NAME>')
# Workspace subscription, name etc.
ws <- load_workspace_from_config(".")

ds <- get_default_datastore(ws)

target_path <- "irisdata"
upload_files_to_azure_datastore(ds, list("./iris.csv"),
                                target_path = target_path, overwrite = TRUE)

# define script run config
data_reference <- create_data_reference(ds, path_on_datastore = target_path)
arguments <- list("--data_folder", get_data_reference_path_in_compute(data_reference))
data_references <- list(data_reference)

src <- create_script_run_config(source_directory = ".", script = "train.R",
                                arguments = arguments, target = cluster_name,
                                data_references = data_references)

experiment_name <- "train-r-script-on-remote-vm"
exp <- get_or_create_experiment(ws, experiment_name)

run <- submit_experiment(src, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
