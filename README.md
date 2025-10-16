# ECON 413 — gEcon Atelier (Local RStudio)

**Today’s goal (70–75 min):**
1) Learn the `.gcn → make_model → solve → IRF` pipeline on a tiny toy model (no macro).
2) Copy the official `rbc.gcn`, calibrate α and δ from data, solve, check BK, and plot IRFs.
3) Make one safe edit (preference shock) and compare IRFs.
4) Write a two‑sentence reflection and commit.

---

## START HERE — Get the project into RStudio (choose ONE)

> ✅ **Recommended (most reliable): Option A**  
> ❌ **Do NOT** double‑click random `.R` files. Always open the **project** first.

### Option A — Clone in RStudio (uses Git)
1. Open **RStudio**.
2. Go to **File → New Project → Version Control → Git**.
3. In **Repository URL**, paste your GitHub Classroom link:  
   `https://github.com/<your-classroom-org>/<this-assignment-repo>`
4. Choose a folder on your computer (e.g., `Documents/ECON413`).
5. Click **Create Project**.  
   RStudio will clone the repo and open `ECON413_gEcon_Atelier.Rproj`.

**You did it if:** you see the Files pane listing `00_check_env.R`, `01_hello_ar1.gcn`, etc., and the RStudio title bar ends with `ECON413_gEcon_Atelier`.

---

### Option B — Download ZIP (no Git required)
1. On the GitHub repo page, click the green **Code** button → **Download ZIP**.
2. Unzip the file.
3. Double‑click `ECON413_gEcon_Atelier.Rproj` inside the unzipped folder.  
   (If RStudio is closed, this will launch it and open the project.)

**You did it if:** RStudio opens in that folder and the Files pane shows the project files.

---

### Option C — GitHub Desktop
1. In **GitHub Desktop**, click **File → Clone repository…** and paste your Classroom URL.
2. After cloning, click **Open in RStudio**, or double‑click `ECON413_gEcon_Atelier.Rproj` in the cloned folder.

---

### Quick checks (applies to A/B/C)
- In RStudio: **Tools → Global Options → Git/SVN**  
  - If Git is *not* detected and you want to use Option A or C:
    - **Windows:** install “Git for Windows”.  
    - **macOS:** run `xcode-select --install` once if prompted.
- If GitHub asks for a password, use your **personal access token** (PAT).

---

## Step 0 — Check your setup

1. Open `00_check_env.R`.
2. Select all (**Ctrl/Cmd‑A**) → Run (**Ctrl/Cmd‑Enter**).

What you should see:
- A line like `✅ READY — gEcon examples found at: ...`
- If you see a red ❌ message, follow the on‑screen fix (Windows: install **Rtools**; macOS: run `xcode-select --install`) and re‑run the file.

---

## Step 1 — Hello, gEcon (toy AR(1))

**Purpose:** practice the pipeline without macro.

1. Open `01_hello_ar1.gcn` (8 lines; one AR(1) with a shock).
2. Open `01_hello_ar1.R` and run it line‑by‑line.

**Done when:** an IRF plot for `X` appears and no errors are printed.

---

## Step 2 — RBC from data

1. Open `02_rbc_setup.R` and run it line‑by‑line. It will:
   - Copy the official `rbc.gcn` into this folder (from the package examples).
   - Pull U.S. data (2000–2019) for GDP, Investment, and Labor Share.
   - Calibrate **α** from labor share; back out **δ** from the mean **I/Y** given β = 0.99.
   - Solve the steady state (with your α), run the perturbation, check BK, and plot IRFs for {Y, C, I, K_s, W}.

**Done when:** steady state solves, `check_bk(rbc)` returns OK info, and IRFs plot.

---

## Step 3A — Tiny edit: add a **preference shock**

1. Open `04_extend_prefshock.R` and follow the TODOs inside:
   - Multiply utility by `Xi[]` in `rbc.gcn`.
   - Add a `PREF` block with AR(1) for `Xi[]` and a shock `epsilon_Xi[]`.
   - Re‑solve; set a two‑shock covariance; plot IRFs for {Y, C, I}.
2. Compare IRFs with and without the preference shock.

**Done when:** new IRFs plot and differ from the tech‑shock IRFs.

---

## Step 3B — Tiny edit: add a **fiscal shock**

1. Open `04b_extend_fiscalshock.R` and follow the TODOs inside:
   - Add tax T[] to household budget constraint in `rbc.gcn`.
   - Add a `GOVERNMENT` block with AR(1) for `G[]` and a shock `eps_G[]`.
   - Re‑solve; set a two‑shock covariance; plot IRFs for all endogenous variables.
2. Compare IRFs across all three different shocks.

**Done when:** new IRFs plot and differ from the tech‑shock and preference-shock IRFs.

---

## Step 4 — Reflection

Open `05_reflection.Rmd` and write **two sentences**:

1. *Evidence:* With α from labor share and δ implied by I/Y, my model’s IRFs show **[pattern]**, especially **[variable(s)]** over **[horizon]**.  
2. *Limits:* I’d be convinced the model is missing **[mechanism]** because the data show **[fact]** while the model insists **[model pattern]**.

**Plus: answer two micro‑prompts (one from A and one from B). Keep each answer ≤ 25 words.**

**A. Preference shock**
- A1. *Margins:* Did the **preference shock** mostly move **consumption–saving** or **labor–leisure**? Point to the equation it touched (Euler vs. intratemporal FOC).  
- A2. *Signs & humps:* After a **+Ξ** shock, what happens on impact to {C, I, Y, L_s}? Which has the most pronounced hump, and why?  
- A3. *Persistence:* Change **ρ_Ξ** from 0.5 → 0.95. How do **amplitude** and **duration** of C’s IRF change?

Knit (optional), then **Commit** with message: `irfs + reflection`.

---

## Troubleshooting (read top to bottom)

- **Package install fails (Windows):** install **Rtools** (CRAN) and re‑run Step 0.  
- **Package install fails (macOS):** run `xcode-select --install` and re‑run Step 0.  
- **Steady state fails:** re‑run after Step 2 lines; check any printed equation residuals.  
- **BK error:** ensure you ran `solve_pert()` before `check_bk()`; review timing of any new variables.  
- **No IRF plot:** confirm you called `set_shock_cov_mat()`; check the **shock names** match the model.

---

## FAQ

**Q: Can I just open `02_rbc_setup.R` by double‑clicking it?**  
A: Please **don’t**. Always open the **`.Rproj`** first so all paths are correct.

**Q: I don’t have Git. Can I still do the assignment?**  
A: Yes—use **Option B (ZIP)** above.

**Q: Do I need a GitHub PAT?**  
A: Only if you clone via HTTPS and GitHub prompts for a password. The PAT goes in the password box.

---

## (Optional) Power‑user one‑liner: clone via `usethis`

```r
# ---- packages: install if missing, then load quietly ----
pkgs <- c("usethis")
to_install <- pkgs[!sapply(pkgs, requireNamespace, quietly = TRUE)]
if (length(to_install) > 0) install.packages(to_install)
invisible(lapply(pkgs, library, character.only = TRUE))

# Replace with your Classroom repo URL and desired folder:
usethis::create_from_github("https://github.com/<your-classroom-org>/<this-assignment-repo>",
                            destdir = "~/repos")
