# This example creates a remote cluster and starts a job on the cluster
devtools::install_github('https://github.com/Azure/azureml-sdk-for-r')

library("azureml")

ws <- load_workspace_from_config(".")

ds <- get_default_datastore(ws)
target_path <- "irisdata"
upload_files_to_azure_datastore(ds, list("./iris.csv"),
                                target_path = target_path, overwrite = TRUE)

data_reference <- create_data_reference(ds, path_on_datastore = target_path, overwrite = TRUE)
path <- get_data_reference_path_in_compute(data_reference)

estimator <- create_estimator(".", compute_target = "rcluster", entry_script = "train.R",
    script_params = list("--data_folder" = path), inputs = list(data_reference)
)

experiment_name <- "train-r-script-on-remote-vm"
exp <- get_or_create_experiment(ws, experiment_name)

run <- submit_experiment(estimator, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
