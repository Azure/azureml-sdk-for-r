# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Create a configuration object for deploying an ACI Webservice.
#' @param cpu_cores The number of cpu cores to allocate for this Webservice. Can be a decimal.
#' @param memory_gb The amount of memory (in GB) to allocate for this Webservice. Can be a decimal.
#' Defaults to 0.5
#' @param tags Dictionary of key value tags to give this Webservice
#' @param properties Dictionary of key value properties to give this Webservice. These properties cannot
#' be changed after deployment, however new key value pairs can be added
#' @param description A description to give this Webservice
#' @param location The Azure region to deploy this Webservice to. If not specified the Workspace location will
#' be used. More details on available regions can be found here:
#' https://azure.microsoft.com/en-us/global-infrastructure/services/?regions=all&products=container-instances
#' @param auth_enabled Whether or not to enable auth for this Webservice. Defaults to FALSE
#' @param ssl_enabled Whether or not to enable SSL for this Webservice. Defaults to FALSE
#' @param enable_app_insights Whether or not to enable AppInsights for this Webservice. Defaults to FALSE
#' @param ssl_cert_pem_file The cert file needed if SSL is enabled
#' @param ssl_key_pem_file The key file needed if SSL is enabled
#' @param ssl_cname The cname for if SSL is enabled
#' @param dns_name_label The dns name label for the scoring endpoint.
#' If not specified a unique dns name label will be generated for the scoring endpoint.
#' @return AciServiceDeploymentConfiguration object to use when deploying a Webservice object
#' @export
aci_webservice_deployment_config <- function(cpu_cores = NULL, memory_gb = NULL, tags = NULL, properties = NULL, 
                                             description = NULL, location = NULL, auth_enabled = NULL, ssl_enabled = NULL, 
                                             enable_app_insights = NULL, ssl_cert_pem_file = NULL, 
                                             ssl_key_pem_file = NULL, ssl_cname = NULL, dns_name_label = NULL)
{
  azureml$core$webservice$AciWebservice$deploy_configuration(cpu_cores, memory_gb, tags, properties, description,
                                                             location, auth_enabled, ssl_enabled, enable_app_insights,
                                                             ssl_cert_pem_file, ssl_key_pem_file, ssl_cname, dns_name_label)
}

#' Update the Webservice with provided properties.
#' Values left as None will remain unchanged in this Webservice.
#' @param webservice AciWebservice object.
#' @param tags Dictionary of key value tags to give this Webservice. Will replace existing tags.
#' @param properties Dictionary of key value properties to add to existing properties dictionary.
#' @param description A description to give this Webservice.
#' @param auth_enabled Enable or disable auth for this Webservice.
#' @param ssl_enabled Whether or not to enable SSL for this Webservice.
#' @param ssl_cert_pem_file The cert file needed if SSL is enabled.
#' @param ssl_key_pem_file The key file needed if SSL is enabled.
#' @param ssl_cname The cname for if SSL is enabled.
#' @param enable_app_insights Whether or not to enable AppInsights for this Webservice.
#' @param models A list of Model objects to package into the updated service.
#' @param inference_config An InferenceConfig object used to provide the required model deployment properties.
#' @export
update_aci_webservice <- function(webservice, tags = NULL, properties = NULL, description = NULL, auth_enabled = NULL,
                                  ssl_enabled = NULL, ssl_cert_pem_file = NULL, ssl_key_pem_file = NULL, 
                                  ssl_cname = NULL, enable_app_insights = NULL, models = NULL, inference_config = NULL) 
{
  webservice$update(tags = tags, properties = properties, description = description, auth_enabled = auth_enabled,
                    ssl_enabled = ssl_enabled, ssl_cert_pem_file = ssl_cert_pem_file, ssl_key_pem_file = ssl_key_pem_file, 
                    ssl_cname = ssl_cname, enable_app_insights = enable_app_insights, models = models, 
                    inference_config = inference_config)
}
