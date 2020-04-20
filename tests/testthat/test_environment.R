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
  cran_pkg1 <- cran_package("ggplot2")
  cran_pkg2 <- cran_package("dplyr")

  env <- r_environment(env_name, cran_packages = list(cran_pkg1, cran_pkg2),
                       github_packages = c("Azure/azureml-sdk-for-r"),
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
<<<<<<< HEAD
=======
})

test_that("create dockerfile", {
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04")
  expect_equal(dockerfile, paste0("FROM ubuntu-18.04\nRUN conda install -c r ",
                                  "-y r-essentials=3.6.0 r-reticulate rpy2 ",
                                  "r-remotes r-e1071 r-optparse && conda ",
                                  "clean -ay && pip install --no-cache-dir ",
                                  "azureml-defaults\nENV TAR=\"/bin/tar\"\n",
                                  "RUN R -e \"remotes::install_cran('azuremlsdk'",
                                  ", repos = 'https://cloud.r-project.org/', ",
                                  "upgrade = FALSE)\"\n"))
  
  # cran packages
  cran_pkg_1 <- cran_package("ggplot2")
  cran_pkg_2 <- cran_package("stringr", "0.0.0", "https://some-other-repo.com/")
  cran_pkg_3 <- cran_package('shiny', "1.14")
  dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04",
                                     cran_packages = list(cran_pkg_1,
                                                          cran_pkg_2,
                                                          cran_pkg_3),
                                     install_system_packages = FALSE)
  expected_dockerfile <- paste0("FROM ubuntu-18.04\n",
                                "RUN R -e \"remotes::install_version('ggplot2', repos = c('https://cloud.r-project.org'))\"\n",
                                "RUN R -e \"remotes::install_version('stringr', version = '0.0.0', repos = c('https://some-other-repo.com/'))\"\n",
                                "RUN R -e \"remotes::install_version('shiny', version = '1.14', repos = c('https://cloud.r-project.org'))\"\n")
  expect_equal(dockerfile, expected_dockerfile)
  
  # github packages
  dockerfile <- generate_docker_file(github_packages = c(
    "https://github/user/repo1", 
    "https://github/user/repo2"),
    install_system_packages = FALSE)
  expected_dockerfile <- paste0(
    "RUN R -e \"remotes::install_github(\'https://github/user/repo1\')\"\n",
    "RUN R -e \"remotes::install_github(\'https://github/user/repo2\')\"\n")
  expect_equal(dockerfile, expected_dockerfile)
  
  # custom url
  dockerfile <- generate_docker_file(custom_url_packages = c(
    "https://url/pak1.tar", 
    "https://url/pak2.tar"),
    install_system_packages = FALSE)
  expected_dockerfile <- paste0(
    "RUN R -e \"install.packages(\'https://url/pak1.tar\', repos = NULL)\"\n",
    "RUN R -e \"install.packages(\'https://url/pak2.tar\', repos = NULL)\"\n")
  expect_equal(dockerfile, expected_dockerfile)
>>>>>>> master
})