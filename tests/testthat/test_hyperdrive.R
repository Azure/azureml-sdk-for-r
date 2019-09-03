context("hyperdrive")

test_that("create hyperdrive config, launch runs, get run metrics",
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
            script_name <- "train_hyperdrive_dummy.R"
            
            dir.create(tmp_dir_name)
            file.copy(script_name, tmp_dir_name)

            script_params <- list(number_1 = 3, number_2 = 2)
            
            est <- create_estimator(source_directory = tmp_dir_name, entry_script = script_name,
                                    compute_target = existing_compute$name,
                                    script_params = script_params)

            run <- submit_experiment(est, exp)
            wait_for_run_completion(run, show_output = TRUE)
            metrics <- get_run_metrics(run)
            
            expected_metrics <- list("Sum" = 5)
            expect_equal(length(setdiff(metrics, expected_metrics)), 0)
            
            
            # define sampling and policy for hyperparameter tuning
            sampling <- grid_parameter_sampling(list(number_1 = choice(c(3, 6)),
                                                     number_2 = choice(c(2, 5))))
            policy <- median_stopping_policy()
            hyperdrive_config <- create_hyperdrive_config(sampling, "Sum", "MAXIMIZE", 4,
                                                          policy = policy, estimator = est)
            
            # submit hyperdrive run
            hyperdrive_run <- submit_experiment(hyperdrive_config, exp)
            wait_for_run_completion(hyperdrive_run, show_output = TRUE)

            children <- get_children_sorted_by_primary_metric()
            expect_equal(length(children), 4)

            children_hyperparams <- get_children_hyperparameters()
            children_metrics <- get_children_metrics()
            
            # find best-performing run
            best_run <- get_best_run_by_primary_metric(hyperdrive_run)
            best_run_metrics <- get_run_metrics(best_run)

            expected_best_metrics <- list("Sum" = 11)
            expect_equal(length(setdiff(best_run-metrics, expected_best_metrics)), 0)

            # tear down resources
            unlink(tmp_dir_name, recursive = TRUE)
          })