# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Register a Dataset in the workspace
#'
#' @description
#' Register the Dataset in the workspace, making it available to other users of the workspace.
#'
#' @param dataset The dataset to be registered.
#' @param workspace The AzureML workspace in which the Dataset is to be registered.
#' @param name The name of the Dataset in the workspace.
#' @param description A description of the Dataset.
#' @param tags Named list of tags to give the Dataset. Defaults to NULL.
#' @param create_new_version Boolean to register the dataset as a new version under the specified name.
#' @return The registered Dataset object.
#' @export
#' @md
register_dataset <- function(workspace, dataset, name, description = NULL,
                             tags = NULL, create_new_version = FALSE) {
  dataset$register(workspace, name, description, tags, create_new_version)
}

#' Unregister all versions under the registration name of this dataset from the workspace.
#'
#' @description
#' Unregister all versions under the registration name of this dataset from the workspace.
#'
#' @param dataset The dataset to be unregistered.
#' @return None
#' @export
#' @md
unregister_all_dataset_versions <- function(dataset) {
  dataset$unregister_all_versions()
  invisible(NULL)
}

#' Get a registered Dataset from the workspace by its registration name.
#'
#' @description
#' Get a registered Dataset from the workspace by its registration name.
#'
#' @param workspace The existing AzureML workspace in which the Dataset was registered.
#' @param name The registration name.
#' @param version The registration version. Defaults to "latest".
#' @return The registered Dataset object.
#' @export
#' @md
get_dataset_by_name <- function(workspace, name, version = "latest") {
  azureml$core$dataset$Dataset$get_by_name(workspace, name, version)
}

#' Get Dataset by ID.
#'
#' @description
#' Get a Dataset which is saved to the workspace using its ID.
#'
#' @param workspace The existing AzureML workspace in which the Dataset is saved.
#' @param id The ID of the dataset
#' @return The Dataset object
#' @export
#' @md
get_dataset_by_id <- function(workspace, id) {
  azureml$core$dataset$Dataset$get_by_id(workspace, id)
}

#' Return the named list for input datasets.
#'
#' @description
#' Return the named list for input datasets.
#'
#' @param name The name of the input dataset
#' @param run The run taking the dataset as input
#' @return A dataset object corresponding to the "name"
#' @export
#' @md
get_input_dataset_from_run <- function(name, run = NULL) {
  if (is.null(run)) {
    run <- get_current_run()
  }

  run$input_datasets[name]
}

#' Create a FileDataset to represent file streams.
#'
#' @description
#' Create a FileDataset to represent file streams.
#'
#' @param path A data path in a registered datastore or a local path.
#' @param validate Indicates whether to validate if data can be loaded from the
#' returned dataset. Defaults to True. Validation requires that the data source
#' is accessible from the current compute.
#' @return The FileDataset object
#' @export
#' @seealso
#' \code{\link{data_path}}
#' @md
create_file_dataset_from_files <- function(path, validate = TRUE) {
  azureml$data$dataset_factory$FileDatasetFactory$from_files(path, validate)
}

#' Get a list of file paths for each file stream defined by the dataset.
#'
#' @description
#' Get a list of file paths for each file stream defined by the dataset. The file
#' paths are relative paths for local files when the file srteam are downloaded
#' or mounted. A common prefix will be removed from the file paths based on how
#' data source was specified to create the dataset.
#'
#' @param dataset The Dataset object.
#' @return A list of file paths.
#' @export
#' @md
get_file_dataset_paths <- function(dataset) {
  list(dataset$to_path())
}

#' Download file streams defined by the dataset as local files.
#'
#' @description
#' Download file streams defined by the dataset as local files. If target_path starts
#' with a /, then it will be treated as an absolute path. If it doesn't start with a /,
#' then it will be treated as a relative path relative to the current working directory.
#'
#' @param dataset The Dataset object
#' @param target_path The local directory to download the files to. If NULL,
#' the data will be downloaded into a temporary directory.
#' @param overwrite Indicates whether to overwirte existing files. The default
#' is FALSE. Existing files will be overwritten if ``overwrite`` is set to TRUE;
#' otherwise an exception will be raised.
#' @return A list of file paths for each file downloaded.
#' @export
#' @md
download_from_file_dataset <- function(dataset, target_path = NULL,
                                       overwrite = FALSE) {
  list(dataset$download(target_path, overwrite))
}

