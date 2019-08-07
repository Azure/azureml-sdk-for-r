context("install azureml")

test_that("install_azureml",
{
    install_azureml(environment = test_env)
    expect_true(TRUE)
})