context("estimator")

test_that("create estimator", {
  skip_if_no_azureml()

  r_env <- r_environment("r-env",
                         cran_packages = list(cran_package("ggplot2")),
                         use_gpu = TRUE,
                         environment_variables = list("var1" = "val1"))

  est <- estimator(".", compute_target = "local",
                   script_params = list("param1" = 1),
                   environment = r_env)

  expect_equal(est$run_config$target, "local")
  expect_equal(length(est$run_config$arguments), 2)
  expect_equal(est$run_config$arguments[[1]], "param1")
  expect_equal(est$run_config$arguments[[2]], 1)
})