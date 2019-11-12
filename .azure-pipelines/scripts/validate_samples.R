#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide the Samples directory path", call.=FALSE)
}

library(azuremlsdk)

subscription_id <- Sys.getenv("TEST_SUBSCRIPTION_ID", unset = NA)
resource_group <- Sys.getenv("TEST_RESOURCE_GROUP")
workspace_name <- Sys.getenv("TEST_WORKSPACE_NAME")
cluster_name <- Sys.getenv("TEST_CLUSTER_NAME")

root_dir <- getwd()

getPathLeaves <- function(path){
  children <- list.dirs(path, recursive = FALSE)
  if(length(children) == 0)
    return(path)
  ret <- list()
  for(child in children){
    ret[[length(ret)+1]] <- getPathLeaves(child)
  }
  return(unlist(ret))
}

validate_samples <- function(directory) {

  sample_dirs = getPathLeaves(directory)

  for (sub_dir in sample_dirs) {
    entry_script <- paste0(basename(sub_dir), ".R")
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
  validate_samples(directory = args[1])
}
