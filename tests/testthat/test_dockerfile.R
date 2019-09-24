context("create docker file tests")

test_that("create dockerfile", {
    dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04")
    expect_equal(dockerfile, "FROM ubuntu-18.04\n")

    dockerfile <- generate_docker_file(custom_docker_image = "ubuntu-18.04",
                                       cran_packages = c("ggplot2"))

    expected_dockerfile <- paste0(
        "FROM ubuntu-18.04\n",
        sprintf("RUN R -e install.packages(\"%s\",
                                  repos = \"http://cran.us.r-project.org\")\n",
                "ggplot2"))

    expect_equal(dockerfile, expected_dockerfile)
})