# This is the auto-generated launcher file.
# It installs the packages specified in the estimator.
# Once all the packages are successfully installed, it will execute the entry script.

install.packages("caret", repos = "http://cran.us.r-project.org")

install.packages("optparse", repos = "http://cran.us.r-project.org")

install.packages("e1071", repos = "http://cran.us.r-project.org")

source("train.R")
