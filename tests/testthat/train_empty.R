package_uri <- "https://hichandostorage.blob.core.windows.net/bleeding/azureml_1.0.tar.gz"
devtools::install_url(package_uri, dep = FALSE)

library(azureml)

log_metric_to_run("test_metric", 0, get_current_run())