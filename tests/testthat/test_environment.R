context("environment")
source("utils.R")

test_that("create, register, and get environment", {
  skip_if_no_subscription()
  ws <- existing_ws
  
  env_name <- "testenv"
  
  # Create environment
  env <- r_environment(env_name, version = "1")
  expect_equal(env$name, env_name)
  expect_equal(env$version, "1")
  
  expect_equal(env$docker$enabled, TRUE)
  expect_equal(env$docker$base_dockerfile, NULL)
  expect_equal(env$docker$base_image, "r-base:cpu")

  # Register environment
  register_environment(env, ws)
  
  # Get environment
  environ <- get_environment(ws, env_name, "1")
  expect_equal(env$name, environ$name)
})

test_that("create dockerfile", {
  skip_if_no_subscription()
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04")
  expect_equal(dockerfile, "FROM ubuntu-18.04\n")

  # cran packages
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04",
                                     cran_packages = c("ggplot2", "dplyr"))
  expected_dockerfile <- paste0(
    "FROM ubuntu-18.04\n",
    "RUN R -e \"install.packages(\'ggplot2\', ",
    "repos = \'http://cran.us.r-project.org\')\"\n",
    "RUN R -e \"install.packages(\'dplyr\', ",
    "repos = \'http://cran.us.r-project.org\')\"\n")
  expect_equal(dockerfile, expected_dockerfile)
  
  # github packages
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04",
                                     github_packages = c(
                                       "https://github/user/repo1", 
                                       "https://github/user/repo2"))
  expected_dockerfile <- paste0(
    "FROM ubuntu-18.04\n",
    "RUN R -e \"devtools::install_github(\'https://github/user/repo1\')\"\n",
    "RUN R -e \"devtools::install_github(\'https://github/user/repo2\')\"\n")
  expect_equal(dockerfile, expected_dockerfile)
  
  # custom url
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04",
                                     custom_url_packages = c(
                                       "https://url/pak1.tar", 
                                       "https://url/pak2.tar"))
  expected_dockerfile <- paste0(
    "FROM ubuntu-18.04\n",
    "RUN R -e \"install.packages(\'https://url/pak1.tar\', repos = NULL)\"\n",
    "RUN R -e \"install.packages(\'https://url/pak2.tar\', repos = NULL)\"\n")
  expect_equal(dockerfile, expected_dockerfile)
})