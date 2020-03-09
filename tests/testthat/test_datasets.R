context("datasets")
source("utils.R")

test_that("create a tabular dataset, register multiple versions of a dataset,
          unregister a dataset",{
  skip_if_no_subscription()
  ws <- existing_ws

  # upload files to datastore and create dataset
  ds <- get_default_datastore(ws)

  file_name <- "iris.csv"
  upload_files_to_datastore(ds,
                            files = list(file.path(".", file_name)),
                            target_path = 'train-dataset/tabular/',
                            overwrite = TRUE)
  dataset <- create_tabular_dataset_from_delimited_files(ds$path('train-dataset/tabular/iris.csv'))

  # load data into data frame
  pandas_df <- load_dataset_into_data_frame(dataset)
  expect_equal(is.data.frame(pandas_df), TRUE)

  # register two versions of the dataset
  register_dataset(ws, dataset, "iris")
  register_dataset(ws, dataset, "iris", create_new_version = TRUE)

  # check updated number of datasets in workspace
  all_registered_datasets <- ws$datasets
  expect_equal(length(all_registered_datasets), 2)

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
