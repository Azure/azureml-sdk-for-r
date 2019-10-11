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

  est <- estimator(tmp_dir_name,
                   compute_target = existing_compute$name, 
                   entry_script = script_name, 
                   script_params = list("data_folder" = ds$as_mount()),
                   cran_packages = c("dplyr", "ggplot2"))
  
  run <- submit_experiment(exp, est)
  wait_for_run_completion(run, show_output = TRUE)
  
  run <- get_run(exp, run$id)
  metrics <- get_run_metrics(run)
  
  expect_equal(metrics$test_metric, 0.5)
  
  expected_list <- c(1, 2, 3)
  expect_equal(length(setdiff(metrics$test_list, expected_list)), 0)

  expected_row <- list(x = 1, y = 2)
  expect_equal(length(setdiff(metrics$test_row, expected_row)), 0)

  expect(startsWith(metrics$test_predictions, "aml://artifactId") &&
         endsWith(metrics$test_predictions, "test_predictions"),
         "invalid predictions uri returned")

  upload_files_to_run(list("dummy_data"), list("dummy_data.txt"), run = run)
  upload_folder_to_run("folder1", tmp_dir_name, run = run)
  files <- get_run_file_names(run)
  expect_true("dummy_data" %in% files)
  expect_true("folder1/train_dummy.R" %in% files)
  
  workspaces <- list_workspaces(subscription_id)
  workspaces
  get_workspace_details(ws)
  x <- plyr::ldply(get_workspace_details(ws), data.frame)
  
  get_run_details(run)
  
  # tear down resources
  unlink(tmp_dir_name, recursive = TRUE)
})

test_that("submit experiment through a custom environment", {
  ws <- existing_ws
  
  # start a remote job and get the run, wait for it to finish
  tmp_dir_name <- "tmp_dir"
  script_name <- "train_dummy.R"
  dir.create(tmp_dir_name)
  file.copy(script_name, tmp_dir_name)
  
  env <- r_environment("myenv", cran_packages = c("dplyr", "ggplot2"))

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