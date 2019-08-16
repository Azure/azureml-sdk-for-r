#' Create run configuration to run a R script
#' @param target target string
#' @param data_references list of data references
#' @param base_image image to use
#' @return runconfig object
#' @export
create_run_config <- function(target, data_references = NULL, base_image = NULL)
{
  runconfig <- azureml$core$runconfig$RunConfiguration(framework="R")
  runconfig$target <- target
  runconfig$environment$docker$enabled <- TRUE
  runconfig$environment$docker$base_image <- base_image
  runconfig$environment$python$user_managed_dependencies <- TRUE

  if (is.null(base_image))
  {
      runconfig$environment$docker$base_image <- "r-base:cpu"
      runconfig$environment$docker$base_image_registry$address <- "viennaprivate.azurecr.io"
  }

  data_references_list <- reticulate::py_dict(keys = NULL, values = NULL)
  if (!is.null(data_references))
  {
    data_references_list <- lapply(data_references, function(x) x$to_config())
    names(data_references_list) <- lapply(data_references, function(x) x$data_reference_name)
  }
  runconfig$data_references <- data_references_list

  invisible(runconfig)
}

#' Create script runconfig
#' @param source_directory source directory containing the script
#' @param script script name
#' @param arguments arguments to script
#' @param target compute target
#' @param data_references list of data references
#' @param base_image image to use
#' @return script runconfig object
#' @export
create_script_run_config <- function(source_directory, script = NULL, arguments = NULL, target = NULL,
  data_references = NULL, base_image = NULL)
{
  run_config <- create_run_config(target,
                data_references = data_references,
                base_image = base_image)
  azureml$core$script_run_config$ScriptRunConfig(source_directory, script, arguments, run_config)
}