#' Create a context manager for mounting file streams defined by the dataset as local files.
#'
#' @description
#' Create a context manager for mounting file streams defined by the dataset as local files.
#' A context manager will be returned to manage the lifecycle of the mount.
#' To mount, you will need to enter the context manager and to unmount, exit from
#' the context manager. Mount is only supported on Unix or Unix-like operating systems
#' and libfuse must be present. If you are running inside a docker container, the docker
#' container must be started with the `--privileged` flag or started with
#' `--cap-add SYS_ADMIN --device /dev/fuse`.
#'
#' @param dataset The Dataset object.
#' @param mount_point The local directory to mount the files to. If NULL, the
#' data will be mounted into a temporary directory.
#' @return Returns a context manager for managing the lifecycle of the mount of
#' type `azureml.dataprep.fuse.daemon.MountContext`.
#' @export
#' @md
mount_file_dataset <- function(dataset, mount_point = NULL) {
  dataset$mount(mount_point = mount_point)
}

#' Skip file streams from the top of the dataset by the specified count.
#'
#' @description
#' Skip file streams from the top of the dataset by the specified count.
#'
#' @param dataset The Dataset object.
#' @param count The number of file streams to skip.
#' @return A new Dataset object representing the dataset with file streams skipped.
#' @export
#' @md
skip_from_dataset <- function(dataset, count) {
  dataset$skip(count)
}

#' Take a sample of file streams from top of the dataset by the specified count.
#'
#' @description
#' Take a sample of file streams from top of the dataset by the specified count.
#'
#' @param dataset The Dataset object.
#' @param count The number of file streams to take.
#' @return A new Dataset object representing the sampled dataset.
#' @export
#' @md
take_from_dataset <- function(dataset, count) {
  dataset$take(count)
}

#' Take a random sample of file streams in the dataset approximately by the probability specified.
#'
#' @description
#' Take a random sample of file streams in the dataset approximately by the probability specified.
#'
#' @param dataset The Dataset object.
#' @param probability The probability of a file stream being included in the sample.
#' @param seed An optional seed to use for the random generator.
#' @return A new Dataset object representing the sampled dataset.
#' @export
#' @md
take_sample_from_dataset <- function(dataset, probability, seed = NULL) {
  dataset$take_sample(probability, seed)
}

#' Split file streams in the dataset into two parts randomly and approximately by the percentage specified.
#'
#' @description
#' Split file streams in the dataset into two parts randomly and approximately by the percentage specified.
#'
#' @param dataset The Dataset object.
#' @param percentage The approximate percentage to split the Dataset by. This must
#' be a number between 0.0 and 1.0.
#' @param seed An optional seed to use for the random generator.
#' @return A new Dataset object representing the two datasets after the split.
#' @export
#' @md
random_split_dataset <- function(dataset, percentage, seed = NULL) {
  dataset$random_split(percentage, seed)
}

#' Create an unregistered, in-memory Dataset from parquet files.
#'
#' @description
#' Create an unregistered, in-memory Dataset from parquet files.
#'
#' @param path A data path in a registered datastore or a local path.
#' @param validate Boolean to validate if data can be loaded from the returned dataset.
#' Defaults to True. Validation requires that the data source is accessible from the
#' current compute.
#' @param include_path Whether to include a column containing the path of the file
#' from which the data was read. This is useful when you are reading multiple files,
#' and want to know which file a particular record originated from, or to keep useful
#' information in file path.
#' @param set_column_types A named list to set column data type, where key is
#' column name and value is data type.
#' @param partition_format Specify the partition format in path and create string columns from
#' format '{x}' and datetime column from format '{x:yyyy/MM/dd/HH/mm/ss}', where 'yyyy', 'MM',
#' 'dd', 'HH', 'mm' and 'ss' are used to extrat year, month, day, hour, minute and second for the datetime
#' type. The format should start from the postition of first partition key until the end of file path.
#' For example, given a file path '../USA/2019/01/01/data.csv' and data is partitioned by country and time,
#' we can define '/{Country}/{PartitionDate:yyyy/MM/dd}/data.csv' to create columns 'Country'
#' of string type and 'PartitionDate' of datetime type.
#' @return The Tabular Dataset object.
#' @export
#' @seealso
#' \code{\link{data_path}}
#' @md
create_tabular_dataset_from_parquet_files <- function(path, validate = TRUE,
                                                      include_path = FALSE,
                                                      set_column_types = NULL,
                                                      partition_format = NULL) {
  azureml$core$dataset$Dataset$Tabular$from_parquet_files(path, validate,
                                                          include_path,
                                                          set_column_types,
                                                          partition_format)
}

