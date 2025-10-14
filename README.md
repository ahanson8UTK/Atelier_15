# Atelier_15

# ECON 413 — gEcon Atelier (Local RStudio)

**Goal today (70–75 min):**  
1) Learn the `.gcn → make_model → solve → IRF` pipeline on a tiny toy model (no macro).  
2) Copy the official `rbc.gcn`, calibrate α and δ from data, solve, check BK, and plot IRFs.  
3) Make one safe edit (preference shock) and compare IRFs.  
4) Write a two‑sentence reflection and commit.

---

## Before class

- Install **R (≥4.2)** and **RStudio**.  
- Windows: if prompted later, install **Rtools**. macOS: install **Xcode Command Line Tools** (`xcode-select --install`).

---

## Open this project *correctly*

1. Launch **RStudio**.  
2. **File → Open Project…** and select `ECON413_gEcon_Atelier.Rproj`.  
3. Keep the **Console** visible.

---

## Step 0 — Check your setup (3–4 min)

1. Open `00_check_env.R`.  
2. Select all (Ctrl/Cmd‑A) → Run (Ctrl/Cmd‑Enter).  
   - It installs/loads packages and verifies access to gEcon examples.  
   - Look for: **“✅ READY — gEcon examples found at: …”**  
   - If you see a **❌** message, follow the on‑screen fix and re‑run the file.

---

## Step 1 — Hello, gEcon (toy AR(1), 7–8 min)

Purpose: practice the pipeline **without macro**.

1. Open `01_hello_ar1.gcn` (8 lines; defines an AR(1) with a shock).
2. Open `01_hello_ar1.R` and run it line‑by‑line.  
   - You should see an IRF plot for `X`.

**You did it if:** a plot appears and no errors show.

---

## Step 2 — RBC from data (15–20 min, pairs)

1. Open `02_rbc_setup.R` and run it line‑by‑line. It will:
   - Copy the official `rbc.gcn` into this folder (from the package examples).
   - Pull U.S. data (2000–2019) for GDP, Investment, and Labor Share.
   - Calibrate **α** from labor share and back out **δ** from the mean **I/Y** given β=0.99.
   - Solve the steady state (calibration **off** so your α is respected), run the perturbation, check BK, and plot IRFs for {Y, C, I, K_s, W}.

**You did it if:**  
- The steady state solves, `check_bk(rbc)` prints a OK summary, and IRFs plot.  
- If BK fails, re‑run after reading the printed hint.

---

## Step 3 — Tiny edit: add a **preference shock** (10–12 min)

1. Open `04_extend_prefshock.R` and follow the TODOs inside:  
   - Multiply utility by `Xi[]` in `rbc.gcn`.  
   - Add block `PREF` with AR(1) for `Xi[]` and a shock `epsilon_Xi[]`.  
   - Re‑solve, set a two‑shock covariance, and plot IRFs for {Y, C, I}.

**You did it if:** the new IRFs plot and look different from the tech‑shock IRFs.

---

## Step 4 — Reflection (3 min)

Open `05_reflection.Rmd` and write exactly **two sentences**:
1) Evidence: “With α from labor share and δ from I/Y, my model’s IRFs show …”  
2) Limits: “I’d be convinced we’re missing … because the data show … but the model insists …”

Knit (optional), then **Commit** with message: `irfs + reflection`.

---

## Troubleshooting hints

- **Package install fails (Windows)**: install **Rtools**; re‑run Step 0.  
- **Package install fails (macOS)**: run `xcode-select --install`; re‑run Step 0.  
- **Steady state fails**: re‑run after `initval_var()` guesses (see inline comments).  
- **BK error**: ensure you called `solve_pert()` before `check_bk()`.  
- **No IRF plot**: confirm `set_shock_cov_mat()` was called; check shock names.

---

## What to turn in (automatically handled by Git commit)

- Your edited `rbc.gcn` (preference shock), plus any scripts you touched.  
- Your `05_reflection.Rmd`.

