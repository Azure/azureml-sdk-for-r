ws <- load_workspace_from_config()
cls <- get_compute(ws, "hesuricls")

ws_prod <- get_workspace("hesuri_eastus", subscription_id = ws$subscription_id, resource_group = "hesuri")
cls_prod <- get_compute(ws_prod, "hesuricluster")

detach('package:azuremlsdk', unload = TRUE)
pkg <- devtools::build()
install.packages(pkg, repos = NULL)


library(azuremlsdk)
library(foreach)
library(iterators)
devtools::load_all()


.doAzureBatchGlobals <- new.env(parent = emptyenv())


run_prod <- 1


if (run_prod == 0) {
  registerDoAMLComputeParallel(ws, cluster)
} else {
  registerDoAMLComputeParallel(ws_prod, cls_prod)
}

x <- seq(-1, 1, by=0.5)

v <- foreach(w = 1:10) %dopar% {
  res <- x+w
}

