# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a deployment config for deploying a local web service
#' @description
#' You can deploy a model locally for limited testing and troubleshooting.
#' To do so, you will need to have Docker installed on your local machine.
#'
#' If you are using an Azure Machine Learning Compute Instance for
#' development, you can also deploy locally on your compute instance.
#' @param port An int of the local port on which to expose the service's
#' HTTP endpoint.
#' @return The `LocalWebserviceDeploymentConfiguration` object.
#' @export
#' @examples
#' \dontrun{
#' deployment_config <- local_webservice_deployment_config(port = 8890)
#' }
#' @md
local_webservice_deployment_config <- function(port = NULL) {
  config <- azureml$core$webservice$LocalWebservice$deploy_configuration(port)
  invisible(config)
}

#' Update a local web service
#' @description
#' Update a local web service with the provided properties. You can update the
#' web service to use a new model, a new entry script, or new dependencies
#' that can be specified in an inference configuration.
#'
#' Values left as `NULL` will remain unchanged in the service.
#' @param webservice The `LocalWebservice` object.
#' @param models A list of `Model` objects to package into the updated service.
#' @param deployment_config A `LocalWebserviceDeploymentConfiguration` to
#' apply to the web service.
#' @param wait If `TRUE`, wait for the service's container to reach a
#' healthy state. Defaults to `FALSE`.
#' @param inference_config An `InferenceConfig` object.
#' @return None
#' @export
#' @md
update_local_webservice <- function(webservice, models = NULL,
                                    deployment_config = NULL,
                                    wait = FALSE,
                                    inference_config = NULL) {
  webservice$update(models = models,
                    deployment_config = deployment_config,
                    wait = wait,
                    inference_config = inference_config)
  invisible(NULL)
}

#' Delete a local web service from the local machine
#' @description
#' Delete a local web service from the local machine. This function call
#' is not asynchronous; it runs until the service is deleted.
#' @param webservice The `LocalWebservice` object.
#' @param delete_cache If `TRUE`, delete the temporary files cached for
#' the service.
#' @param delete_image If `TRUE`, delete the service's Docker image.
#' @return None
#' @export
#' @md
delete_local_webservice <- function(webservice,
                                    delete_cache = TRUE,
                                    delete_image = FALSE) {
  webservice$delete(delete_cache = delete_cache,
                    delete_image = delete_image)
  invisible(NULL)
}

#' Reload a local web service's entry script and dependencies
#' @description
#' This restarts the service's container with copies of updated assets,
#' including the entry script and local dependencies, but it does not
#' rebuild the underlying image. Accordingly, changes to the environment
#' will not be reflected in the reloaded local web service. To handle those
#' changes call `update_local_webservice()` instead.
#' @param webservice The `LocalWebservice` object.
#' @param wait If `TRUE`, wait for the service's container to reach a
#' healthy state. Defaults to `FALSE`.
#' @return None
#' @export
#' @md
reload_local_webservice_assets <- function(webservice, wait = FALSE) {
  webservice$reload(wait)
  invisible(NULL)
}
