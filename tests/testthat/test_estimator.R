context("estimator")

test_that("create, submit experiment, run in default amlcompute,
          get run metrics", {
  experiment_name <- "estimator_run"
  
  ws <- existing_ws
  
  # create experiment
  exp <- experiment(ws, experiment_name)
  expect_equal(exp$name, experiment_name)
  
  # start a remote job and get the run, wait for it to finish
  tmp_dir_name <- "tmp_dir"
  script_name <- "train_dummy.R"
  dir.create(tmp_dir_name)
  file.copy(script_name, tmp_dir_name)

  ds <- get_default_datastore(ws)

  estimator <- estimator(tmp_dir_name,
                         compute_target = existing_compute$name, 
                         entry_script = script_name, 
                         script_params = list("data_folder" = ds$as_mount()),
                         cran_packages = c("ggplot2", "dplyr"))
  
  run <- submit_experiment(exp, estimator)
  wait_for_run_completion(run, show_output = TRUE)
  
  run <- get_run(exp, run$id)
  metrics <- get_run_metrics(run)
  
  expected_metrics <- list("test_metric" = 0.5)
  expect_equal(length(setdiff(metrics, expected_metrics)), 0)
  
  # Uncomment once base image upgrades the sdk
  # expected_list <- c(1, 2, 3)
  # expect_equal(length(setdiff(metrics$test_list, expected_list)), 0)

  # expected_row <- list(x = 1, y = 2)
  # expect_equal(length(setdiff(metrics$test_row, expected_row)), 0)

  # expect(startsWith(metrics$test_predictions, "aml://artifactId") &&
  #       endsWith(metrics$test_predictions, "test_predictions"),
  #       "invalid predictions uri returned")

  files <- get_run_file_names(run)
  expect(length(files) > 0, "No file is generated from the run")
  
  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})