#' Create an unregistered, in-memory Dataset from delimited files.
#'
#' @description
#' Create an unregistered, in-memory Dataset from delimited files.
#' Use this method to read delimited text files when you want to control the options used.
#'
#' @param path A data path in a registered datastore, a local path, or an HTTP URL.
#' @param validate Boolean to validate if data can be loaded from the returned dataset.
#' Defaults to True. Validation requires that the data source is accessible from the
#' current compute.
#' @param include_path Whether to include a column containing the path of the file
#' from which the data was read. This is useful when you are reading multiple files,
#' and want to know which file a particular record originated from, or to keep
#' useful information in file path.
#' @param infer_column_types Indicates whether column data types are inferred.
#' @param set_column_types A named list to set column data type, where key is
#' column name and value is data type.
#' @param separator The separator used to split columns.
#' @param partition_format Specify the partition format in path and create string columns from
#' format '{x}' and datetime column from format '{x:yyyy/MM/dd/HH/mm/ss}', where 'yyyy', 'MM',
#' 'dd', 'HH', 'mm' and 'ss' are used to extrat year, month, day, hour, minute and second for the datetime
#' type. The format should start from the postition of first partition key until the end of file path.
#' For example, given a file path '../USA/2019/01/01/data.csv' and data is partitioned by country and time,
#' we can define '/{Country}/{PartitionDate:yyyy/MM/dd}/data.csv' to create columns 'Country'
#' of string type and 'PartitionDate' of datetime type.
#' @param header Controls how column headers are promoted when reading from files. Defaults to True for all
#' files having the same header. Files will read as having no header When header=False. More options can
#' be specified using `PromoteHeadersBehavior`.
#' @param support_multi_line By default (support_multi_line=FALSE), all line breaks,
#' including those in quoted field values, will be interpreted as a record break. Reading data this way is
#' faster and more optimized for parallel execution on multiple CPU cores. However, it may result in silently
#' producing more records with misaligned field values. This should be set to TRUE when the delimited files
#' are known to contain quoted line breaks.
#' @param empty_as_string Specify if empty field values should be loaded as empty strings.
#' The default (FALSE) will read empty field values as nulls. Passing this as TRUE will read empty
#' field values as empty strings. If the values are converted to numeric or datetime then this has no effect,
#' as empty values will be converted to nulls.
#' @return The Tabular Dataset object.
#' @export
#' @seealso
#' \code{\link{data_path}}
#' @md
create_tabular_dataset_from_delimited_files <- function(
  path, validate = TRUE, include_path = FALSE, infer_column_types = TRUE,
  set_column_types = NULL, separator = ",", header = TRUE,
  partition_format = NULL, support_multi_line = FALSE,
  empty_as_string = FALSE) {
  azureml$core$dataset$Dataset$Tabular$from_delimited_files(path,
                                                            validate,
                                                            include_path,
                                                            infer_column_types,
                                                            set_column_types,
                                                            separator,
                                                            header,
                                                            partition_format,
                                                            support_multi_line,
                                                            empty_as_string)
}

