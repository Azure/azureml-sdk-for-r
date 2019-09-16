context("model tests")

test_that("get, register, download, serialize, deserialize and delete model",
{
    ws <- existing_ws
    
    tmp_dir_name <- "tmp_dir"
    model_name <- "dummy_model.data"
    dir.create(tmp_dir_name)
    file.create(file.path(tmp_dir_name, model_name))
    
    # register the model
    model <- register_model(ws, tmp_dir_name, model_name)
    
    # get model
    ws_model <- get_model(ws, model_name)

    expect_equal(model_name, ws_model$name)

    # download model    
    download_dir <- "downloaded"
    dir.create(download_dir)
    path <- download_model(model, download_dir)
    expect_equal(file.exists(file.path(download_dir, tmp_dir_name, model_name)), TRUE)
    
    # serialize and deserialize model
    model_payload <- serialize_model(model)
    deserialized_model <- deserialize_to_model(ws, model_payload)

    # delete the model
    delete_model(model)
})
