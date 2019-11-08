#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0 || length(args) %% 2 == 1) {
  stop("Please provide the directory path and entry script", call.=FALSE)
}

validate_samples <- function(args) {
  for (i in seq(1, length(args), 2)) {
    sub_dir_name <- args[i]
    entry_script <- args[i+1]
    
    root_dir <- getwd()
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


validate_samples(args)
