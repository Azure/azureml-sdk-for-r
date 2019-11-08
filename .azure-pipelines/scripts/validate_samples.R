#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0 || length(args) %% 2 == 1) {
  stop("Please provide the directory path and entry script", call.=FALSE)
}

library(azuremlsdk)

subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID", unset = NA)
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")
workspace_name <- Sys.getenv("TEST_WORKSPACE_NAME")
cluster_name <- Sys.getenv("TEST_CLUSTER_NAME")

root_dir <- getwd()

validate_samples <- function(args) {
  for (i in seq(1, length(args), 2)) {
    sub_dir_name <- args[i]
    entry_script <- args[i+1]
    
    sub_dir <- file.path(root_dir, "samples", sub_dir_name)
    setwd(sub_dir)
    
    tryCatch({
      source(entry_script)
      setwd(root_dir)
    },
    error = function(e) {
      stop(message(e))
    })
  }
}

if(!is.na(subscription_id)) {
  ws <- get_workspace(workspace_name, subscription_id, resource_group)
  write_workspace_config(ws, path = root_dir)
  validate_samples(args)
}
