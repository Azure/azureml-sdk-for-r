library(testthat)
library(azuremlsdk)

if (identical(Sys.getenv("NOT_CRAN"), "true")) {
  test_check("azuremlsdk") 
}