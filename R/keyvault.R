# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Add a named list of secrets eg. list("name" = "value") into the keyvault
#' @param keyvault keyvault object
#' @export
set_secrets <- function(keyvault, secrets) {
  keyvault$set_secrets(secrets)
  invisible(NULL)
}

#' Return the secret values for a given vector of secret names
#' @param keyvault keyvault object
#' @param secrets a vector of secret names
#' @return Returns a list of found and not found secrets
#' @export
get_secrets <- function(keyvault, secrets) {
  keyvault$get_secrets(secrets)
}

#' Delete the secrets from the keyvault
#' @param keyvault keyvault object
#' @param secrets a vector of secret names
#' @export
delete_secrets <- function(keyvault, secrets) {
  keyvault$delete_secrets(secrets)
  invisible(NULL)
}

#' Return the list of secret names
#' @param keyvault keyvault object
#' @return Returns secret names for a given keyvault
#' @export
list_secrets <- function(keyvault) {
  keyvault$list_secrets()
}