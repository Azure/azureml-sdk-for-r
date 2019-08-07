delete_aml_compute(existing_compute)
delete_workspace(existing_ws)

tryCatch(
{
  reticulate::conda_remove(test_env)
},
error = function(e) {
    NULL
})
