context("hyperdrive")

test_that("create hyperdrive config, launch runs, get best run metrics",
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
            
            est <- create_estimator(source_directory = tmp_dir_name, entry_script = script_name,
                                    compute_target = existing_compute$name)
            
            
            # tear down resources
            unlink(tmp_dir_name, recursive = TRUE)
          })