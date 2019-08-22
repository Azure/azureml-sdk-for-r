Before running the samples in Rstudio, change to the samples directory in Rstudio using `setwd(dirname)`.
The examples assume that the data and scripts are in the current directory.

- `setup.R`: Setup workspace before running samples.
- `create_cluster_start_remote_job.R`: Runs a remote job by creating a compute target and running `train.R`.
- `train.R` : Trains a glm model on the iris dataset and logs the metrics after training.
- `tensorflow/create_tensorflow_remote_job.R` : Runs a remote TensorFlow job by creating a compute target and running `tf_mnist.R`.
- `tensorflow/tf_mnist.R` : Trains a TensorFlow gradient descent model on the MNIST dataset.