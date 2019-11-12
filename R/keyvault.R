# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Add secrets to a keyvault
#'
#' @description
#' Add a named list of secrets into the keyvault associated with the
#' workspace.
#' @param keyvault The `Keyvault` object.
#' @param secrets The named list of secrets to be added to the keyvault,
#' where element name corresponds to the secret name.
#' @return None
#' @export
#' @examples
#' \dontrun{
#' ws <- load_workspace_from_config()
#' my_secret <- Sys.getenv("MY_SECRET")
#' keyvault <- get_default_keyvault(ws)
#' set_secrets(list("mysecret" = my_secret))
#' }
#' @md
set_secrets <- function(keyvault, secrets) {
  keyvault$set_secrets(secrets)
  invisible(NULL)
}

#' Get secrets from a keyvault
#'
#' @description
#' Returns the secret values from the keyvault associated with the
#' workspace for a given set of secret names. For runs submitted using
#' `submit_experiment()`, you can use `get_secrets_from_run()` instead,
#' as that method shortcuts workspace instantiation (since a submitted
#' run is aware of its workspace).
#' @param keyvault The `Keyvault` object.
#' @param secrets A vector of secret names.
#' @return A named list of found and not found secrets, where element
#' name corresponds to the secret name. If a secret was not found, the
#' corresponding element will be `NULL`.
#' @export
#' @md
get_secrets <- function(keyvault, secrets) {
  keyvault$get_secrets(secrets)
}

#' Delete secrets from a keyvault
#'
#' @description
#' Delete secrets from the keyvault associated with the workspace for
#' a specified set of secret names.
#' @param keyvault The `Keyvault` object.
#' @param secrets A vector of secret names.
#' @return None
#' @export
#' @md
delete_secrets <- function(keyvault, secrets) {
  keyvault$delete_secrets(secrets)
  invisible(NULL)
}

#' List the secrets in a keyvault
#'
#' @description
#' Returns the list of secret names for all the secrets in the keyvault
#' associated with the workspace.
#' @param keyvault The `Keyvault` object.
#' @return A list of secret names.
#' @export
#' @md
list_secrets <- function(keyvault) {
  keyvault$list_secrets()
}
