# run setup.R prior to running this script
library("azureml")

ws <- load_workspace_from_config("~/azureml-sdk-for-r/samples/.azureml/config.json")

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target))
{
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws, cluster_name = cluster_name,
                                       vm_size = vm_size, max_nodes = 1)
}
wait_for_compute(compute_target)

# define estimator
est <- create_estimator(source_directory = "./tensorflow", entry_script = "tf_mnist.R",
                        compute_target = compute_target, cran_packages = c("tensorflow"))

experiment_name <- "train-tf-script-on-remote-amlcompute"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(est, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# delete cluster
delete_aml_compute(compute_target)
