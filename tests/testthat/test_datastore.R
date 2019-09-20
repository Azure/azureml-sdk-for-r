context("datastore")

test_that("datastore", {
    ws <- existing_ws
    ds <- get_default_datastore(ws)
    # upload files to datastore
    file_name <- "dummy_data.txt"
    upload_files_to_datastore(ds, files = list(file.path(".", file_name)))

    # download files from datastore
    target_dir <- "./downloaded_files"
    dir.create(target_dir)
    download_from_datastore(ds, target_path = target_dir)

    # check whether file exists
    expect_equal(file.exists(file.path(target_dir, file_name)), TRUE)


    # upload tmp directory to datastore
    tmp_dir_name <- "tmp_dir"
    dir.create(tmp_dir_name)
    file.copy(file_name, tmp_dir_name)
    upload_to_datastore(ds, src_dir = tmp_dir_name, target_path = tmp_dir_name)
    
    # download data from datastore
    target_dir <- "./downloaded_dir"
    dir.create(target_dir)
    download_from_datastore(ds, target_path = target_dir, prefix = tmp_dir_name)
    
    # check whether the directory contents are downloaded
    expect_equal(file.exists(file.path(target_dir, tmp_dir_name)), TRUE)
    expect_equal(file.exists(file.path(target_dir, tmp_dir_name, file_name)),
                 TRUE)
    

    # tear down workspace and directory
    unlink(target_dir, recursive = TRUE)
})