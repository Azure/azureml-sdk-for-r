context("create docker file tests")

test_that("create dockerfile",
{
    dockerfile <- create_docker_file(custom_docker_image = "ubuntu-18.04")
    expect_equal(dockerfile, "FROM ubuntu-18.04\n")

    dockerfile <- create_docker_file(custom_docker_image = "ubuntu-18.04", 
                                     cran_packages = c("ggplot2"), 
                                     github_packages = NULL, 
                                     custom_url_packages = NULL, base_image_registry = NULL)
    expect_equal(dockerfile, "FROM ubuntu-18.04\nRUN R -e install.packages(\"ggplot2\", repos = \"http://cran.us.r-project.org\")\n")
    
    image_registry <- create_container_registry("privateacr")
    dockerfile <- create_docker_file(base_image_registry = image_registry)
    expect_equal(dockerfile, "FROM privateacr/r-base:cpu\n")
})