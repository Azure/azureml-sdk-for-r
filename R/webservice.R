# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Get a deployed web service
#' @description
#' Return the corresponding Webservice object of a deployed web service from
#' a given workspace.
#' @param workspace The `Workspace` object.
#' @param name A string of the name of the web service to retrieve.
#' @return The `LocalWebservice`, `AciWebservice`, or `AksWebservice` object.
#' @export
#' @md
get_webservice <- function(workspace, name) {
  webservice <- azureml$core$Webservice(workspace, name)
  invisible(webservice)
}

#' Wait for a web service to finish deploying
#' @description
#' Automatically poll on the running web service deployment and
#' wait for the web service to reach a terminal state. Will throw
#' an exception if it reaches a non-successful terminal state.
#'
#' Typically called after running `deploy_model()`.
#' @param webservice The `LocalWebservice`, `AciWebservice`, or
#' `AksWebservice` object.
#' @param show_output If `TRUE`, print more verbose output. Defaults
#' to `FALSE`.
#' @return None
#' @export
#' @seealso
#' `deploy_model()`
#' @md
wait_for_deployment <- function(webservice, show_output = FALSE) {
  webservice$wait_for_deployment(show_output)
}

#' Retrieve the logs for a web service
#' @description
#' You can get the detailed Docker engine log messages from your
#' web service deployment. You can view the logs for local, ACI,
#' and AKS deployments.
#'
#' For example, if your web service deployment fails, you can
#' inspect the logs to help troubleshoot.
#' @param webservice The `LocalWebservice`, `AciWebservice`, or
#' `AksWebservice` object.
#' @param num_lines An int of the maximum number of log lines to
#' retrieve.
#' @return A string of the logs for the web service.
#' @export
#' @md
get_webservice_logs <- function(webservice, num_lines = 5000L) {
  webservice$get_logs(num_lines)
}

#' Retrieve auth keys for a web service
#' @description
#' Get the authentication keys for a web service that is deployed
#' with key-based authentication enabled. In order to enable
#' key-based authentication, set the `auth_enabled = TRUE` parameter
#' when you are creating or updating a deployment (either
#' `aci_webservice_deployment_config()` or
#' `aks_webservice_deployment_config()` for creation and
#' `update_aci_webservice()` or `update_aks_webservice()` for updating).
#' Note that key-based auth is enabled by default for `AksWebservice`
#' but not for `AciWebservice`.
#'
#' To check if a web service has key-based auth enabled, you can
#' access the following boolean property from the Webservice object:
#' `service$auth_enabled`
#'
#' Not supported for `LocalWebservice` deployments.
#' @param webservice The `AciWebservice` or `AksWebservice` object.
#' @return A list of two strings corresponding to the primary and
#' secondary authentication keys.
#' @export
#' @seealso
#' `generate_new_webservice_key()`
#' @md
get_webservice_keys <- function(webservice) {
  webservice$get_keys()
}

#' Delete a web service from a given workspace
#' @description
#' Delete a deployed ACI or AKS web service from the given workspace.
#' This function call is not asynchronous; it runs until the resource is
#' deleted.
#'
#' To delete a `LocalWebservice` see `delete_local_webservice()`.
#' @param webservice The `AciWebservice` or `AksWebservice` object.
#' @return None
#' @export
#' @md
delete_webservice <- function(webservice) {
  webservice$delete()
  invisible(NULL)
}

#' Call a web service with the provided input
#' @description
#' Invoke the web service with the provided input and to receive
#' predictions from the deployed model. The structure of the
#' provided input data needs to match what the service's scoring
#' script and model expect. See the "Details" section of
#' `inference_config()`.
#' @param webservice The `LocalWebservice`, `AciWebservice`, or
#' `AksWebservice` object.
#' @param input_data The input data to invoke the web service with. This is
#' the data your model expects as an input to run predictions.
#' @return A named list of the result of calling the web service. This will
#' return the predictions run from your model.
#' @export
#' @details
#' Instead of invoking the web service using `invoke_webservice()`, you can
#' also consume the web service using the service's REST API. If you've
#' enabled key-based authentication for your service, you will need to provide
#' a service key as a token in your request header
#' (see `get_webservice_keys()`). If you've enabled token-based
#' authentication, you will need to provide an JWT token as a bearer
#' token in your request header (see `get_webservice_token()`).
#'
#' To get the REST API address for the service's scoring endpoint, you can
#' access the following property from the Webservice object:
#' `service$scoring_uri`
#' @md
invoke_webservice <- function(webservice, input_data) {
  webservice$run(input_data)
}

#' Regenerate one of a web service's keys
#' @description
#' Regenerate either the primary or secondary authentication key for
#' an `AciWebservice` or `AksWebservice`.The web service must have
#' been deployed with key-based authentication enabled.
#'
#' Not supported for `LocalWebservice` deployments.
#' @param webservice The `AciWebservice` or `AksWebservice` object.
#' @param key_type A string of which key to regenerate. Options are
#' "Primary" or "Secondary".
#' @return None
#' @export
#' @md
generate_new_webservice_key <- function(webservice, key_type) {
  webservice$regen_key(key_type)
  invisible(NULL)
}

#' Retrieve the auth token for a web service
#' @description
#' Get the authentication token, scoped to the current user,
#' for a web service that was deployed with token-based authentication
#' enabled. Token-based authentication requires clients to use an Azure
#' Active Directory account to request an authentication token, which is
#' used to make requests to the deployed service. Only available for
#' AKS deployments.
#'
#' In order to enable token-based authentication, set the
#' `token_auth_enabled = TRUE` parameter when you are creating or
#' updating a deployment (`aks_webservice_deployment_config()` for creation
#' or `update_aks_webservice()` for updating). Note that you cannot have both
#' key-based authentication and token-based authentication enabled.
#' Token-based authentication is not enabled by default.
#'
#' To check if a web service has token-based auth enabled, you can
#' access the following boolean property from the Webservice object:
#' `service$token_auth_enabled`
#' @param webservice The `AksWebservice` object.
#' @return An `AksServiceAccessToken` object.
#' @export
#' @md
get_webservice_token <- function(webservice) {
  webservice$get_access_token()
}

#' Convert this Webservice into a json serialized dictionary.
#' @param webservice The webservice object.
#' @return The json representation of this Webservice
#' @noRd
serialize_webservice <- function(webservice) {
  webservice$serialize()
}

#' Convert a json object into a Webservice object.
#' @param workspace The workspace object the Webservice is registered under
#' @param webservice_payload A json object to convert to a Webservice object
#' @return The Webservice representation of the provided json object
#' @noRd
deserialize_to_webservice <- function(workspace, webservice_payload) {
  azureml$core$Webservice$deserialize(workspace, webservice_payload)
}
