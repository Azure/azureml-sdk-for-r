context("compute tests")

test_that("create amlcompute",
{
    ws <- existing_ws

    vm_size <- "STANDARD_D2_V2"
    cluster_name <- paste("cls", build_num, sep="")
    compute_target <- create_aml_compute(workspace = ws, cluster_name = cluster_name, vm_size = vm_size, max_nodes = 1)
    wait_for_compute(compute_target)
    expect_equal(compute_target$name, cluster_name)

    compute_target <- get_compute(ws, cluster_name = cluster_name)
    expect_equal(compute_target$name, cluster_name)

    non_existent_cluster <- get_compute(ws, cluster_name = "nonexistent")
    expect_equal(non_existent_cluster, NULL)

    # tear down compute
    delete_compute(compute_target)
})