# ---- packages: install if missing, then load quietly ----
pkgs <- c("gEcon","tidyverse","quantmod","tsibble","lubridate","zoo","ggplot2","rstudioapi")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) {
  if ("gEcon" %in% to_install) install.packages("gEcon", repos = "https://R-Forge.R-project.org")
  install.packages(setdiff(to_install, "gEcon"))
}
invisible(lapply(pkgs, library, character.only = TRUE))

# ---- diagnostics (robust in/out of RStudio) ----
r_ver <- R.version.string
rs_ver <- tryCatch({
  if (rstudioapi::isAvailable()) as.character(rstudioapi::versionInfo()$version) else "Not RStudio"
}, error = function(e) "Not RStudio")

cat("\nR version:", r_ver, "\n")
cat("RStudio version:", rs_ver, "\n")

if (Sys.info()[["sysname"]] == "Windows") message("Windows: if compilation errors appear, install Rtools (CRAN).")
if (Sys.info()[["sysname"]] == "Darwin")  message("macOS: if compilation errors appear, run in Terminal: xcode-select --install")

# Test that gEcon example models are visible
ex_path <- system.file("examples", package = "gEcon")
if (!dir.exists(ex_path) || !file.exists(file.path(ex_path, "rbc.gcn"))) {
  stop("❌ Could not find gEcon example models. Try reinstalling gEcon from R-Forge.")
}
cat("✅ READY — gEcon examples found at:", ex_path, "\n")
