# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Retrieve a cloud representation of a Webservice object associated with the
#' provided workspace. Will return an instance of a child class corresponding to the
#' specific type of the retrieved Webservice object.
#' @param workspace The workspace object containing the Webservice object to retrieve
#' @param name The name of the of the Webservice object to retrieve
#' @export
get_webservice <- function(workspace, name)
{
  webservice <- azureml$core$Webservice(workspace, name)
  invisible(webservice)
}

#' Automatically poll on the running Webservice deployment.
#' @param webservice The webservice object.
#' @param show_output Option to print more verbose output.
#' @export
wait_for_deployment <- function(webservice, show_output = FALSE)
{
  webservice$wait_for_deployment(show_output)
}

#' Retrieve logs for the Webservice.
#' @param webservice The webservice object.
#' @param num_lines The maximum number of log lines to retrieve.
get_webservice_logs <- function(webservice, num_lines = 5000)
{
  webservice$get_logs(num_lines)
}


get_webservice_keys <- function(webservice, key)	get_keys

delete_webservice <- function(webservice)	delete

invoke_webservice <- function(webservice, input_data)	run

generate_new_webservice_key <- function(webservice, key_type = c("PRIMARY", "SECONDARY"))	regen_key

get_webservice_token <- function(webservice)	get_token

serialize_webservice <- function(webservice)	serialize

deserialize_to_webservice <- function(workspace, webservice_payload)
