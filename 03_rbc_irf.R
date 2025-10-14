# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# Re-load (uses your local rbc.gcn copy)
rbc <- make_model("rbc.gcn")
# Parameter handoff to the model (REPLACE alpha_hat, beta_hat, and delta_hat with your estimates from before!)
# IMPORTANT: In the official rbc.gcn, alpha is a CALIBRATED parameter (arrow -> alpha).
# To override it with our data-based alpha, we set it as an initial value for calibrated pars

rbc <- set_free_par(rbc, list(beta = beta_hat, delta = delta_hat))
rbc <- initval_calibr_par(rbc, calibr_par = list(alpha = alpha_hat))
rbc <- steady_state(rbc, calibration = TRUE)
rbc <- solve_pert(rbc)
rbc <- set_shock_cov_mat(rbc, cov_matrix = matrix(0.01, 1, 1), shock_order = "epsilon_Z")
irf <- compute_irf(rbc, variables = c("Y","C","I","K_s","W"), sim_length = 40)
plot_simulation(irf)
