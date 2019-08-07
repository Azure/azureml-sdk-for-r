Before running the samples in Rstudio, change to the samples directory in Rstudio using `setwd(dirname)`.
The examples assume that the data and scripts are in the current directory.

- `setup.R`: Setup workspace before running samples.
- `start_remote_job.R`: Runs a remote r job using the default compute attached to the workspace.
- `create_cluster_start_remote_job.R`: Runs the remote job by creating a compute and running `train.R`

`train.R` : Trains a glm model on the iris dataset.
Logs the metrics after training.