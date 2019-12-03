globalEnv <- readRDS("envs.rds")


task_rank <- Sys.getenv("OMPI_COMM_WORLD_RANK")
task_rank <- as.integer(task_rank)
#if (is.null(task_rank))
#  task_rank = Sys.getenv("PMI_RANK")

print(paste0("MPI Rank is: ", task_rank))

#startIndices <- globalEnv$startIndices
#endIndices <- globalEnv$endIndices
#argsList <- globalEnv$argsList

args <- globalEnv$task_args
task_args <- args[[task_rank + 1L]]
print(paste0("task_args ", task_args))


result <- lapply(task_args, function(args) {
  tryCatch({
    lapply(names(args), function(n)
      assign(n, args[[n]], pos = globalEnv$exportenv))

    print(ls(globalEnv$exportenv))    
    eval(globalEnv$expr, envir = globalEnv$exportenv)
  },
  error = function(e) {
    print(e)
    traceback()
    e
  })
})

print(result)
