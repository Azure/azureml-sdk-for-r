context("webservice tests")

test_that("create webservice",
{
  ws <- existing_ws
  
  tmp_dir_name <- "tmp_dir"
  model_name <- "dummy_model.data"
  dir.create(tmp_dir_name)
  file.create(file.path(tmp_dir_name, model_name))
  
  # register the model
  model <- register_model(ws, tmp_dir_name, model_name)
  service <- deploy_model(ws, model, inference_config,
                           deployment_config = NULL, deployment_target = NULL)
  
  
  service_name <- "temp_service"
  service <- get_webservice(ws, name = model_name)
get_webservice
wait_for_deployment
get_webservice_logs
get_webservice_keys
delete_webservice
invoke_webservice
generate_new_webservice_key
get_webservice_token
serialize_webservice
deserialize_to_webservice
})