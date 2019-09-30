#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide the direcotry path", call.=FALSE)
}

validate_copyright_header <- function(directory) {
  copyright_header <- c("# Copyright(c) Microsoft Corporation.", 
                        "# Licensed under the MIT license.")
  files <- list.files(directory)
  for (filename in files) {
    file <- file.path(".", "R", filename)
    file_handle <- file(file, open="r")
    lines <- readLines(file_handle)
    
    assertthat::assert_that(length(lines) >= length(copyright_header))
    
    for (i in 1:length(copyright_header)) {
      assertthat::assert_that(lines[[i]] == copyright_header[[i]])
    }
  }
}


validate_copyright_header(directory = args[1])
