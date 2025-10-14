# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon","tidyverse","quantmod","tsibble","lubridate","zoo")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) {
  if ("gEcon" %in% to_install) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
  install.packages(setdiff(to_install, "gEcon"))
}
invisible(lapply(pkgs, library, character.only = TRUE))

# 0) Copy the official RBC .gcn from the package examples into THIS folder
file.copy(file.path(system.file("examples", package = "gEcon"), "rbc.gcn"),
          getwd(), overwrite = TRUE)  # Sample models reference. :contentReference[oaicite:8]{index=8}

# 1) Load the model
rbc <- make_model("rbc.gcn")  # parses & builds gecon_model. :contentReference[oaicite:9]{index=9}

# 2) Data (2000–2019): real GDP, real private investment, labor share
getSymbols(c("GDPC1","GPDIC1","LABSHPUSA156NRUG"), src = "FRED", auto.assign = TRUE)

# Merge on the union of dates; labor share is annual, others quarterly
X <- merge(GDPC1, GPDIC1, LABSHPUSA156NRUG, join = "left")

# Upsample annual labor share to quarterly by carrying its yearly value forward
X$LABSHPUSA156NRUG <- zoo::na.locf(X$LABSHPUSA156NRUG, fromLast = TRUE)

# Restrict to 2000–2019 window
X <- window(X, start = as.Date("2000-01-01"), end = as.Date("2019-12-31"))

# Build tidy table
fred <- tibble(
  date   = zoo::index(X),
  y      = as.numeric(X$GDPC1),
  i      = as.numeric(X$GPDIC1),
  lshare = as.numeric(X$LABSHPUSA156NRUG)
) |>
  mutate(qtr = yearquarter(date)) |>
  as_tsibble(index = qtr)

# Targets
IY_target <- mean(fred$i / fred$y, na.rm = TRUE)
labshare  <- mean(fred$lshare,     na.rm = TRUE)
alpha_hat <- 1 - labshare
beta_hat  <- 0.99

# Back out δ from steady-state I/Y:
# K/Y = α / (1/β - 1 + δ), and I/Y = δ * (K/Y)
f_delta <- function(delta){
  ky <- alpha_hat / (1/beta_hat - 1 + delta)
  delta*ky - IY_target
}
delta_hat <- uniroot(f_delta, c(0.001, 0.12))$root

# 3) Parameter handoff to the model
# IMPORTANT: In the official rbc.gcn, alpha is a CALIBRATED parameter (arrow -> alpha).
# To override it with our data-based alpha, we set it as an initial value for calibrated pars
# and call steady_state(calibration = FALSE). :contentReference[oaicite:10]{index=10}
rbc <- set_free_par(rbc, list(beta = beta_hat, delta = delta_hat))
rbc <- initval_calibr_par(rbc, calibr_par = list(alpha = alpha_hat))
rbc <- steady_state(rbc, calibration = FALSE)   # don't run built-in calibration; keep our alpha
rbc <- solve_pert(rbc)                          # 1st-order solution. :contentReference[oaicite:11]{index=11}

# (Optional) peek at eigenvalues / BK conditions
check_bk(rbc)                                   # :contentReference[oaicite:12]{index=12}

# 4) IRFs to a 1‑s.d. tech shock (epsilon_Z in the sample model). :contentReference[oaicite:13]{index=13}
rbc <- set_shock_cov_mat(rbc, cov_matrix = matrix(0.01, 1, 1), shock_order = "epsilon_Z")
irf <- compute_irf(rbc, variables = c("Y","C","I","K_s","W"), sim_length = 40)
plot_simulation(irf)