#' Create a TabularDataset to represent tabular data in JSON Lines files (http://jsonlines.org/).
#'
#' @description
#' Create a TabularDataset to represent tabular data in JSON Lines files (http://jsonlines.org/).
#' ``from_json_lines_files``` creates a Tabular Dataset object , which defines the operations to
#' load data from JSON Lines files into tabular representation. For the data to be accessible
#' by Azure Machine Learning, the JSON Lines files specified by `path` must be located in
#' a Datastore or behind public web urls. Column data types are read from data types saved
#' in the JSON Lines files. Providing `set_column_types` will override the data type
#' for the specified columns in the returned Tabular Dataset.
#'
#' @param path The path to the source files, which can be single value or list
#' of http url string or tuple of Datastore and relative path.
#' @param validate Boolean to validate if data can be loaded from the returned
#' dataset. Defaults to True. Validation requires that the data source is
#' accessible from the current compute.
#' @param include_path Boolean to keep path information as column in the dataset.
#' Defaults to False. This is useful when reading multiple files, and want to
#' know which file a particular record originated from, or to keep useful
#' information in file path.
#' @param set_column_types A named list to set column data type, where key is
#' column name and value is data type.
#' @param partition_format Specify the partition format in path and create string columns from
#' format '{x}' and datetime column from format '{x:yyyy/MM/dd/HH/mm/ss}', where 'yyyy', 'MM',
#' 'dd', 'HH', 'mm' and 'ss' are used to extrat year, month, day, hour, minute and second for the datetime
#' type. The format should start from the postition of first partition key until the end of file path.
#' For example, given a file path '../USA/2019/01/01/data.csv' and data is partitioned by country and time,
#' we can define '/{Country}/{PartitionDate:yyyy/MM/dd}/data.csv' to create columns 'Country'
#' of string type and 'PartitionDate' of datetime type.
#' @return The Tabular Dataset object.
#' @export
#' @seealso
#' \code{\link{data_path}}
#' @md
create_tabular_dataset_from_json_lines_files <- function(
                                                      path,
                                                      validate = TRUE,
                                                      include_path = FALSE,
                                                      set_column_types = NULL,
                                                      partition_format = NULL) {
  azureml$core$dataset$Dataset$Tabular$from_json_lines_files(path,
                                                             validate,
                                                             include_path,
                                                             set_column_types,
                                                             partition_format)
}

#' Create a TabularDataset to represent tabular data in SQL databases.
#'
#' @description
#' Create a TabularDataset to represent tabular data in SQL databases.
#' ``from_sql_query``` creates a Tabular Dataset object , which defines the operations to
#' load data from SQL databases into tabular representation. For the data to be accessible
#' by Azure Machine Learning, the SQL database specified by `query` must be located in
#' a Datastore and the datastore type must be of a SQL kind. Column data types are
#' read from data types in SQL query result. Providing `set_column_types` will
#' override the data type  for the specified columns in the returned Tabular Dataset.
#'
#' @param query A SQL-kind datastore and a query
#' @param validate Boolean to validate if data can be loaded from the returned dataset.
#' Defaults to True. Validation requires that the data source is accessible from
#' the current compute.
#' @param set_column_types A named list to set column data type, where key is
#' column name and value is data type.
#' @param query_timeout Sets the wait time (as an int, in seconds) before terminating the attempt to execute a command
#' and generating an error. The default is 30 seconds.
#' @return A `TabularDataset` object
#' @export
#' @section Examples:
#' ```
#' # create tabular dataset from a SQL database in datastore
#' datastore <- get_datastore(ws, 'sql-db')
#' query <- data_path(datastore, 'SELECT * FROM my_table')
#' tab_ds <- create_tabular_dataset_from_sql_query(query, query_timeout = 10)
#'
#' # use `set_column_types` param to set column data types
#' data_types <- list(ID = data_type_string(),
#'                    Date = data_type_datetime('%d/%m/%Y %I:%M:%S %p'),
#'                    Count = data_type_long(),
#'                    Latitude = data_type_double(),
#'                    Found = data_type_bool())
#'
#' set_tab_ds <- create_tabular_dataset_from_sql_query(query, set_column_types = data_types)

#' ```
#' @seealso [data_path()] [data_type_datetime()] [data_type_bool()]
#' [data_type_double()] [data_type_string()] [data_type_long()]
#' @md
create_tabular_dataset_from_sql_query <- function(query, validate = TRUE,
                                                  set_column_types = NULL,
                                                  query_timeout = 30L) {
  azureml$core$dataset$Dataset$Tabular$from_sql_query(query = query,
                                      validate = validate,
                                      set_column_types = set_column_types,
                                      query_timeout = as.integer(query_timeout))
}

