# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a deployment config for deploying an ACI web service
#' @description
#' Deploy a web service to Azure Container Instances for testing or
#' debugging. Use ACI for low-scale CPU-based workloads that
#' require less than 48 GB of RAM.
#'
#' Deploy to ACI if one of the following conditions is true:
#' * You need to quickly deploy and validate your model. You do not need
#' to create ACI containers ahead of time. They are created as part of
#' the deployment process.
#' * You are testing a model that is under development.
#' @param cpu_cores The number of cpu cores to allocate for
#' the web service. Can be a decimal. Defaults to `0.1`.
#' @param memory_gb The amount of memory (in GB) to allocate for
#' the web service. Can be a decimal. Defaults to `0.5`.
#' @param tags A named list of key-value tags for the web service,
#' e.g. `list("key" = "value")`.
#' @param properties A named list of key-value properties for the web
#' service, e.g. `list("key" = "value")`. These properties cannot
#' be changed after deployment, but new key-value pairs can be added.
#' @param description A string of the description to give the web service.
#' @param location A string of the Azure region to deploy the web service
#' to. If not specified the workspace location will be used. More details
#' on available regions can be found [here](https://azure.microsoft.com/en-us/global-infrastructure/services/?regions=all&products=container-instances).
#' @param auth_enabled If `TRUE` enable key-based authentication for the
#' web service. Defaults to `FALSE`.
#' @param ssl_enabled If `TRUE` enable SSL for the web service. Defaults
#' to `FALSE`.
#' @param enable_app_insights If `TRUE` enable AppInsights for the web service.
#' Defaults to `FALSE`.
#' @param ssl_cert_pem_file A string of the cert file needed if SSL is enabled.
#' @param ssl_key_pem_file A string of the key file needed if SSL is enabled.
#' @param ssl_cname A string of the cname if SSL is enabled.
#' @param dns_name_label A string of the dns name label for the scoring
#' endpoint.
#' If not specified a unique dns name label will be generated for the scoring
#' endpoint.
#' @return The `AciServiceDeploymentConfiguration` object.
#' @export
#' @examples
#' \dontrun{
#' deployment_config <- aci_webservice_deployment_config(cpu_cores = 1, memory_gb = 1)
#' }
#' @seealso
#' `deploy_model()`
#' @md
aci_webservice_deployment_config <- function(cpu_cores = NULL,
                                             memory_gb = NULL,
                                             tags = NULL,
                                             properties = NULL,
                                             description = NULL,
                                             location = NULL,
                                             auth_enabled = NULL,
                                             ssl_enabled = NULL,
                                             enable_app_insights = NULL,
                                             ssl_cert_pem_file = NULL,
                                             ssl_key_pem_file = NULL,
                                             ssl_cname = NULL,
                                             dns_name_label = NULL) {
  azureml$core$webservice$AciWebservice$deploy_configuration(
                                             cpu_cores,
                                             memory_gb,
                                             tags,
                                             properties,
                                             description,
                                             location,
                                             auth_enabled,
                                             ssl_enabled,
                                             enable_app_insights,
                                             ssl_cert_pem_file,
                                             ssl_key_pem_file,
                                             ssl_cname,
                                             dns_name_label)
}

#' Update a deployed ACI web service
#' @description
#' Update an ACI web service with the provided properties. You can update the
#' web service to use a new model, a new entry script, or new dependencies
#' that can be specified in an inference configuration.
#'
#' Values left as `NULL` will remain unchanged in the web service.
#' @param webservice The `AciWebservice` object.
#' @param tags A named list of key-value tags for the web service,
#' e.g. `list("key" = "value")`. Will replace existing tags.
#' @param properties A named list of key-value properties to add for the web
#' service, e.g. `list("key" = "value")`.
#' @param description A string of the description to give the web service.
#' @param auth_enabled If `TRUE` enable key-based authentication for the
#' web service.
#' @param ssl_enabled Whether or not to enable SSL for this Webservice.
#' @param ssl_cert_pem_file A string of the cert file needed if SSL is enabled.
#' @param ssl_key_pem_file A string of the key file needed if SSL is enabled.
#' @param ssl_cname A string of the cname if SSL is enabled.
#' @param enable_app_insights If `TRUE` enable AppInsights for the web service.
#' @param models A list of `Model` objects to package into the updated service.
#' @param inference_config An `InferenceConfig` object.
#' @return None
#' @export
#' @md
update_aci_webservice <- function(webservice,
                                  tags = NULL,
                                  properties = NULL,
                                  description = NULL,
                                  auth_enabled = NULL,
                                  ssl_enabled = NULL,
                                  ssl_cert_pem_file = NULL,
                                  ssl_key_pem_file = NULL,
                                  ssl_cname = NULL,
                                  enable_app_insights = NULL,
                                  models = NULL,
                                  inference_config = NULL) {
  webservice$update(tags = tags,
                    properties = properties,
                    description = description,
                    auth_enabled = auth_enabled,
                    ssl_enabled = ssl_enabled,
                    ssl_cert_pem_file = ssl_cert_pem_file,
                    ssl_key_pem_file = ssl_key_pem_file,
                    ssl_cname = ssl_cname,
                    enable_app_insights = enable_app_insights,
                    models = models,
                    inference_config = inference_config)
  invisible(NULL)
}
