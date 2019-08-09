context("Workspace")

subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID")
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")

test_that("create, get, save and load workspace",
{
    workspace_name <- existing_ws$name

    # retrieve workspace
    ws <- get_workspace(workspace_name, subscription_id = subscription_id, resource_group = resource_group)
    expect_equal(ws$name, workspace_name)

    # write config
    write_workspace_config(existing_ws)

    # load from config
    loaded_ws <- load_workspace_from_config(".")
    expect_equal(loaded_ws$name, workspace_name)
})
