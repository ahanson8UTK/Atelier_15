# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
invisible(lapply(pkgs, library, character.only = TRUE))

# =========================================================
# GOAL: Add government spending G and lump-sum taxes T with
#       a balanced budget (T = G) + AR(1) fiscal shock.
#       Then solve & plot IRFs for {G, T, Y, C, I, L_s, W, r}.
# =========================================================
# ── WHAT YOU EDIT (inside rbc.gcn) ───────────────────────
# 1) In block CONSUMER, change the budget constraint line:
#    BEFORE:
#      I[] + C[] = pi[] + r[] * K_s[-1] + W[] * L_s[];
#    AFTER (add taxes on the uses side):
#      I[] + C[] + T[] = pi[] + r[] * K_s[-1] + W[] * L_s[];
#
# 2) At the end of the file, add a new block FISCAL:
#    block FISCAL {
#      identities {
#        G[] = exp(rho_G * log(G[-1]) + epsilon_G[]);
#        T[] = G[];     # balanced budget (lump-sum)
#      };
#      shocks { epsilon_G[]; };
#      calibration {
#        rho_G = 0.9;   # persistence of G
#        gY = 0.20;     # steady-state G/Y share (can tweak)
#        G[ss] = gY * Y[ss];
#      };
#    };
#
#    TIP: We do NOT add an explicit "Y = C + I + G" identity here.
#    In this sample model, goods market clearing follows from the
#    firm profit identity + the (now) taxed household budget.
#
# Save rbc.gcn, then run from here ↓
# ---------------------------------------------------------

# 1) Parse & (re)load the edited model
rbc <- make_model("rbc.gcn")         # parse .gcn → gecon_model. :contentReference[oaicite:1]{index=1}

# 2) Solve steady state (let the file’s calibration determine alpha, etc.)
rbc <- steady_state(rbc, calibration = TRUE)   # finds ss & calibrates. :contentReference[oaicite:2]{index=2}

# 3) First-order (log-)linear solution
rbc <- solve_pert(rbc)                         # Sims' gensys under the hood. :contentReference[oaicite:3]{index=3}

# 4) Shock covariance: technology (epsilon_Z) + fiscal (epsilon_G)
rbc <- set_shock_cov_mat(
  rbc,
  cov_matrix = diag(c(0.01, 0.01)),
  shock_order = c("epsilon_Z", "epsilon_G")
)

# 5) IRFs for key variables (note: "T" must be quoted; in R bare T means TRUE)
irf_fisc <- compute_irf(
  rbc,
  variables = c("G","T","Y","C","I","L_s","W","r"),
  sim_length = 40
)

# 6) Plot
plot_simulation(irf_fisc)

# ── OPTIONAL: Data-driven G/Y target (uncomment to try) ──
# # If you want gY to match U.S. data, estimate gY ≈ mean(G/Y) and push it:
# # (requires quantmod & friends; kept out here to keep this file minimal)
# # rbc <- set_free_par(rbc, list(gY = 0.18))  # example: set to 18%
# # rbc <- steady_state(rbc, calibration = TRUE); rbc <- solve_pert(rbc)
# # rbc <- set_shock_cov_mat(rbc, cov_matrix = diag(c(0.01, 0.01)),
# #                          shock_order = c("epsilon_Z","epsilon_G"))
# # irf_fisc <- compute_irf(rbc, variables = c("G","T","Y","C","I","L_s","W","r"), sim_length = 40)
# # plot_simulation(irf_fisc)
