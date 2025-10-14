# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon","quantmod","tidyverse","tsibble","lubridate","zoo")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) {
  if ("gEcon" %in% to_install) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
  install.packages(setdiff(to_install, "gEcon"))
}
invisible(lapply(pkgs, library, character.only = TRUE))

# =========================================================
# GOAL: Calibrate gY = mean(G/Y) from FRED, then solve & IRF
# Pre-req: rbc.gcn has been edited to include:
#   • Household budget: I[] + C[] + T[] = pi[] + r[] * K_s[-1] + W[] * L_s[];
#   • block FISCAL with: G[] AR(1), T[] = G[], calibration includes gY and G[ss] = gY * Y[ss].
# =========================================================

# 0) Pull data (2000–2019): GDPC1 (real GDP), GCEC1 (real gov't C+I)
getSymbols(c("GDPC1","GCEC1"), src = "FRED", auto.assign = TRUE)

fred <- tibble(
  date = zoo::index(GDPC1),
  y    = as.numeric(GDPC1),
  g    = as.numeric(GCEC1[zoo::index(GDPC1)])
) |>
  filter(date >= as.Date("2000-01-01"), date <= as.Date("2019-12-31")) |>
  mutate(qtr = yearquarter(date)) |>
  as_tsibble(index = qtr)

gY_hat <- mean(fred$g / fred$y, na.rm = TRUE)
cat(sprintf("\nEstimated steady-state government share gY ≈ %.3f\n", gY_hat))

# 1) Parse the edited model
rbc <- make_model("rbc.gcn")

# 2) Push data-driven gY, then solve & check
rbc <- set_free_par(rbc, list(gY = gY_hat))
rbc <- steady_state(rbc, calibration = TRUE)
rbc <- solve_pert(rbc)

# 3) Set shocks: epsilon_Z (TFP) and epsilon_G (fiscal)
rbc <- set_shock_cov_mat(
  rbc,
  cov_matrix = diag(c(0.01, 0.01)),
  shock_order = c("epsilon_Z","epsilon_G")
)

# 4) IRFs (note: pass "T" as a string—bare T is TRUE in R)
irf_fisc_data <- compute_irf(
  rbc,
  variables = c("G","T","Y","C","I","L_s","W","r"),
  sim_length = 40
)

plot_simulation(irf_fisc_data)
