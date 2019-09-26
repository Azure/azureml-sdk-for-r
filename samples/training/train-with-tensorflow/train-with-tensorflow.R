# run setup.R to setup workspace for the first time
# set working directory to current file location prior to running this script
library("azureml")

ws <- load_workspace_from_config()

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target)) {
  vm_size <- "STANDARD_NC6"
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       max_nodes = 1)
}
wait_for_provisioning_completion(compute_target)

# define estimator
est <- estimator(source_directory = ".",
                 entry_script = "tf_mnist.R",
                 compute_target = compute_target,
                 cran_packages = c("tensorflow"),
                 use_gpu = TRUE)

experiment_name <- "train-tf-script-on-amlcompute"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(exp, est)
view_run_details(run)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# delete cluster
delete_compute(compute_target)
