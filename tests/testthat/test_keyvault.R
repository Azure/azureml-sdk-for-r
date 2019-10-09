context("keyvault")

test_that("keyvault tests, list/set/get/delete secrets",
{
  ws <- existing_ws
  kv <- get_default_keyvault(ws)
  expect_gte(length(list_secrets(kv)), 0)
  
  secret_name <- paste0("secret", gsub("-", "", build_num))
  secret_value <- paste0("value", gsub("-", "", build_num))
  secrets <- list()
  secrets[[ secret_name ]] <- secret_value
  
  set_secrets(kv, secrets)
  expect_equal(get_secrets(kv, list(secret_name))[[ secret_name ]], 
               secret_value)
  
  delete_secrets(kv, list(secret_name))
  expect_equal(get_secrets(kv, list(secret_name))[[ secret_name ]], 
               NULL)
})