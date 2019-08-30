# run setup.R prior to running this script
library(azureml)

ws <- load_workspace_from_config(".")

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
script_params <- list(batch_size = 32, epochs = 200,
                      lr = 0.0001, decay = 0.000001)

est <- create_estimator(source_directory = ".", entry_script = "cifar10_cnn.R",
                        compute_target = compute_target, script_params = script_params,
                        cran_packages = c("keras"))

experiment_name <- "hyperdrive-testing"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(est, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# define sampling and policy for hyperparameter tuning
sampling <- random_parameter_sampling(list(batch_size <- choice(c(16, 32, 64)),
                                           epochs = choice(c(200, 350, 500)),
                                           lr = normal(0.0001, 0.005),
                                           decay = uniform(0.0000001, 0.00001)))

policy <- bandit_policy(slack_factor = 0.15)
hyperdrive_config <- create_hyperdrive_config(sampling, "Loss", primary_metric_goal("MINIMIZE"),
                                              4, policy = policy, estimator = est)

# submit hyperdrive run
hyperdrive_run <- submit_experiment(hyperdrive_config, exp)
wait_for_run_completion(hyperdrive_run, show_output = TRUE)

# find best-performing run
best_run <- get_best_run_by_primary_metric(hyperdrive_run)
metrics <- get_run_metrics(best_run)
metrics

# delete cluster
delete_aml_compute(compute_target)
