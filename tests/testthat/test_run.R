context("run")

test_that("create, submit experiment, run in default amlcompute, get run metrics",
{
    experiment_name <- "test_experiment"

    ws <- existing_ws

    # get offline run
    run <- get_current_run()

    # create experiment
    exp <- experiment(ws, experiment_name)
    expect_equal(exp$name, experiment_name)

    # get existing experiment
    exp <- experiment(ws, experiment_name)
    expect_equal(exp$name, experiment_name)

    # start a remote job and get the run, wait for it to finish
    tmp_dir_name <- "tmp_dir"
    script_name <- "train_empty.R"

    dir.create(tmp_dir_name)
    file.copy(script_name, tmp_dir_name)

    est <- estimator(source_directory = tmp_dir_name, entry_script = script_name,
                     compute_target = existing_compute$name)

    run <- submit_experiment(est, exp)
    wait_for_run_completion(run, show_output = TRUE)
    metrics <- get_run_metrics(run)

    expected_metrics <- list("test_metric" = 0)
    expect_equal(length(setdiff(metrics, expected_metrics)), 0)

    # tear down resources
    unlink(tmp_dir_name, recursive = TRUE)
})