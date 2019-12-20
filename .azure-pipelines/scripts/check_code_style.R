#!/usr/bin/env
args <- commandArgs(trailingOnly = TRUE)
if (length(args) == 0) {
  stop("Please provide the directory path", call.=FALSE)
}

library("lintr")

check_code_style <- function(args) {
  skip_tests = c("package.R")
  if (length(args) > 1) {
    skip_tests <- append(skip_tests, unlist(strsplit(args[2], ";")))
  }

  directory = args[1]
  files <- list.files(directory)

  for (filename in files) {
    if (filename %in% skip_tests) {
      next
    }

    file <- file.path(".", "R", filename)

    style_issues <- lintr::lint(file, linters = with_defaults(
      line_length_linter = line_length_linter(240L),
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

check_code_style(args)
