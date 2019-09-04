context("environment")

test_that("create, register, get and list environment",
{
    ws <- existing_ws
    
    env_name <- "testenv"
    
    # Create environment
    env <- create_environment(env_name, version = "1")
    expect_equal(env$name, env_name)
    expect_equal(env$version, "1")
    expect_equal(env$docker$base_image, NULL)
    expect_equal(env$docker$base_dockerfile, "FROM viennaprivate.azurecr.io/r-base:cpu\n")

    # Register environment
    register_environment(env, ws)
    
    # Get environment
    environ <- get_environment(ws, env_name, "1")
    expect_equal(env, environ)
    
    # List environments
    envs <- list_environments_in_workspace(ws)
    expect_equal(length(envs), 1)
})