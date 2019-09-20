# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a configuration object for deploying a local Webservice.
#' @param port The local port on which to expose the service's HTTP endpoint.
#' @return LocalWebserviceDeploymentConfiguration object to use when deploying a Webservice object.
#' @export
local_webservice_deployment_config <- function(port = NULL)
{
  config <- azureml$core$webservice$LocalWebservice$deploy_configuration(port)
  invisible(config)
}

#' Update the LocalWebservice with provided properties.
#' Values left as None will remain unchanged in this LocalWebservice.
#' @param webservice LocalWebservice object.
#' @param models A new list of models contained in the LocalWebservice.
#' @param deployment_config Deployment configuration options to apply to the LocalWebservice.
#' @param wait Wait for the service's container to reach a healthy state.
#' @param inference_config An InferenceConfig object used to provide the required model deployment properties.
#' @export
update_local_webservice <- function(webservice, models = NULL, 
                                    deployment_config = NULL, wait = FALSE, 
                                    inference_config = NULL)
{
  webservice$update(models = models, deployment_config = deployment_config,
                    wait = wait, inference_config = inference_config)
}

#' Delete this LocalWebservice from the local machine.
#' This function call is not asynchronous; it runs until the service is deleted.
#' @param webservice LocalWebservice object.
#' @param delete_cache Delete temporary files cached for the service.
#' @param delete_image Delete the service's Docker image.
#' @export
delete_local_webservice <- function(webservice, delete_cache = TRUE, delete_image = FALSE)
{
  webservice$delete(delete_cache = delete_cache, delete_image = delete_image)
}

#' Reload the LocalWebservice's execution script and dependencies.
#' This restarts the service's container with copies of updated assets, including the execution script and local
#' dependencies, but it does not rebuild the underlying image. Accordingly, changes to Conda/pip dependencies or
#' custom Docker steps will not be reflected in the reloaded LocalWebservice. To handle those changes call
#' LocalWebservice.update(), instead.
#' @param webservice LocalWebservice object.
#' @param wait Wait for the service's container to reach a healthy state.
#' @export
reload_local_webservice_assets <- function(webservice, wait = FALSE)
{
  webservice$reload(wait)
}
