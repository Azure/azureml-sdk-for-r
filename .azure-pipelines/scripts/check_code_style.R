#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide the directory path", call.=FALSE)
}

library("lintr")

check_code_style <- function(directory) {
  files <- list.files(directory)
  for (filename in files) {
    if (filename == "package.R"){
      next
    }

    file <- file.path(".", "R", filename)

    style_issues <- lintr::lint(file, linters = with_defaults(
      line_length_linter = line_length_linter(172L),
      object_length_linter = object_length_linter(40L)
      )
    )

    if (length(style_issues) != 0) {
      print(file)
      print(style_issues)
      stop("Code quality failed.")
    }
  }
}

validate_copyright_header(directory = args[1])
