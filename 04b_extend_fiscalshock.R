# packages: install quietly if needed, then load
pkgs <- c("gEcon","ggplot2","tidyr","dplyr","paletteer")
need <- setdiff(pkgs, rownames(installed.packages()))
if ("gEcon" %in% need) install.packages("gEcon", repos = "http://R-Forge.R-project.org", quiet = TRUE)
if (length(setdiff(need, "gEcon")) > 0) install.packages(setdiff(need, "gEcon"), repos = "https://cloud.r-project.org", quiet = TRUE)
invisible(lapply(pkgs, function(p) suppressPackageStartupMessages(library(p, character.only = TRUE))))

# === TODOs for students (open rbc.gcn in the editor and make these edits) ===
# 1) In block CONSUMER, add T[] to the expenses (lump sum tax)
#    BEFORE:
#      I[] + C[] = pi[] + r[] * K_s[-1] + W[] * L_s[]
#            - psi * K_s[-1] * (I[] / K_s[-1] - delta)^2;
#    AFTER:
#      I[] + C[] + T[] = pi[] + r[] * K_s[-1] + W[] * L_s[]
#            - psi * K_s[-1] * (I[] / K_s[-1] - delta)^2;
#
# 2) Add a new block at the end of rbc.gcn:
#    block GOVERNMENT
#{
#    identities
#    {
#        g_til[] = rho_G * g_til[-1] + sigma_G * eps_G[];
#        G[]     = G_bar * exp(g_til[]);
#        T[]     = G[];          # balanced budget each period
#    };
#    shocks { eps_G[]; };
#    calibration
#    {
#        gy      = 0.20;         # steady-state G/Y target (tuneable)
#        rho_G   = 0.90;
#        sigma_G = 0.01;
#        G_bar = gy * Y[ss] -> G_bar;   # calibrate level to your Y[ss]
#    };
#};


# Build model, compute steady state and linear solution
m <- make_model("rbc.gcn")
m <- steady_state(
  m,
  calibration = TRUE,
  use_jac     = TRUE,
  options_list = list(method = "Broyden", global = "gline", max_iter = 300, tol = 1e-7)
)
m <- solve_pert(m)

# (Optional) set a simple identity covariance across shocks so cholesky = FALSE gives 1-unit shocks
shock_names <- get_shock_names(m)
cov <- diag(length(shock_names)); dimnames(cov) <- list(shock_names, shock_names)
m <- set_shock_cov_mat(m, cov_matrix = cov, shock_order = shock_names)

# IRFs to government spending shock
irf_g <- compute_irf(m, variables = c("Y","C","I","G","L_s","W","r"), shocks = "eps_G", sim_length = 40, cholesky = FALSE)

# ---- helper: plot IRFs with paletteer discrete palette ----
plot_irf_paletteer <- function(irf_obj,
                               palette = "ggthemes::Tableau_10",   # try "khroma::bright", "cartography::green.pal", etc.
                               base_size = 12,
                               linetype_by_variable = FALSE) {
  # 1) gather IRF matrices (one per shock) into long data
  lst <- get_simulation_results(irf_obj)  # list of matrices: vars x time
  df  <- dplyr::bind_rows(lapply(names(lst), function(s) {
    M <- lst[[s]]
    d <- as.data.frame(t(M))                      # time on rows
    d$horizon <- seq_len(nrow(d)) - 1
    tidyr::pivot_longer(d, -horizon,
                        names_to = "variable", values_to = "value") |>
      dplyr::mutate(shock = s)
  }))
  
  # 2) build a discrete palette from paletteer (expand if vars > palette length)
  vars <- unique(df$variable)
  raw_cols <- as.character(paletteer::paletteer_d(palette))
  if (length(raw_cols) < length(vars)) {
    # expand gracefully if there are many variables
    raw_cols <- grDevices::colorRampPalette(raw_cols)(length(vars))
  } else {
    raw_cols <- raw_cols[seq_along(vars)]
  }
  cols <- setNames(raw_cols, vars)
  
  # 3) plot
  aes_map <- aes(horizon, value, color = variable)
  if (linetype_by_variable) aes_map$linetype <- quote(variable)
  
  ggplot(df, aes_map) +
    geom_hline(yintercept = 0, linewidth = 0.3) +
    geom_line(linewidth = 1) +
    facet_wrap(~ shock, scales = "free_y") +
    scale_color_manual(values = cols, name = NULL) +
    { if (linetype_by_variable) scale_linetype_discrete(name = NULL) else NULL } +
    labs(x = "quarters after shock", y = "response (log dev.)", title = "IRFs") +
    theme_minimal(base_size = base_size) +
    theme(legend.position = "bottom")
}


# fiscal shock IRFs
p1 <- plot_irf_paletteer(irf_g, palette = "wesanderson::Darjeeling1", linetype_by_variable = TRUE)

print(p1)

# preference shock IRFs
irf_xi <- compute_irf(m, variables = c("Y","C","I","G","L_s","W","r"), shocks = "epsilon_Xi", sim_length = 40, cholesky = FALSE)

p2 <- plot_irf_paletteer(irf_xi, palette = "wesanderson::Darjeeling1", linetype_by_variable = TRUE)

# tech shock IRFs
irf_z <- compute_irf(m, variables = c("Y","C","I","G","L_s","W","r"), shocks = "epsilon_Z", sim_length = 40, cholesky = FALSE)

p3 <- plot_irf_paletteer(irf_z, palette = "wesanderson::Darjeeling1", linetype_by_variable = TRUE)

print(p2)
