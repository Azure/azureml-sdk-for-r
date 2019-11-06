## Resubmission
This is a resubmission to address the following reviewer feedback:
* "Please write package names, software names and API names in single quotes (e.g. 'Azure') in Title and Description."
  * We have put the service name 'Azure Machine Learning' in single quotes in the Title and Description fields.
* Please ensure that your functions do not modify (save or delete) the user's home filespace in your examples/vignettes/tests. Please only write/save files if the user has specified a directory. In your examples/vignettes/tests you can write to tempdir().
  * We have updated our examples and tests to write to tempdir().


## Test environments
* local: windows-x86_64-devel
* azure devops: Ubuntu:16.04 LTS
* r-hub: windows-x86_64-devel, ubuntu-gcc-release
* win-builder: windows-x86_64-devel

## R CMD check results
0 errors | 0 warnings | 0 notes
