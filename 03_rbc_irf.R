# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# Re-load (uses your local rbc.gcn copy)
rbc <- make_model("rbc.gcn")
# For a quick rerun with textbook-ish values, uncomment the next line:
# rbc <- set_free_par(rbc, list(alpha = 0.33, beta = 0.99, delta = 0.025))
rbc <- steady_state(rbc, calibration = TRUE)
rbc <- solve_pert(rbc)
rbc <- set_shock_cov_mat(rbc, cov_matrix = matrix(0.01, 1, 1), shock_order = "epsilon_Z")
irf <- compute_irf(rbc, variables = c("Y","C","I","K_s","W"), sim_length = 40)
plot_simulation(irf)
