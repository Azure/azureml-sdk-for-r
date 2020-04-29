# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create an estimator
#'
#' @description
#' An Estimator wraps run configuration information for specifying details
#' of executing an R script. Running an Estimator experiment
#' (using `submit_experiment()`) will return a `ScriptRun` object and
#' execute your training script on the specified compute target.
#'
#' To define the environment to use for training, you can either directly
#' provide the environment-related parameters (e.g. `cran_packages`,
#' `custom_docker_image`) to `estimator()`, or you can provide an
#' `Environment` object to the `environment` parameter. For more information
#' on the predefined Docker images that are used for training if
#' `custom_docker_image` is not specified, see the documentation
#' [here](https://azure.github.io/azureml-sdk-for-r/reference/r_environment.html#predefined-docker-images).
#' @param source_directory A string of the local directory containing
#' experiment configuration and code files needed for the training job.
#' @param compute_target The `AmlCompute` object for the compute target
#' where training will happen.
#' @param vm_size A string of the VM size of the compute target that will be
#' created for the training job. The list of available VM sizes
#' are listed [here](https://docs.microsoft.com/azure/cloud-services/cloud-services-sizes-specs).
#' Provide this parameter if you want to create AmlCompute as the compute target
#' at run time, instead of providing an existing cluster to the `compute_target`
#' parameter. If `vm_size` is specified, a single-node cluster is automatically
#' created for your run and is deleted automatically once the run completes.
#' @param vm_priority A string of either `'dedicated'` or `'lowpriority'` to
#' specify the VM priority of the compute target that will be created for the
#' training job. Defaults to `'dedicated'`. This takes effect only when the
#' `vm_size` parameter is specified.
#' @param entry_script A string representing the relative path to the file used
#' to start training.
#' @param script_params A named list of the command-line arguments to pass to
#' the training script specified in `entry_script`.
#' @param max_run_duration_seconds An integer of the maximum allowed time for
#' the run. Azure ML will attempt to automatically cancel the run if it takes
#' longer than this value.
#' @param environment The `Environment` object that configures the R
#' environment where the experiment is executed.
#' @param inputs A list of DataReference objects or DatasetConsumptionConfig
#' objects to use as input.
#' @return The `Estimator` object.
#' @export
#' @section Examples:
#' ```
#' est <- estimator(source_directory = ".",
#'                  entry_script = "train.R",
#'                  compute_target = compute_target)
#' ```
#' @seealso
#' [r_environment()], [container_registry()], [submit_experiment()],
#' [dataset_consumption_config()], [cran_package()]
#'
#' @md
estimator <- function(source_directory,
                      compute_target = NULL,
                      vm_size = NULL,
                      vm_priority = NULL,
                      entry_script = NULL,
                      script_params = NULL,
                      max_run_duration_seconds = NULL,
                      environment = NULL,
                      inputs = NULL) {

  if (is.null(environment)) {
    environment <- r_environment(name = "estimatorenv")
  }

  est <- azureml$train$estimator$Estimator(
    source_directory,
    compute_target = compute_target,
    vm_size = vm_size,
    vm_priority = vm_priority,
    entry_script = entry_script,
    script_params = script_params,
    max_run_duration_seconds = max_run_duration_seconds,
    environment_definition = environment,
    inputs = inputs)

  run_config <- est$run_config
  run_config$framework <- "R"
  invisible(est)
}
