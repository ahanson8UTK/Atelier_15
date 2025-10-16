# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# === TODOs for students (open rbc.gcn in the editor and make these edits) ===
# 1) In block CONSUMER, multiply utility by Xi[]:
#    BEFORE:
#      u[] = (C[]^mu * (1 - L_s[])^(1 - mu))^(1 - eta) / (1 - eta);
#    AFTER:
#      u[] = Xi[] * (C[]^mu * (1 - L_s[])^(1 - mu))^(1 - eta) / (1 - eta);
#
# 2) Add a new block at the end of rbc.gcn:
#    block PREF {
#      identities { Xi[] = exp(rho_Xi * log(Xi[-1]) + epsilon_Xi[]); };
#      shocks { epsilon_Xi[]; };
#      calibration { rho_Xi = 0.5; };
#    };

# === After saving rbc.gcn, run from here ===
rbc <- make_model("rbc.gcn")
# reuse baseline free params if desired (or comment this to use file defaults)
rbc <- set_free_par(rbc, list(beta = 0.99, delta = 0.025))
rbc <- steady_state(rbc, calibration = TRUE)
rbc <- solve_pert(rbc)

# two shocks now: epsilon_Z (tech) and epsilon_Xi (preference)
rbc <- set_shock_cov_mat(
  rbc,
  cov_matrix = diag(c(0.01, 0.01)),
  shock_order = c("epsilon_Z","epsilon_Xi")
)
irf_pref <- compute_irf(rbc, variables = c("Y","C","I"), sim_length = 40)
plot_simulation(irf_pref)
