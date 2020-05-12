context("environment")
source("utils.R")


test_that("create environment and check parameters", {
  skip_if_no_azureml()
  env_name <- "testenv"
  
  # Create environment
  env <- r_environment(env_name, version = "1", r_version = "3.5.2")
  expect_equal(env$name, env_name)
  expect_equal(env$version, "1")
  expect_equal(env$docker$enabled, TRUE)
  expect_equal(env$docker$base_dockerfile, NULL)
  expect_equal(env$r$r_version, "3.5.2")

  # use custom docker image
  custom_docker_image_name = "temp_image"
  env <- r_environment(env_name, custom_docker_image = custom_docker_image_name)
  expect_equal(env$name, env_name)
  expect_equal(env$docker$enabled, TRUE)
  expect_equal(env$docker$base_dockerfile, NULL)
  expect_equal(env$docker$base_image, custom_docker_image_name)

  # use extra packages
  cran_pkg1 <- cran_package("ggplot2")
  cran_pkg2 <- cran_package("dplyr")

  github_pkg1 <- github_package("Azure/azureml-sdk-for-r")

  env <- r_environment(env_name, cran_packages = list(cran_pkg1, cran_pkg2),
                       github_packages = list(github_pkg1),
                       custom_url_packages = c("/some/package/dir"),
                       bioconductor_packages = c("a4", "BiocCheck"))
  expect_equal(length(env$r$cran_packages), 2)
  expect_equal(env$r$cran_packages[[1]]$name, "ggplot2")
  expect_equal(env$r$cran_packages[[2]]$name, "dplyr")

  expect_equal(length(env$r$github_packages), 1)
  expect_equal(env$r$github_packages[[1]]$repository, "Azure/azureml-sdk-for-r")

  expect_equal(length(env$r$custom_url_packages), 1)
  expect_equal(env$r$custom_url_packages[[1]], "/some/package/dir")

  expect_equal(length(env$r$bioconductor_packages), 2)
  expect_equal(env$r$bioconductor_packages[[1]], "a4")
  expect_equal(env$r$bioconductor_packages[[2]], "BiocCheck")
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
