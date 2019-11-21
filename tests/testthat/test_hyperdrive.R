context("hyperdrive")
source("utils.R")

test_that("create hyperdrive config, launch runs, get run metrics", {
  skip_if_no_subscription()
  experiment_name <- "test_experiment"
  
  ws <- existing_ws
  
  # create experiment
  exp <- experiment(ws, experiment_name)
  expect_equal(exp$name, experiment_name)
  
  # get existing experiment
  exp <- experiment(ws, experiment_name)
  expect_equal(exp$name, experiment_name)
  
  # start a remote job and get the run, wait for it to finish
  tmp_dir_name <- file.path(tempdir(), "tmp_dir")
  script_name <- "train_hyperdrive_dummy.R"
  
  dir.create(tmp_dir_name)
  file.copy(script_name, tmp_dir_name)
  
  script_params <- list(number_1 = 3, number_2 = 2)
  est <- estimator(source_directory = tmp_dir_name,
                   entry_script = script_name,
                   compute_target = existing_compute$name,
                   script_params = script_params)
  
  # define sampling and policy for hyperparameter tuning
  sampling <- 
    grid_parameter_sampling(list(number_1 = choice(c(3, 6)),
                                 number_2 = choice(c(2, 5))))
  policy <- median_stopping_policy()
  hyperdrive_config <- 
    hyperdrive_config(sampling, "Sum",
                      primary_metric_goal("MAXIMIZE"),
                      4,
                      policy = policy,
                      estimator = est)
  # submit hyperdrive run
  hyperdrive_run <- submit_experiment(exp, hyperdrive_config)
  wait_for_run_completion(hyperdrive_run, show_output = TRUE)
  
  child_runs <- 
    get_child_runs_sorted_by_primary_metric(hyperdrive_run)
  expected_best_run <- toString(child_runs[[1]][1])
  expect_equal(length(child_runs), 5)
  
  child_run_metrics <- get_child_run_metrics(hyperdrive_run)
  expect_equal(length(child_run_metrics), 4)
  
  # find best-performing run
  best_run <- get_best_run_by_primary_metric(hyperdrive_run)
  
  expect_equal(expected_best_run, best_run$id)
  
  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})