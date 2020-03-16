context("environment")
source("utils.R")


test_that("create environment and check parameters", {
  skip_if_no_azureml()
  env_name <- "testenv"
  
  # Create environment
  env <- r_environment(env_name, version = "1")
  expect_equal(env$name, env_name)
  expect_equal(env$version, "1")
  expect_equal(env$docker$enabled, TRUE)
  expect_equal(env$docker$base_dockerfile, NULL)

  # use custom docker image
  custom_docker_image_name = "temp_image"
  env <- r_environment(env_name, custom_docker_image = custom_docker_image_name)
  expect_equal(env$name, env_name)
  expect_equal(env$docker$enabled, TRUE)
  expect_equal(env$docker$base_dockerfile, NULL)
  expect_equal(env$docker$base_image, custom_docker_image_name)

  # use extra packages
  env <- r_environment(env_name, cran_packages = c("ggplot2", "dplyr"))
  expect_equal(length(env$r$cran_packages), 2)
  expect_equal(env$r$cran_packages[[1]]$name, "ggplot2")
  expect_equal(env$r$cran_packages[[2]]$name, "dplyr")
})

test_that("create, register, and get environment", {
  skip_if_no_subscription()
  ws <- existing_ws

  env_name <- "testenv"

  # Create environment
  env <- r_environment(env_name, version = "1")

  # Register environment
  register_environment(env, ws)

  # Get environment
  environ <- get_environment(ws, env_name, "1")
  expect_equal(env$name, environ$name)
})