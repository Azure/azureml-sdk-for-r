# check if ggplot2 and dplyr are already installed
library("ggplot2")
library("dplyr")

library(azureml)

log_metric_to_run("test_metric", 0.5, get_current_run())

# Uncomment once base image upgrades the sdk
#log_list_to_run("test_list", c(1, 2, 3))
#log_row_to_run("test_row", x = 1, y = 2)
#predict_json <- '{
#                    "schema_type": "predictions",
#                    "schema_version": "v1",
#                    "data": {
#                        "bin_averages": [0.25, 0.75],
#                        "bin_errors": [0.013, 0.042],
#                        "bin_counts": [56, 34],
#                        "bin_edges": [0.0, 0.5, 1.0]
#                    }
#                }'
#log_predictions_to_run("test_predictions", predict_json)