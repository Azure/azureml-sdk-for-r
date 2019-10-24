# This is the auto-generated launcher file.
# It installs the packages specified in the estimator.
# Once all the packages are successfully installed, it will execute the entry script.

install.packages("tensorflow", repos = "http://cran.us.r-project.org")

source("tf_mnist.R")
