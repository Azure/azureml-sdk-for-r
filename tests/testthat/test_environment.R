context("environment")

test_that("create, register, and get environment",
{
    ws <- existing_ws
    
    env_name <- "testenv"
    
    # Create environment
    env <- environment(env_name, version = "1")
    expect_equal(env$name, env_name)
    expect_equal(env$version, "1")
    
    expect_equal(env$docker$base_dockerfile, NULL)
    expect_equal(env$docker$base_image, "r-base:cpu")

    # Register environment
    register_environment(env, ws)
    
    # Get environment
    environ <- get_environment(ws, env_name, "1")
    expect_equal(env$name, environ$name)
})