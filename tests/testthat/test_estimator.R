context("estimator")

test_that("create estimator", {
  skip_if_no_azureml()

  est <- estimator(".",
                   compute_target = "local",
                   script_params = list("param1" = 1),
                   cran_packages = list(cran_package("ggplot2")),
                   use_gpu = TRUE,
                   environment_variables = list("var1" = "val1"))
  
  expect_equal(est$run_config$target, "local")
  expect_equal(length(est$run_config$arguments), 2)
  expect_equal(est$run_config$arguments[[1]], "param1")
  expect_equal(est$run_config$arguments[[2]], 1)
  expect_equal(est$run_config$environment$docker$gpu_support, TRUE)
  
  env_vars <- est$run_config$environment$environment_variables
  expect_equal(names(env_vars)[[1]], "var1")
  expect_equal(env_vars[[1]], "val1")
})