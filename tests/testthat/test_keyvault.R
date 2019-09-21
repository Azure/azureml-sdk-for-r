context("keyvault")

test_that("keyvault tests, list/set/get/delete secrets",
{
  ws <- existing_ws
  kv <- get_default_keyvault(ws)
  expect_equal(length(list_secrets(kv), 0))
  
  set_secrets(kv, list("secret1" = "value1", "secret2" = "value2"))
  expect_equal(length(list_secrets(kv), 2))
  expect_equal(get_secrets(kv, list("secret1"))$secret1, "value1")
  
  delete_secrets(kv, list("secret1"))
  expect_equal(get_secrets(kv, list("secret1"))$secret1, NULL)
  expect_equal(length(list_secrets(kv), 1))
})