#' Drop the specified columns from the dataset.
#'
#' @description
#' Drop the specified columns from the dataset. If a timeseries column is dropped,
#' the corresponding capabilities will be dropped for the returned dataset as well.
#'
#' @param dataset The Tabular Dataset object.
#' @param columns A name or a list of names for the columns to drop.
#' @return A new TabularDataset object with the specified columns dropped.
#' @export
#' @md
drop_columns_from_dataset <- function(dataset, columns) {
  dataset$drop_columns(columns)
}

#' Keep the specified columns and drops all others from the dataset.
#'
#' @description
#' Keep the specified columns and drops all others from the dataset.
#' If a timeseries column is dropped, the corresponding capabilities will be
#' dropped for the returned dataset as well.
#'
#' @param dataset The Tabular Dataset object
#' @param columns The name or a list of names for the columns to keep.
#' @param validate Indicates whether to validate if data can be loaded from the
#' returned dataset. The default is False. Validation requires that the data
#' source is accessible from current compute.
#' @return A new Tabular Dataset object with only the specified columns kept.
#' @export
#' @md
keep_columns_from_dataset <- function(dataset, columns, validate = FALSE) {
  dataset$keep_columns(columns, validate)
}

#' Filter Tabular Dataset with time stamp columns after a specified start time.
#'
#' @description
#' Filter Tabular Dataset with time stamp columns after a specified start time.
#'
#' @param dataset The Tabular Dataset object
#' @param start_time The lower bound for filtering data.
#' @param include_boundary Boolean indicating if the row associated with the
#' boundary time (``start_time``) should be included.
#' @return The filtered Tabular Dataset
#' @export
#' @md
filter_dataset_after_time <- function(dataset, start_time,
                                      include_boundary = TRUE) {
  dataset$time_after(start_time, include_boundary)
}

#' Filter Tabular Dataset with time stamp columns before a specified end time.
#'
#' @description
#' Filter Tabular Dataset with time stamp columns before a specified end time.
#'
#' @param dataset The Tabular Dataset object
#' @param end_time The upper bound for filtering data.
#' @param include_boundary Boolean indicating if the row associated with the
#' boundary time (``start_time``) should be included.
#' @return The filtered Tabular Dataset
#' @export
#' @md
filter_dataset_before_time <- function(dataset, end_time,
                                       include_boundary = TRUE) {
  dataset$time_before(end_time, include_boundary)
}

#' Filter Tabular Dataset between a specified start and end time.
#'
#' @description
#' Filter Tabular Dataset between a specified start and end time.
#'
#' @param dataset The Tabular Dataset object
#' @param start_time The lower bound for filtering data.
#' @param end_time The upper bound for filtering data.
#' @param include_boundary Boolean indicating if the row associated with the
#' boundary time (`start_time` and `end_time`) should be included.
#' @return The filtered Tabular Dataset
#' @export
#' @md
filter_dataset_between_time <- function(dataset, start_time, end_time,
                                        include_boundary = TRUE) {
  dataset$time_between(start_time, end_time, include_boundary)
}

#' Filter Tabular Dataset to contain only the specified duration (amount) of recent data.
#'
#' @description
#' Filter Tabular Dataset to contain only the specified duration (amount) of recent data.
#'
#' @param dataset The Tabular Dataset object
#' @param time_delta The duration (amount) of recent data to retrieve.
#' @param include_boundary Boolean indicating if the row associated with the
#' boundary time (`time_delta`) should be included.
#' @return The filtered Tabular Dataset
#' @export
#' @md
filter_dataset_from_recent_time <- function(dataset, time_delta,
                                            include_boundary = TRUE) {
  dataset$time_recent(time_delta, include_boundary)
}

#' Define timestamp columns for the dataset.
#'
#' @description
#' Define timestamp columns for the dataset.
#' The method defines columns to be used as timestamps. Timestamp columns on a dataset
#' make it possible to treat the data as time-series data and enable additional capabilities.
#' When a dataset has both `fine_grain_timestamp` and `coarse_grain_timestamp defined`
#' specified, the two columns should represent the same timeline.
#'
#' @param dataset The Tabular Dataset object.
#' @param fine_grain_timestamp The name of column as fine grain timestamp. Use None to clear it.
#' @param coarse_grain_timestamp The name of column coarse grain timestamp (optional).
#' The default is None.
#' @param validate Indicates whether to validate if specified columns exist in dataset.
#' The default is False. Validation requires that the data source is accessible
#' from the current compute.
#' @return The Tabular Dataset with timestamp columns defined.
#' @export
#' @md
define_timestamp_columns_for_dataset <- function(dataset, fine_grain_timestamp,
                                                 coarse_grain_timestamp = NULL,
                                                 validate = FALSE) {
  dataset$with_timestamp_columns(fine_grain_timestamp, coarse_grain_timestamp,
                                 validate)
}

