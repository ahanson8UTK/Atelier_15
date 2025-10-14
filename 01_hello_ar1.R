# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon","ggplot2")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) {
  if ("gEcon" %in% to_install) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
  install.packages(setdiff(to_install, "gEcon"))
}
invisible(lapply(pkgs, library, character.only = TRUE))

# 1) Parse the .gcn and make the model
toy <- make_model("01_hello_ar1.gcn")  # parses → gecon_model object. :contentReference[oaicite:3]{index=3}

# 2) (Optional) overwrite rho from a quick data moment to show calibration idea
rho_hat <- with(ggplot2::economics, cor(uempmed[-1], uempmed[-nrow(ggplot2::economics)]))
toy <- set_free_par(toy, list(rho = ifelse(is.finite(rho_hat), rho_hat, 0.8)))

# 3) Steady state and first-order (log-)linear solution
toy <- steady_state(toy)               # :contentReference[oaicite:4]{index=4}
toy <- solve_pert(toy)                 # :contentReference[oaicite:5]{index=5}

# 4) Shock variance, IRF, plot
toy <- set_shock_cov_mat(toy, cov_matrix = matrix(0.01, 1, 1), shock_order = "eps_X")
irf <- compute_irf(toy, variables = c("X"), sim_length = 40)  # :contentReference[oaicite:6]{index=6}
plot_simulation(irf)                                          # see manual/guide. :contentReference[oaicite:7]{index=7}
