tryCatch( {
  reticulate::conda_remove(test_env)
},
error = function(e) {
    NULL
})