#' Load all records from the dataset into a dataframe.
#'
#' @description
#' Load all records from the dataset into a dataframe.
#'
#' @param dataset The Tabular Dataset object.
#' @param on_error How to handle any error values in the dataset, such as those
#' produced by an error while parsing values. Valid values are 'null' which replaces
#' them with NULL; and 'fail' which will result in an exception.
#' @param out_of_range_datetime How to handle date-time values that are outside
#' the range supported by Pandas. Valid values are 'null' which replaces them with
#' NULL; and 'fail' which will result in an exception.
#' @return A data.frame.
#' @export
#' @md
load_dataset_into_data_frame <- function(dataset, on_error = "null",
                                         out_of_range_datetime = "null")	{
  dataset$to_pandas_dataframe(on_error = on_error,
                              out_of_range_datetime = out_of_range_datetime)
}

#' Convert the current dataset into a FileDataset containing CSV files.
#'
#' @description
#' Convert the current dataset into a FileDataset containing CSV files.
#'
#' @param dataset The Tabular Dataset object.
#' @param separator The separator to use to separate values in the resulting file.
#' @return A new FileDataset object with a set of CSV files containing the data
#' in this dataset.
#' @export
#' @md

convert_to_dataset_with_csv_files <- function(dataset, separator = ",") {
  dataset$to_csv_files(separator)
}

#' Convert the current dataset into a FileDataset containing Parquet files.
#'
#' @description
#' Convert the current dataset into a FileDataset containing Parquet files.
#' The resulting dataset will contain one or more Parquet files, each corresponding
#' to a partition of data from the current dataset. These files are not materialized
#' until they are downloaded or read from.
#'
#' @param dataset The Tabular Dataset object.
#' @return A new FileDataset object with a set of Parquet files containing the
#' data in this dataset.
#' @export
#' @md
convert_to_dataset_with_parquet_files <- function(dataset) {
  dataset$to_parquet_files()
}

#' Configure conversion to bool.
#'
#' @description
#' Configure conversion to bool.
#'
#' @return Converted DataType object.
#' @export
#' @md
data_type_bool <- function() {
  azureml$data$dataset_factory$DataType$to_bool()
}

#' Configure conversion to datetime.
#'
#' @description
#' Configure conversion to datetime.
#'
#' @param formats Formats to try for datetime conversion. For example `%d-%m-%Y` for data in "day-month-year",
#' and `%Y-%m-%dT%H:%M:%S.%f` for "combined date an time representation" according to ISO 8601.
#' * %Y: Year with 4 digits
#' * %y: Year with 2 digits
#' * %m: Month in digits
#' * %b: Month represented by its abbreviated name in 3 letters, like Aug
#' * %B: Month represented by its full name, like August
#' * %d: Day in digits
#' * %H: Hour as represented in 24-hour clock time
#' * %I: Hour as represented in 12-hour clock time
#' * %M: Minute in 2 digits
#' * %S: Second in 2 digits
#' * %f: Microsecond
#' * %p: AM/PM designator
#' * %z: Timezone, for example: -0700
#'
#' Format specifiers will be inferred if not specified.
#' Inference requires that the data source is accessible from current compute.
#' @return Converted DataType object.
#' @export
#' @md
data_type_datetime <- function(formats = NULL) {
  azureml$data$dataset_factory$DataType$to_datetime(formats)
}

#' Configure conversion to 53-bit double.
#'
#' @description
#' Configure conversion to 53-bit double.
#'
#' @return Converted DataType object.
#' @export
#' @md
data_type_double <- function()	{
  azureml$data$dataset_factory$DataType$to_float()
}

