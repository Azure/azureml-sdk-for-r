# run setup.R prior to running this script
library("azureml")

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
wait_for_compute(compute_target)

# define estimator
script_params <- list(step = 0.01, num_octave = 3, octave_scale = 1.4, iterations = 20,
                      max_loss = 10)

est <- create_estimator(source_directory = ".", entry_script = "deep_dream.R",
                        compute_target = compute_target, script_params = script_params,
                        cran_packages = c("keras"))

experiment_name <- "hyperparameter-tuning-on-remote-amlcompute"
exp <- experiment(ws, experiment_name)

run <- submit_experiment(est, exp)
wait_for_run_completion(run, show_output = TRUE)

metrics <- get_run_metrics(run)
metrics

# define sampling and policy for hyperparameter tuning
sampling <- random_parameter_sampling(list(step = normal(0.05, 0.01, 0.02),
                                           num_octave = choice(2, 3, 5),
                                           octave_scale = loguniform(0.4, 1.4, 2.4),
                                           iterations = choice(10, 20, 30),
                                           max_loss = choice(5, 10, 5)))
policy <- bandit_policy(slack_factor = 0.15)
hyperdrive_config <- create_hyperdrive_config(sampling, "Loss", "MINIMIZE", 10,
                                              policy = policy, estimator = est)

# submit hyperdrive run
hyperdrive_run <- submit_experiment(config = hyperdrive_config, exp)
wait_for_run_completion(hyperdrive_run, show_output = TRUE)

# find best-performing run
best_run <- get_best_run_by_primary_metric(hyperdrive_run)
metrics <- get_run_metrics(best_run)
metrics

# delete cluster
delete_aml_compute(compute_target)
