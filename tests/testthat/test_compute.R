context("compute tests")
source("utils.R")

test_that("create amlcompute", {
  skip_if_no_subscription()
  ws <- existing_ws

  vm_size <- "STANDARD_D2_V2"
  cluster_name <- paste("aml", build_num, sep = "")
  compute_target <- create_aml_compute(workspace = ws,
                                       cluster_name = cluster_name,
                                       vm_size = vm_size,
                                       max_nodes = 1)
  wait_for_provisioning_completion(compute_target)
  expect_equal(compute_target$name, cluster_name)

  compute_target <- get_compute(ws, cluster_name = cluster_name)
  expect_equal(compute_target$name, cluster_name)

  non_existent_cluster <- get_compute(ws, cluster_name = "nonexistent")
  expect_equal(non_existent_cluster, NULL)

  # tear down compute
  delete_compute(compute_target)
})

test_that("create akscompute", {
  skip('skip')
  ws <- existing_ws
  
  # create aks compute
  cluster_name <- paste("aks", build_num, sep = "")
  compute_target <- create_aks_compute(workspace = ws,
                                       cluster_name = cluster_name)
  wait_for_provisioning_completion(compute_target)
  expect_equal(compute_target$name, cluster_name)
  
  compute_target <- get_compute(ws, cluster_name = cluster_name)
  expect_equal(compute_target$name, cluster_name)

  # tear down compute
  delete_compute(compute_target)
})
