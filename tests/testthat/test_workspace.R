context("Workspace")
source("utils.R")

subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID")
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")
location <- Sys.getenv("TEST_LOCATION")

test_that("create, get, save, load and delete workspace", {
  skip('skip')
  # create workspace
  workspace_name <- paste0("test_ws", build_num)
  existing_ws <- create_workspace(workspace_name,
                                  subscription_id = subscription_id,
                                  resource_group = resource_group,
                                  location = location)
    
  # retrieve workspace
  ws <- get_workspace(workspace_name,
                      subscription_id = subscription_id,
                      resource_group = resource_group)
  expect_equal(ws$name, existing_ws$name)
  get_workspace_details(ws)
  kv <- get_default_keyvault(ws)
  expect_equal(length(kv$list_secrets()), 0)
    
  # write config
  write_workspace_config(existing_ws)
    
  # load from config
  loaded_ws <- load_workspace_from_config(".")
  expect_equal(loaded_ws$name, workspace_name)

  ws_details <- get_workspace_details(ws)
  expect_equal(nrow(ws_details), 1)
  expect_equal(length(ws_details), 15)
    
  # delete workspace
  delete_workspace(existing_ws)
    
  # negative testing
  ws <- get_workspace("random", subscription_id = subscription_id)
  expect_equal(ws, NULL)
})