#' Configure conversion to 64-bit integer.
#'
#' @description
#' Configure conversion to 64-bit integer.
#'
#' @return Converted DataType object.
#' @export
#' @md
data_type_long <- function() {
  azureml$data$dataset_factory$DataType$to_float()
}

#' Configure conversion to string.
#'
#' @description
#' Configure conversion to string.
#'
#' @return Converted DataType object.
#' @export
#' @md
data_type_string <- function() {
  azureml$data$dataset_factory$DataType$to_string()
}

#' Defines options for how column headers are processed when reading data from files to create a dataset.
#'
#' @description
#' Defines options for how column headers are processed when reading data from files to create a dataset.
#' These enumeration values are used in the Dataset class method.
#'
#' @param option An integer corresponding to an option for how column headers are to be processed
#' * 0: NO_HEADERS No column headers are read
#' * 1: ONLY_FIRST_FILE_HAS_HEADERS Read headers only from first row of first file, everything else is data.
#' * 2: COMBINE_ALL_FILES_HEADERS Read headers from first row of each file, combining identically named columns.
#' * 3: ALL_FILES_HAVE_SAME_HEADERS Read headers from first row of first file, drops first row from other files.
#' @return The PromoteHeadersBehavior object.
#' @export
#' @md
promote_headers_behavior <- function(option) {
  option <- as.integer(option)
  azureml$data$dataset_type_definitions$PromoteHeadersBehavior(option)
}

#' Represents a path to data in a datastore.
#'
#' @description
#' The path represented by DataPath object can point to a directory or a data artifact (blob, file).
#'
#' @param datastore The Datastore to reference.
#' @param path_on_datastore The relative path in the backing storage for the data reference.
#' @param name An optional name for the DataPath.
#' @return The `DataPath` object.
#' @export
#' @section Examples:
#' ```
#' my_data <- register_azure_blob_container_datastore(
#'     workspace = ws,
#'     datastore_name = blob_datastore_name,
#'     container_name = ws_blob_datastore$container_name,
#'     account_name = ws_blob_datastore$account_name,
#'     account_key = ws_blob_datastore$account_key,
#'     create_if_not_exists = TRUE)
#'
#' datapath <- data_path(my_data, <path_on_my_datastore>)
#' dataset <- create_file_dataset_from_files(datapath)
#' ```
#' @seealso
#' \code{\link{create_file_dataset_from_files}}
#' \code{\link{create_tabular_dataset_from_parquet_files}}
#' \code{\link{create_tabular_dataset_from_delimited_files}}
#' \code{\link{create_tabular_dataset_from_json_lines_files}}
#' \code{\link{create_tabular_dataset_from_sql_query}}
#' @md
data_path <- function(datastore, path_on_datastore = NULL, name = NULL) {
  azureml$data$datapath$DataPath(datastore = datastore,
                                 path_on_datastore = path_on_datastore,
                                 name = name)
}

#' Represent how to deliver the dataset to a compute target.
#'
#' @description
#' Represent how to deliver the dataset to a compute target.
#'
#' @param name The name of the dataset in the run, which can be different to the
#' registered name. The name will be registered as environment variable and can
#' be used in data plane.
#' @param dataset The dataset that will be consumed in the run.
#' @param mode Defines how the dataset should be delivered to the compute target. There are three modes:
#'
#' 'direct': consume the dataset as dataset.
#' 'download': download the dataset and consume the dataset as downloaded path.
#' 'mount': mount the dataset and consume the dataset as mount path.
#' @param path_on_compute The target path on the compute to make the data available at.
#' The folder structure of the source data will be kept, however, we might add prefixes
#' to this folder structure to avoid collision.
#' @return The `DatasetConsumptionConfig` object.
#' @export
#' @section Examples:
#' ```
#' est <- estimator(source_directory = ".",
#'                  entry_script = "train.R",
#'                  inputs = list(dataset_consumption_config('mydataset', dataset, mode = 'download')),
#'                  compute_target = compute_target)
#' ```
#' @seealso
#' \code{\link{estimator}}
#' @md
dataset_consumption_config <- function(name, dataset, mode = "direct",
                                       path_on_compute = NULL) {
  azureml$data$dataset_consumption_config$DatasetConsumptionConfig(
    name = name,
    dataset = dataset,
    mode = mode,
    path_on_compute = path_on_compute)
}
