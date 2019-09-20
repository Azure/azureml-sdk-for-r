# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Retrieve a cloud representation of a Webservice object associated with the
#' provided workspace. Will return an instance of a child class corresponding to
#' the
#' specific type of the retrieved Webservice object.
#' @param workspace The workspace object containing the Webservice object to
#' retrieve
#' @param name The name of the of the Webservice object to retrieve
#' @export
get_webservice <- function(workspace, name) {
  webservice <- azureml$core$Webservice(workspace, name)
  invisible(webservice)
}

#' Automatically poll on the running Webservice deployment.
#' @param webservice The webservice object.
#' @param show_output Option to print more verbose output.
#' @export
wait_for_deployment <- function(webservice, show_output = FALSE) {
  webservice$wait_for_deployment(show_output)
}

#' Retrieve logs for the Webservice.
#' @param webservice The webservice object.
#' @param num_lines The maximum number of log lines to retrieve.
#' @export
get_webservice_logs <- function(webservice, num_lines = 5000L) {
  webservice$get_logs(num_lines)
}

#' Retrieve auth keys for this Webservice.
#' @param webservice The webservice object.
#' @export
get_webservice_keys <- function(webservice) {
  webservice$get_keys()
}

#' Delete this Webservice from its associated workspace.
#' @param webservice The webservice object.
#' @export
delete_webservice <- function(webservice) {
  webservice$delete()
}

#' Call this Webservice with the provided input.
#' @param webservice The webservice object.
#' @param input_data The input data to call the Webservice with. This is the
#' data your machine learning model expects as an input to run predictions.
#' @export
invoke_webservice <- function(webservice, input_data) {
  webservice$run(input_data)
}

#' Regenerate one of the Webservice's keys. Must specify either 'Primary' or
#' 'Secondary' key.
#' @param webservice The webservice object.
#' @param key_type Which key to regenerate. Options are 'Primary' or 'Secondary'
#' @export
generate_new_webservice_key <- function(webservice, key_type) {
  webservice$regen_key(key_type)
}

#' Retrieve auth token for this Webservice, scoped to the current user.
#' @param webservice The webservice object.
#' @export
get_webservice_token <- function(webservice) {
  webservice$get_token()
}

#' Convert this Webservice into a json serialized dictionary.
#' @param webservice The webservice object.
serialize_webservice <- function(webservice) {
  webservice$serialize()
}

#' Convert a json object into a Webservice object.
#' @param workspace The workspace object the Webservice is registered under
#' @param webservice_payload A json object to convert to a Webservice object
deserialize_to_webservice <- function(workspace, webservice_payload) {
  azureml$core$Webservice$deserialize(workspace, webservice_payload)
}
