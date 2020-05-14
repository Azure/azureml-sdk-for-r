context("experiment")
source("utils.R")

test_that("create, submit experiment, run in default amlcompute,
          get run metrics", {
  skip_if_no_subscription()
  experiment_name <- "estimator_run"
  
  ws <- existing_ws
  
  # create experiment
  exp <- experiment(ws, experiment_name)
  expect_equal(exp$name, experiment_name)
  
  # start a remote job and get the run, wait for it to finish
  tmp_dir_name <- file.path(tempdir(), "tmp_dir")
  script_name <- "train_dummy.R"
  dir.create(tmp_dir_name)
  file.copy(script_name, tmp_dir_name)

  ds <- get_default_datastore(ws)

  r_env <- r_environment("r-env",
                         cran_packages = list(cran_package("dplyr"),
                                              cran_package("ggplot2")))

  est <- estimator(tmp_dir_name,
                   compute_target = existing_compute$name, 
                   entry_script = script_name, 
                   script_params = list("data_folder" = ds$as_mount()),
                   environment = r_env)
  
  run <- submit_experiment(exp, est)
  wait_for_run_completion(run, show_output = TRUE)

  run <- get_run(exp, run$id)
  metrics <- get_run_metrics(run)
  expect_equal(metrics$test_metric, 0.5)
  
  keyvault <- ws$get_default_keyvault()
  keyvault$set_secret(name="mysecret", value = "temp_secret")
  secrets <- get_secrets_from_run(run, list("mysecret"))
  expect_equal(any(secrets == "temp_secret"), TRUE)

  # upload files to the run
  upload_files_to_run(list("dummy_data"), list("dummy_data.txt"), run = run)
  upload_folder_to_run("folder1", tmp_dir_name, run = run)
  files <- get_run_file_names(run)
  expect_true("dummy_data" %in% files)
  expect_true("folder1/train_dummy.R" %in% files)

  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})

test_that("submit experiment through a custom environment,
          add child run with config", {
  skip_if_no_subscription()
  ws <- existing_ws
  
  # start a remote job and get the run, wait for it to finish
  tmp_dir_name <- file.path(tempdir(), "tmp_dir")
  script_name <- "train_dummy.R"
  dir.create(tmp_dir_name)
  file.copy(script_name, tmp_dir_name)
  
  env <- r_environment("myenv", cran_packages = list(cran_package("dplyr"),
                                                     cran_package("ggplot2")))

  est <- estimator(tmp_dir_name,
                   compute_target = existing_compute$name, 
                   entry_script = script_name,
                   environment = env)
  
  exp <- experiment(ws, "estimator_run")
  run <- submit_experiment(exp, est)

  wait_for_run_completion(run, show_output = TRUE)
  expect_equal(run$status, "Completed")
  
  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})

test_that("Create an interactive run, log metrics locally.", {
  skip_if_no_subscription()
  ws <- existing_ws
  exp <- experiment(ws, "interactive_logging")

  run <- start_logging_run(exp)
  expect_true(run$status %in% c("NotStarted", "Running"))

  # log metrics
  log_metric_to_run("test_metric", 0.5, run = run)
  log_list_to_run("test_list", c(1, 2, 3), run = run)
  log_row_to_run("test_row", x = 1, y = 2, run = run)
  predict_json <- '{
                      "schema_type": "predictions",
                      "schema_version": "v1",
                      "data": {
                          "bin_averages": [0.25, 0.75],
                          "bin_errors": [0.013, 0.042],
                          "bin_counts": [56, 34],
                          "bin_edges": [0.0, 0.5, 1.0]
                      }
                  }'
  log_predictions_to_run("test_predictions", predict_json, run = run)
  log_image_to_run("myplot", plot = ggplot2::ggplot(), run = run)
  
  # complete the run
  complete_run(run)
  wait_for_run_completion(run, show_output = TRUE)
  expect_equal(run$status, "Completed")

  # get metrics
  metrics <- get_run_metrics(run)
  
  expect_equal(metrics$test_metric, 0.5)
  
  expected_list <- c(1, 2, 3)
  expect_equal(length(setdiff(metrics$test_list, expected_list)), 0)

  expected_row <- list(x = 1, y = 2)
  expect_equal(length(setdiff(metrics$test_row, expected_row)), 0)

  expect(startsWith(metrics$test_predictions, "aml://artifactId") &&
         endsWith(metrics$test_predictions, "test_predictions"),
         "invalid predictions uri returned")
  
  files <- get_run_file_names(run)
  image_found <- grep("myplot", files)
  expect_true(length(image_found) > 0)
})

test_that("Create and submit child runs", {
  skip('skip')
  ws <- existing_ws

  exp <- experiment(ws, "estimator_run")
  run <- start_logging_run(exp)

  # create new child runs
  extra_child <- create_child_run(run, run_id = "my_new_child_2")
  expect_equal(extra_child$id, "my_new_child_2")

  extra_children <- create_child_runs(run, count = 3L)
  expect_equal(length(extra_children), 3)

  child_runs <- get_child_runs(run)
  expect_equal(length(child_runs), 5)

  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})
