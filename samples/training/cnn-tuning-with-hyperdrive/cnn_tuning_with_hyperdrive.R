# run setup.R to setup workspace for the first time
# set working directory to current file location prior to running this script
library(azureml)

ws <- load_workspace_from_config()

# create aml compute
cluster_name <- "rcluster"
compute_target <- get_compute(ws, cluster_name = cluster_name)
if (is.null(compute_target))
{
  vm_size <- "STANDARD_D2_V2"
  compute_target <- create_aml_compute(workspace = ws, cluster_name = cluster_name,
                                       vm_size = vm_size, max_nodes = 1)
}
wait_for_provisioning_completion(compute_target)

# define estimator
script_params <- list(batch_size = 32, epochs = 200,
                      lr = 0.0001, decay = 1e-6)

est <- estimator(source_directory = ".", entry_script = "cifar10_cnn.R",
                 compute_target = compute_target, script_params = script_params,
                 cran_packages = c("keras"))

experiment_name <- "hyperdrive-cifar10"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(exp, est)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# define sampling and policy for hyperparameter tuning
sampling <- random_parameter_sampling(list(batch_size = choice(c(16, 32, 64)),
                                           epochs = choice(c(200, 350, 500)),
                                           lr = normal(0.0001, 0.005),
                                           decay = uniform(1e-6, 3e-6)))

policy <- bandit_policy(slack_factor = 0.15)
hyperdrive_config <- hyperdrive_config(sampling, "Loss", primary_metric_goal("MINIMIZE"),
                                              4, policy = policy, estimator = est)

# submit hyperdrive run
hyperdrive_run <- submit_experiment(exp, hyperdrive_config)
wait_for_run_completion(hyperdrive_run, show_output = TRUE)

# find best-performing run
best_run <- get_best_run_by_primary_metric(hyperdrive_run)
metrics <- get_run_metrics(best_run)
metrics

# delete cluster
delete_compute(compute_target)
