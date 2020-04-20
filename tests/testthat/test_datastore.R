context("datastore")
source("utils.R")

test_that("default datastore", {
  skip_if_no_subscription()
  ws <- existing_ws
  ds <- get_default_datastore(ws)
  # upload files to datastore
  file_name <- "dummy_data.txt"
  upload_files_to_datastore(ds, files = list(file.path(".", file_name)))

  # download files from datastore
  target_dir <- file.path(tempdir(), "downloaded_files")
  dir.create(target_dir)
  download_from_datastore(ds, target_path = target_dir, prefix = file_name)

  # check whether file exists
  expect_equal(file.exists(file.path(target_dir, file_name)), TRUE)

  # upload tmp directory to datastore
  tmp_dir_name <- "tmp_dir"
  tmp_dir_path <- file.path(tempdir(), tmp_dir_name)
  dir.create(tmp_dir_path)
  file.copy(file_name, tmp_dir_path)
  upload_to_datastore(ds, src_dir = tmp_dir_path, target_path = tmp_dir_path)
  
  # download data from datastore
  target_dir <- file.path(tempdir(), "downloaded_dir")
  dir.create(target_dir)
  download_from_datastore(ds, target_path = target_dir, prefix = "tmp_dir")
  
  # check whether the directory contents are downloaded
  expect_equal(file.exists(file.path(target_dir, tmp_dir_name)), TRUE)
  expect_equal(file.exists(file.path(target_dir, tmp_dir_name, file_name)),
               TRUE)
  
  # tear down workspace and directory
  unlink(target_dir, recursive = TRUE)
})

test_that("register azure blob/fileshare datastores", {
  skip_if_no_subscription()
  ws <- existing_ws
  
  # register azure blob datastore
  ws_blob_datastore <- get_datastore(ws, "workspaceblobstore")
  blob_datastore_name <- paste0("dsblob", gsub("-", "", build_num))
  register_azure_blob_container_datastore(
    workspace = ws, 
    datastore_name = blob_datastore_name, 
    container_name = ws_blob_datastore$container_name, 
    account_name = ws_blob_datastore$account_name, 
    account_key = ws_blob_datastore$account_key, 
    create_if_not_exists = TRUE)
  
  blob_datastore <- get_datastore(ws, blob_datastore_name)
  expect_equal(blob_datastore$name, blob_datastore_name)
  unregister_datastore(blob_datastore)
  
  # register azure fileshare datastore
  ws_fileshare_datastore <- get_datastore(ws, "workspacefilestore")
  fileshare_datastore_name <- paste0("dsfileshare", gsub("-", "", build_num))
  register_azure_file_share_datastore(
    workspace = ws, 
    datastore_name = fileshare_datastore_name, 
    file_share_name = ws_fileshare_datastore$container_name, 
    account_name = ws_fileshare_datastore$account_name, 
    account_key = ws_fileshare_datastore$account_key, 
    create_if_not_exists = TRUE)
  
  fileshare_datastore <- get_datastore(ws, fileshare_datastore_name)
  expect_equal(fileshare_datastore$name, fileshare_datastore_name)
  unregister_datastore(fileshare_datastore)

})
