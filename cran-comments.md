## Resubmission 2019-11-11 (latest)
This is a resubmission to address the following reviewer feedback:
* Please shorten the title to a maximum of 65 characters. Acronyms can be used on their own in the title as long as they are explained in the description field.
  * We have shortened the title to be <65 characters. Title now contains only the acronym 'SDK', and the full term 'Software Development Kit' is in the description.
* Please add \value to .Rd files that are not data files and explain the functions results in the documentation.
f.i.: detach_aks_compute.Rd - If your function does not return a value, please document that too, e.g. \value{None}.
  * We have added \value to all functions (and the subsequently generated .Rd files), including \value{None} for the functions that do not return anything.

## Resubmission 2019-11-06
This is a resubmission to address the following reviewer feedback:
* "Please write package names, software names and API names in single quotes (e.g. 'Azure') in Title and Description."
  * We have put the service name 'Azure Machine Learning' in single quotes in the Title and Description fields.
* "Please ensure that your functions do not modify (save or delete) the user's home filespace in your examples/vignettes/tests. Please only write/save files if the user has specified a directory. In your examples/vignettes/tests you can write to tempdir()."
  * We have updated our examples and tests to write to tempdir().
  
## Resubmission 2019-11-04
This is a resubmission to address the following reviewer feedback:
* "It seems that the actual authors of tensorflow are still missing."
  * We have added "The TensorFlow Authors" in our DESCRIPTION file Authors@R field.

## Resubmission 2019-10-28
This is a resubmission to address the following reviewer feedback:
* "Please always add all authors and copyright holders in the Authors@R field with the appropriate roles."
  * In our vignette we reference [RStudio Tensorflow's](https://github.com/rstudio/tensorflow) sample tutorial, so we have added "Google Inc." (for TensorFlow authors) and "RStudio Inc." to the Authors@R field with the "cph" role for "Examples and Tutorials."
* "Please omit the redundant "R"  from the title and description."
  * We have removed the redundant "R" from the title and description.
* "Please elaborate and add a link in the form `<http:...>` or `<https:...>` with angle brackets for auto-linking and no space after 'http:' and 'https:'."
  * We have elaborated on the description to explain what the package is for and added a link to the Azure Machine Learning website.
* "Please put the examples in `\examples`."
  * We have put the examples in `\examples` with the @examples tag instead of the generic @section tag. Please note that most of the examples are in `\dontrun` since they require an Azure subscription to be run (to access the Azure resources).
  
## Resubmission 2019-10-25
This is a resubmission to address the following reviewer feedback:
* "Possibly mis-spelled words in DESCRIPTION: SDK (3:32)"
  * We have put 'SDK' in single quotes in Title and Description.
* "Found (possibly) invalid URLs in README.md"
  * We fixed the URLs in README.md to point to valid publicly accessible links.

## Test environments
* local: windows-x86_64-devel
* azure devops: Ubuntu:16.04 LTS
* r-hub: windows-x86_64-devel, ubuntu-gcc-release
* win-builder: windows-x86_64-devel

## R CMD check results
0 errors | 0 warnings | 0 notes
