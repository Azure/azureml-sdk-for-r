registerDoAMLComputeParallel <- function(ws, aml_cluster) {
  setDoPar(fun = .doAMLComputeBatch, data = list(
    ws = ws,
    cls = aml_cluster)
    , info = .info)
}

.info <- function(data, item){
  switch(item,
         workers = 2, #workers(data),
         name = "doAMLComputeBatch",
         version = packageDescription("doAMLComputeBatch", fields = "Version"),
         NULL)
}

.makeDotsEnv <- function(){
  list(...)
  function() NULL
}

.doAMLComputeBatch <- function(obj, expr, envir, data) {
  if (!inherits(obj, 'foreach'))
    stop('obj must be a foreach object')
  
  it <- iterators::iter(obj)
  argsList <- as.list(it)
  
  chunkSize <- 1
  jobTimeout <- 60 * 60 * 24
  
  if(!is.null(obj$options$azure$timeout)){
    jobTimeout <- obj$options$azure$timeout
  }
  
  exportenv <- tryCatch({
    qargs <- quote(list(...))
    args <- eval(qargs, envir)
    environment(do.call(.makeDotsEnv, args))
  },
  error=function(e) {
    new.env(parent=emptyenv())
  })
  noexport <- union(obj$noexport, obj$argnames)
  foreach::getexports(expr, exportenv, envir, bad = noexport)
  vars <- ls(exportenv)
  
  export <- unique(obj$export)
  ignore <- intersect(export, vars)
  if(length(ignore) > 0){
    export <- setdiff(export, ignore)
  }
  
  # add explicitly exported variables to exportenv
  if (length(export) > 0) {
    if (obj$verbose)
      cat(sprintf('explicitly exporting variables(s): %s\n',
                  paste(export, collapse=', ')))
    
    for (sym in export) {
      if (!exists(sym, envir, inherits=TRUE))
        stop(sprintf('unable to find variable "%s"', sym))

      val <- get(sym, envir, inherits=TRUE)
      #if (is.function(val) &&
      #    (identical(environment(val), .GlobalEnv) ||
      #     identical(environment(val), envir))) {
        # Changing this function's environment to exportenv allows it to
        # access/execute any other functions defined in exportenv.  This
        # has always been done for auto-exported functions, and not
        # doing so for explicitly exported functions results in
        # functions defined in exportenv that can't call each other.
      #  environment(val) <- exportenv
      #}
      assign(sym, val, pos=exportenv, inherits=FALSE)
    }
  }
  
  expr <- compiler::compile(expr, env=envir, options=list(suppressUndefined=TRUE))

  assign('expr', expr, .doAzureBatchGlobals)
  assign('exportenv', exportenv, .doAzureBatchGlobals)
  assign('packages', obj$packages, .doAzureBatchGlobals)

  num_processes <- 2L

  ntasks <- length(argsList)
  
  chunkSize <- ceiling(ntasks / num_processes)
  
  startIndices <- seq(1, length(argsList), chunkSize)
  endIndices <-
    if (chunkSize >= length(argsList)) {
      c(length(argsList))
    }
  else {
    seq(chunkSize, length(argsList), chunkSize)
  }
  
  if (length(startIndices) > length(endIndices)) {
    endIndices[length(startIndices)] <- ntasks
  }
  
  task_args <- list()
  for (i in 1:length(endIndices)) {
    task_args[[i]] <- argsList[startIndices[i]: endIndices[i]]
  }
  
  assign('task_args', task_args, .doAzureBatchGlobals)
  
  source_dir <- "parallel_exp"
  saveRDS(.doAzureBatchGlobals, file = file.path(source_dir, "envs.rds"))
  
  dist_backend <- azureml$core$runconfig$MpiConfiguration()
  dist_backend$process_count_per_node = num_processes
  
  image_registry_details <- azureml$core$container_registry$ContainerRegistry()
  image_registry_details$address <- "viennaprivate.azurecr.io"
  
  est <- estimator(source_directory = source_dir,
                   compute_target = data$cls,
                   entry_script = "parallel.py",
                   cran_packages = c("ggplot2"))

  run_config <- est$run_config
  run_config$framework <- "python"
  run_config$communicator <- "IntelMpi"
  run_config$mpi <- dist_backend 

  experiment_name <- "r-foreach"
  exp <- experiment(data$ws, experiment_name)
  run <- submit_experiment(exp, est)
  wait_for_run_completion(run, show_output = TRUE)
  
  # merge results
  download_dir <- "tmp"
  dir.create(download_dir)
  
  result <- list()
  result_index <- 1

  for (i in 1:num_processes) {
    file_name <- paste0("task_", i-1, ".rds")
    run$download_file(name = file.path("outputs", file_name), output_file_path = file.path(download_dir, file_name))
    
    task_data <- readRDS(file.path(download_dir, file_name))
    for (j in 1:length(task_data)) {
      result[[result_index]] <- task_data[[j]]
      result_index <- result_index + 1
    }
  }
  
  invisible(result)
  
}
