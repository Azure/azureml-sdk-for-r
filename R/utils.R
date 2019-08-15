#' Creates a R launch script which contains all the packages to be installed before running entry_script
#' @param source_directory A local directory containing experiment configuration files.
#' @param entry_script A string representing the relative path to the file used to start training.
#' @param cran_packages List of cran packages to be installed.
#' @param github_packages List of github packages to be installed.
#' @param custom_url_packages List of packages to be installed from local, directory or custom url.
create_launch_script <- function(source_directory, entry_script, cran_packages = NULL, github_packages = NULL, custom_url_packages = NULL)
{
  launch_file_name <- "launch_R_script.R"
  launch_file_conn <- file(file.path(source_directory, launch_file_name), open = "w")
  
  if (!is.null(cran_packages))
  {
    for (package in cran_packages)
    {
      writeLines(sprintf("install.packages(\"%s\", repos = \"http://cran.us.r-project.org\")\n", package), launch_file_conn)
    }
  }
  
  if (!is.null(github_packages))
  {
    for (package in github_packages)
    {
      writeLines(sprintf("install_github(\"%s\")\n", package), launch_file_conn)
    }
  }
  
  if (!is.null(custom_url_packages))
  {
    for (package in custom_url_packages)
    {
      writeLines(sprintf("install.packages(\"%s\", repos=NULL)\n", package), launch_file_conn)
    }
  }
  
  writeLines(sprintf("source(\"%s\")", entry_script), launch_file_conn)
  
  close(launch_file_conn)
  invisible(launch_file_name)
}