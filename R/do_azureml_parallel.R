# Copyright(c) Microsoft Corporation.
# Licensed under the MIT license.

#' Registers AMLCompute as a parallel backend with the foreach package.
#' @param workspace The Workspace object which has the compute_target.
#' @param compute_target The AMLCompute target to use for parallelization.
register_do_azureml_parallel <- function(workspace, compute_target) {
  foreach::setDoPar(fun = .do_azureml_parallel,
           data = list(
             ws = workspace,
             cls = compute_target),
           info = .info)
}

.info <- function(data, item) {
  switch(item,
         workers = workers(data),
         name = "doAzureMLParallel",
         version = utils::packageDescription("do_azureml_parallel",
                                             fields = "Version"),
         NULL)
}

.make_dots_env <- function(...) {
  list(...)
  function() NULL
}

workers <- function(data) {
  max_nodes <- data$cls$scale_settings$maximum_node_count
  max_nodes
}

.do_azureml_parallel <- function(obj, expr, envir, data) {
  if (!inherits(obj, "foreach"))
    stop("obj must be a foreach object")

  global_env <- new.env(parent = emptyenv())

  node_count <- 1L
  process_count_per_node <- 1L
  r_env <- NULL
  max_run_duration_seconds <- NULL

  if (!is.null(obj$args$job_timeout)) {
    max_run_duration_seconds <- obj$args$job_timeout
    obj$args$job_timeout <- NULL
  }

  if (!is.null(obj$args$node_count)) {
    node_count <- obj$args$node_count
    obj$args$node_count <- NULL
  }

  if (!is.null(obj$args$process_count_per_node)) {
    process_count_per_node <- obj$args$process_count_per_node
    obj$args$process_count_per_node <- NULL
  }

  if (!is.null(obj$args$r_env)) {
    r_env <- obj$args$r_env
    obj$args$r_env <- NULL
  }

  it <- iterators::iter(obj)
  args_list <- as.list(it)

  exportenv <- tryCatch({
    qargs <- quote(list(...))
    args <- eval(qargs, envir)
    environment(do.call(.make_dots_env, args))
  },
  error = function(e) {
    new.env(parent = emptyenv())
  })
  noexport <- union(obj$noexport, obj$argnames)
  packages <- getexports(expr, exportenv, envir, bad=noexport)
  packages = c(packages, obj$packages)
  vars <- ls(exportenv)

  export <- unique(obj$export)
  ignore <- intersect(export, vars)
  if (length(ignore) > 0) {
    export <- setdiff(export, ignore)
  }

  # add explicitly exported variables to exportenv
  if (length(export) > 0) {
    if (obj$verbose)
      cat(sprintf("explicitly exporting variables(s): %s\n",
                  paste(export, collapse = ", ")))

    for (sym in export) {
      if (!exists(sym, envir, inherits = TRUE))
        stop(sprintf('unable to find variable "%s"', sym))

      val <- get(sym, envir, inherits = TRUE)
      assign(sym, val, pos = exportenv, inherits = FALSE)
    }
  }

  assign("packages", obj$packages, global_env)

  expr <- compiler::compile(expr, env = envir,
                            options = list(suppressUndefined = TRUE))

  assign("expr", expr, global_env)
  assign("exportenv", exportenv, global_env)

  # divide args into MPI tasks
  task_args <- split_tasks(args_list, node_count, process_count_per_node)
  assign("task_args", task_args, global_env)

  source_dir <- paste0("foreach_run_", as.integer(Sys.time()))
  dir.create(source_dir)

  saveRDS(global_env, file = file.path(source_dir, "env.rds"))

  # submit estimator job to the cluster
  generate_entry_script(source_directory = source_dir)
  est <- estimator(source_directory = source_dir,
                   compute_target = data$cls,
                   entry_script = "entry_script.py",
                   environment = r_env,
                   max_run_duration_seconds = max_run_duration_seconds)

  dist_backend <- azureml$core$runconfig$MpiConfiguration()
  dist_backend$process_count_per_node <- process_count_per_node

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
  result <- merge_results(node_count, process_count_per_node, run, source_dir)

  # delete generated files
  unlink(source_dir, recursive = TRUE)
  invisible(result)
}

split_tasks <- function(args_list, node_count, process_count_per_node) {
  ntasks <- length(args_list)
  num_processes <- node_count * process_count_per_node
  chunk_size <- as.integer(ntasks / num_processes)

  if (chunk_size == 0L)
    stop(paste0("Number of arguments (currently, ", ntasks, ") should be ",
                "greater than or equal to number of processes ",
                "(currently, ", num_processes, ")"))

  start_indices <- seq(1, chunk_size * num_processes, chunk_size)
  end_indices <- seq(chunk_size, chunk_size * num_processes, chunk_size)

  end_indices[length(start_indices)] <- length(args_list)

  task_args <- list()
  for (i in seq_len(length(end_indices))) {
    task_args[[i]] <- args_list[start_indices[i]: end_indices[i]]
  }

  invisible(task_args)
}

merge_results <- function(node_count, process_count_per_node, run,
                          source_dir) {
  result <- list()
  num_processes <- node_count * process_count_per_node
  for (i in seq_len(num_processes)) {
    if (num_processes == 1) {
      file_name <- "task.rds"
    } else {
      file_name <- paste0("task_", i - 1, ".rds")
    }
    run$download_file(name = file.path("outputs", file_name),
                      output_file_path = file.path(source_dir, file_name))

    task_data <- readRDS(file.path(source_dir, file_name))
    result <- append(result, task_data)
  }

  invisible(result)
}

generate_entry_script <- function(source_directory) {
  r_launcher_script <- "
globalEnv <- readRDS(\"env.rds\")

task_rank <- Sys.getenv(\"OMPI_COMM_WORLD_RANK\", unset = NA)

if (is.na(task_rank)) {
  task_args <- globalEnv$task_args[[1L]]
  output_file <- \"task.rds\"
} else {
  task_rank <- as.integer(task_rank)
  task_args <- globalEnv$task_args[[task_rank + 1L]]
  output_file <- paste0(\"task_\", task_rank, \".rds\")
}

exportEnv <- globalEnv$exportenv
parent.env(exportEnv) <- globalenv()

for (p in globalEnv$packages)
  library(p, character.only=TRUE)

result <- lapply(task_args, function(args) {
  tryCatch({
    lapply(names(args), function(n)
      assign(n, args[[n]], pos = globalEnv$exportenv))

    eval(globalEnv$expr, envir=globalEnv$exportenv)
  },
  error = function(e) {
    print(e)
    traceback()
    e
  })
})

saveRDS(result, file = file.path(\"outputs\", output_file))
"
  write(r_launcher_script, file.path(source_directory, "launcher.R"))

  python_entry_script <- "
import rpy2.robjects as robjects

robjects.r.source(\"launcher.R\")
"
  write(python_entry_script, file.path(source_directory, "entry_script.py"))
}
