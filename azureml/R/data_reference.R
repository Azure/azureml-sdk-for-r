#' Create data reference configuration
#' @param data_reference Data reference object
#' @export
get_data_reference_configuration <- function(data_reference)
{
    invisible(data_reference$to_config())
}

#' Makes a datastore available as a datareference for a run
#' @param datastore the Datastore to reference
#' @param data_reference_name the name of the data reference
#' @param path_on_datastore the relative path on cloud for the data reference
#' @param mode the operation on the data reference, we support mount, download
#' @param path_on_compute the path on compute for the data reference
#' @param overwrite overwrite if data reference exists
#' @return data reference object
#' @export
create_data_reference <- function(datastore, data_reference_name=NULL, path_on_datastore = NULL, mode = 'mount',
                                path_on_compute = NULL, overwrite = FALSE)
{
    aml$data$data_reference$DataReference(datastore, data_reference_name = data_reference_name,
                                path_on_datastore = path_on_datastore, mode = mode, path_on_compute = path_on_compute,
                                overwrite = overwrite)
}

#' Get data reference path on path_on_compute
#' @param data_reference DataReference whose path is needed
#' @return environment variable in remote compute that holds the data reference path.
#' @export
get_data_reference_path_in_compute <- function(data_reference)
{
    py_str(data_reference)
}
