context("estimator")

test_that("estimator",
{
    ws <- existing_ws
    # start a remote job and get the run, wait for it to finish
    tmp_dir_name <- "tmp_dir"
    script_name <- "train_dummy.R"
    dir.create(tmp_dir_name)
    file.copy(script_name, tmp_dir_name)

    ds <- get_default_datastore(ws)

    estimator <- estimator(tmp_dir_name, compute_target = existing_compute$name, 
                           entry_script = script_name, 
                           script_params = list("data_folder" = ds$as_mount()),
                           cran_packages = c("ggplot2", "dplyr"))
    
    experiment <- experiment(ws, "estimator_run")
    run <- submit_experiment(estimator, experiment)
    wait_for_run_completion(run, show_output = TRUE)
    metrics <- get_run_metrics(run)
    expected_metrics <- list("test_metric" = 0)
    expect_equal(length(setdiff(metrics, expected_metrics)), 0)
    unlink(tmp_dir_name, recursive = TRUE)
})