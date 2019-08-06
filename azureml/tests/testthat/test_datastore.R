context("datastore")

test_that("datastore",
{
    ws <- existing_ws
    ds <- get_default_datastore(ws)
    # upload files to datastore
    file_name <- "dummy_data.txt"
    upload_files_to_azure_datastore(ds, files = list(file.path(".", file_name)))

    # download files from datastore
    target_dir <- "./downloaded_files"
    dir.create(target_dir)
    download_from_datastore(ds, target_path = target_dir)

    # check whether file exists
    expect_equal(file.exists(file.path(target_dir, file_name)), TRUE)

    # set datastore to mount and download. Just a check for errors
    set_datastore_to_download(ds)
    set_datastore_to_mount(ds)

    # tear down workspace and directory
    unlink(target_dir, recursive = TRUE)
})