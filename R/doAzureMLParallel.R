registerDoAzureMLParallel <- function(workspace, compute_target) {
  foreach::setDoPar(fun = .doAzureMLParallel,
           data = list(
             ws = workspace,
             cls = compute_target),
           info = .info)
}

.info <- function(data, item){
  switch(item,
         workers = workers(data),
         name = "doAzureMLParallel",
         version = packageDescription("doAzureMLParallel", fields = "Version"),
         NULL)
}

.makeDotsEnv <- function(){
  list(...)
  function() NULL
}

workers <- function(data) {
  invisible(2)
}

.doAzureMLParallel <- function(obj, expr, envir, data) {
  if (!inherits(obj, 'foreach'))
    stop('obj must be a foreach object')
  
  node_count <- 1L
  process_count_per_node <- 1L
  r_env <- NULL
  max_run_duration_seconds <- NULL
  
  if(!is.null(obj$args$job_timeout)){
    max_run_duration_seconds <- obj$args$job_timeout
    obj$args$job_timeout <- NULL
  }
  
  if(!is.null(obj$args$node_count)){
    node_count <- obj$args$node_count
    obj$args$node_count <- NULL
  }
  
  if(!is.null(obj$args$process_count_per_node)){
    process_count_per_node <- obj$args$process_count_per_node
    obj$args$process_count_per_node <- NULL
  }

  if(!is.null(obj$args$r_env)){
    r_env <- obj$args$r_env
    obj$args$r_env <- NULL
  }

  it <- iterators::iter(obj)
  argsList <- as.list(it)

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
      assign(sym, val, pos=exportenv, inherits=FALSE)
    }
  }
  
  expr <- compiler::compile(expr, env=envir, options=list(suppressUndefined=TRUE))

  assign('expr', expr, .doAzureBatchGlobals)
  assign('exportenv', exportenv, .doAzureBatchGlobals)
  assign('packages', obj$packages, .doAzureBatchGlobals)

  # divide args into MPI tasks
  ntasks <- length(argsList)
  num_processes <- node_count*process_count_per_node
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
  
  source_dir <- paste0("foreach_project_", as.integer(Sys.time()))
  dir.create(source_dir)
  
  saveRDS(.doAzureBatchGlobals, file = file.path(source_dir, "envs.rds"))
  
  # submit estimator job to the cluster  
  create_entry_script(source_directory = source_dir)
  est <- estimator(source_directory = source_dir,
                   compute_target = data$cls,
                   entry_script = "entry_script.py",
                   environment = r_env,
                   max_run_duration_seconds = max_run_duration_seconds)

  dist_backend <- azureml$core$runconfig$MpiConfiguration()
  dist_backend$process_count_per_node = process_count_per_node

  run_config <- est$run_config
  run_config$framework <- "python"
  run_config$communicator <- "IntelMpi"
  run_config$mpi <- dist_backend 
  run_config$node_count <- node_count

  experiment_name <- "r-foreach"
  exp <- experiment(data$ws, experiment_name)
  run <- submit_experiment(exp, est)
  wait_for_run_completion(run, show_output = TRUE)
  
  # merge results
  download_dir <- source_dir
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
  
  # delete generated files
  unlink(source_dir, recursive = TRUE)
  
  invisible(result)
}

create_entry_script <- function(source_directory) {
  r_launcher_script <- "
globalEnv <- readRDS(\"envs.rds\")

task_rank <- Sys.getenv(\"OMPI_COMM_WORLD_RANK\")
if (is.null(task_rank))
  task_rank = Sys.getenv(\"PMI_RANK\")

task_rank <- as.integer(task_rank)

args <- globalEnv$task_args
task_args <- args[[task_rank + 1L]]

result <- lapply(task_args, function(args) {
  tryCatch({
    lapply(names(args), function(n)
      assign(n, args[[n]], pos = globalEnv$exportenv))

    eval(globalEnv$expr, envir = globalEnv$exportenv)
  },
  error = function(e) {
    print(e)
    traceback()
    e
  })
})

saveRDS(result, file = file.path(\"outputs\", paste0(\"task_\", task_rank, \".rds\")))
"
  write(r_launcher_script, file.path(source_directory, "launcher.R"))
  
  
  python_entry_script <- "
import rpy2.robjects as robjects

robjects.r.source(\"launcher.R\")
"
  write(python_entry_script, file.path(source_directory, "entry_script.py"))
  
}
