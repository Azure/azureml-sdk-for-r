context("datasets")
source("utils.R")

test_that("create a tabular dataset,
          load into data frame,
          register multiple versions of a dataset,
          unregister a dataset",{
                   
  skip_if_no_subscription()
  ws <- existing_ws

  # create tabular dataset from delimited files
  date <- as.POSIXct("2011-05-01 17:55:23")
  path_to_dataset <- "https://automlsamplenotebookdata.blob.core.windows.net/automl-sample-notebook-data/nyc_energy.csv"
  time_column_name <- 'timeStamp'
  dataset <- create_tabular_dataset_from_delimited_files(path=path_to_dataset)$with_timestamp_columns(fine_grain_timestamp=time_column_name)
  filtered_dataset <- filter_dataset_before_time(dataset, date)

  # load data into data frame
  pandas_df <- load_dataset_into_data_frame(filtered_dataset)
  expect_equal(is.data.frame(pandas_df), TRUE)
                  
  # register first version of the dataset
  dataset_name <- paste0("energy-", sample.int(100, 1))
  registered_dataset1 <-register_dataset(ws, dataset, dataset_name, description='I am version 1')
  expect_equal(registered_dataset1$name, dataset_name)
 
  # register second version of the dataset
  registered_dataset2 <-register_dataset(ws, dataset, dataset_name, description='I am version 2', create_new_version=TRUE)

  expect_equal(registered_dataset1$name, registered_dataset2$name)
  expect_equal(registered_dataset1$description, 'I am version 1')
  expect_equal(registered_dataset2$description, 'I am version 2')

  # unregister datasets
  unregister_all_dataset_versions(dataset)
  expect_equal(dataset$name, NULL)
  expect_equal(dataset$id, NULL)

})

test_that("register datastore, create file dataset,
          get file dataset paths,
          submit run with dataset as named input", {
  
  skip('skip')
  ws <- existing_ws

  ds <- get_default_datastore(ws)

  # register azure blob datastore with mnist data
  account_name <- "pipelinedata"
  datastore_name <- "mnist_datastore"
  container_name <- "sampledata"

  ws_blob_datastore <- get_datastore(ws, "workspaceblobstore")
  blob_datastore_name <- paste0("dsblob", gsub("-", "", 1))
  mnist_data <- register_azure_blob_container_datastore(
    workspace = ws, 
    datastore_name = blob_datastore_name, 
    container_name = ws_blob_datastore$container_name, 
    account_name = ws_blob_datastore$account_name, 
    account_key = ws_blob_datastore$account_key, 
    create_if_not_exists = TRUE)

  path_on_datastore <- mnist_data$path('mnist')
  datapath <- data_path(mnist_data, path_on_datastore)
  dataset <- create_file_dataset_from_files(datapath)

  file_dataset_path <- get_file_dataset_paths(dataset)
  expect_equal(file_dataset_path, 'train-dataset/file/iris.csv')

  # submit with run
  est <- estimator(".",
                   entry_script = "train_datasets_dummy.R",
                   compute_target = "local",
                   inputs = list(dataset$as_named_input('mnist')))

  run <- submit_experiment(exp, est)
  wait_for_run_completion(run, show_output = TRUE)
  expect_equal(run$status, "Completed")

})
