globalEnv <- readRDS("envs.rds")


task_rank <- Sys.getenv("OMPI_COMM_WORLD_RANK")
if (is.null(task_rank))
  task_rank = Sys.getenv("PMI_RANK")

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

saveRDS(result, file = file.path("outputs", paste0("task_", task_rank, ".rds")))
