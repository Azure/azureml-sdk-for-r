context("create docker file tests")

test_that("create dockerfile",
{
    dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04")
    expect_equal(dockerfile, "FROM ubuntu-18.04\n")

    dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04", cran_packages = c("ggplot2"))
    expect_equal(dockerfile, "FROM ubuntu-18.04\nRUN R -e install.packages(\"ggplot2\", repos = \"http://cran.us.r-project.org\")\n")
})