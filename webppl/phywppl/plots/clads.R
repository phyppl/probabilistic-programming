cat("ClaDS Models Evaluation")
cat(date())
rm(list = ls())
source("src/plotting-functions.R")
cairo_pdf("plots/clads.pdf", onefile = TRUE,  width = 7, height = 7,  pointsize = 8, fallback_resolution = 600)


# ClaDS[0-2] ------------------------------------------------------------------

source("plots/clads-input.R")
B1 = merge_plot(d1 = clads0, d2 = clads0_birch,
           x = "experiment",
           xlab = "Experiment #",
           d1_z = "clads0_means", d1_var = "clads0_var",
           d2_z = "mean", d2_var = "var",
           mtext = "Arrows denote ± 2 st. dev. of the estimate.",
           main = "ClaDS0 WebPPL vs BIRCH ClaDS0",
           low = -260, high = -140, legend = c("WebPPL", "BIRCH"),
           legendy = -240)[, c("lambda", "alpha", "sigma", "clads0_means", "clads0_var", "mean", "var", "particles", "PASS") ]

sink("plots/B1.tex")
cat(print(xtable(B1)), file = clads0_tex)
sink()


# Clads0 PANDA vs RPANDA  ------------------------------------------------------------------
source("plots/clads-input.R")
B2 = merge_plot(d1 = clads0_panda, d2 = clads0_rpanda,
           x = "experiment",
           xlab = "Experiment #",
           ylab = "corrected log Z",
           d1_z = "webppl_cmean", d1_var = "clads0_panda_var",
           d2_z = "rpanda_cmean", d2_var = "dummy",
           mtext = "Arrows denote ± 2 st. dev. of the estimate.",
           main = "ClaDS0 WebPPL vs RPANDA ClaDS0",
           low = -260, high = -140, legend = c("WebPPL", "RPANDA"),
           legendy = -240)[, c("lambda", "alpha", "sigma", "webppl_cmean", "clads0_panda_var", "rpanda_cmean", "particles", "PASS") ]

sink("plots/B2.tex")
cat(print(xtable(B2)), file = clads0_panda_tex)
sink()



# ClaDS1 -------------------------------------------------------------------------

source("plots/clads-input.R")
B3 = merge_plot(d1 = clads1, d2 = clads1_birch,
           x = "experiment",
           xlab = "Experiment #",
           d1_z = "clads1_means", d1_var = "clads1_var",
           d2_z = "mean", d2_var = "var",
           mtext = "Arrows denote ± 2 st. dev. of the estimate.",
           main = "WebPPL ClaDS1 vs BIRCH ClaDS1",
           low = -260, high = -140, legend = c("WebPPL", "BIRCH"),
           legendx = 45, legendy = -240)[, c("lambda", "alpha", "sigma", "clads1_means", "clads1_var", "mean", "var", "particles", "PASS") ]

sink("plots/B3.tex")
cat(print(xtable(B3)), file = clads1_tex)
sink()


# ClaDS2 Evalution -------------------------------------------------------------------------
source("plots/clads-input.R")

B4 = merge_plot(d1 = clads2, d2 = clads2_birch,
           x = "experiment",
           xlab = "Experiment #",
           d1_z = "clads2_means", d1_var = "clads2_var",
           d2_z = "clads2_birch_mean", d2_var = "clads2_birch_var",
           mtext = "Arrows denote ± 2 st. dev. of the estimate.",
           main = "WebPPL ClaDS2 vs BIRCH ClaDS2",
           low = -260, high = -140, legend = c("WebPPL", "BIRCH"),
           legendx = 45, legendy = -240)




# Clads0 grid2 ------------------------------------------------------------

source("plots/clads-input.R")
B5 = merge_plot(d1 = clads0_grid2, d2 = clads0_grid2_birch,
                x = "lambda",
                xlab = latex2exp::TeX("$\\lambda^o$"),
                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                d1_z = "clads0_means", d1_var = "clads0_var",
                d2_z = "mean", d2_var = "var",
                mtext = "B5",
                mtextcex = 0.8,
                main = "WebPPL ClaDS0 vs BIRCH ClaDS0",
                low = -155, high = -138, legend = c("WebPPL", "BIRCH"),
                tickw = 0.005, legendx = 0.25,
                legendy = -151)



# Clads1 grid2 ------------------------------------------------------------

source("plots/clads-input.R")
B6 = merge_plot(d1 = clads1_grid2, d2 = clads1_grid2_birch,
                x = "lambda",
                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                xlab = latex2exp::TeX("$\\lambda^o$"),
                d1_z = "clads1_means", d1_var = "clads1_var",
                d2_z = "mean", d2_var = "var",
                mtext = "B6",
                mtextcex = 0.8,
                main = "WebPPL ClaDS1 vs BIRCH ClaDS1",
                low = -155, high = -138, legend = c("WebPPL", "BIRCH"),
                tickw = 0.005, legendx = 0.25,
                legendy = -151)


# Clads2 grid2 ------------------------------------------------------------

source("plots/clads-input.R")
B7 = merge_plot(d1 = clads2_grid2, d2 = clads2_grid2_birch,
                x = "lambda",
                xlab = latex2exp::TeX("$\\lambda^o$"),
                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                d1_z = "clads2_means", d1_var = "clads2_var",
                d2_z = "mean", d2_var = "var",
                mtext = "B7",
                mtextcex = 0.8,
                main = "WebPPL ClaDS2  vs BIRCH ClaDS2",
                low = -155, high = -138, legend = c("WebPPL", "BIRCH"),
                tickw = 0.005, legendx = 0.25,
                legendy = -151)



# Clads0 vs RPANDA (analytical) ---------------------------------------------

source("plots/clads-input.R")
B8 = plot_vs_analytical_nogroup(d1 = clads0_panda_grid2,
                   d2 = clads0_rpanda_grid2,
                   meanvar = "clads0_panda_means",
                   mtext = "B8",
                   mtextcex = 1,
                   variance_var = "clads0_panda_var",
                   analytical_mean_var = "cmean",
                   xvar = "lambda", ylim = c(-70, -10), legengx = 0.05, legendy = -50,
                   xlab = latex2exp::TeX("$\\lambda_f$"),
                   ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                   main = "WebPPL ClaDS0 vs RPANDA ClaDS0",
                   legend_text = latex2exp::TeX("$\\alpha = 1$, $\\sigma = 0.05$ (R ClaDS0)") )


# Clads1 vs RPANDA (analytical) ---------------------------------------------

source("plots/clads-input.R")
B9 = plot_vs_analytical_nogroup(d1 = clads1_panda_grid2[clads1_panda_grid2$epsilon ==0,],
                                d2 = clads0_rpanda_grid2,
                                meanvar = "clads1_panda_means",
                                mtext = "B9",
                                mtextcex = 1,
                                variance_var = "clads1_panda_var",
                                analytical_mean_var = "cmean",
                                xvar = "lambda", ylim = c(-70, -10), legengx = 0.05, legendy = -50,
                                xlab = latex2exp::TeX("$\\lambda_f$"),
                                ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                main = "WebPPL ClaDS1 vs RPANDA ClaDS0",
                                legend_text = latex2exp::TeX("$\\epsilon = 0$, $\\alpha = 1$, $\\sigma = 0.05$ (analytical)")             )


# Clads2 vs RPANDA (analytical) ---------------------------------------------

source("plots/clads-input.R")
B10 = plot_vs_analytical_nogroup(d1 = clads2_panda_grid2[clads2_panda_grid2$epsilon == 0,],
                                d2 = clads0_rpanda_grid2,
                                meanvar = "clads2_panda_means",
                                mtext = "B10",
                                mtextcex = 1,
                                variance_var = "clads2_panda_var",
                                analytical_mean_var = "cmean",
                                xvar = "lambda", ylim = c(-70, -10), legengx = 0.05, legendy = -50,
                                xlab = latex2exp::TeX("$\\lambda_f$"),
                                ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                main = "WebPPL ClaDS2 vs RPANDA ClaDS0",
                                legend_text = latex2exp::TeX("$\\epsilon = 0$, $\\alpha = 1$, $\\sigma = 0.05$ (analytical)")           )



# RPANDA ClaDS[1-2] vs ClaDS0 ---------------------------------------------

source("plots/clads-input.R")

B11 = rpanda_vs_rpanda(d1 = clads2_rpanda_grid2[clads2_rpanda_grid2$epsilon == 0.0,],
                                d2 = clads0_rpanda_grid2,
                                meanvar = "clads2_likelihood_est",
                                mtext = "B11",
                                mtextcex = 1,
                                variance_var = NA,
                                analytical_mean_var = "likelihood_est",
                                xvar = "lambda", ylim = c(-40, 60), legengx = 0.05, legendy = -20,
                                xlab = latex2exp::TeX("$\\lambda_f$"),
                       ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                      colors = c( "#56B4E9B3", "#E69F00B3","#000000B3", "#009E73B3"),
                                main = "RPANDA ClaDS[1,2] vs RPANDA ClaDS0",
                                legend_text = c(NULL, latex2exp::TeX("$\\epsilon = 0$, $\\alpha = 1$, $\\sigma = 0.05$ (analytical)") ))




# WebPPL Clads2 (PANDA) vs RPANDA Clads2 (grid2) --------------------------
source("plots/clads-input.R")
B12 = plot_vs_analytical_onegroup(d1 = clads2_panda_grid2,
                                  d2 = clads2_rpanda_grid2,
                                  meanvar = "clads2_panda_means",
                                  variance_var =   "clads2_panda_var",
                                  analytical_mean_var = "clads2_cmean",
                                  main = "WebPPL ClaDS2 vs RPANDA ClaDS2",
                                  mtext = latex2exp::TeX("B12. $\\alpha = 1$  $\\sigma = 0.05$"),
                                  xlab = latex2exp::TeX("$\\lambda_f$"),
                                  ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                  groupvar1_name = "$\\epsilon$",
                                  legend_suff = "(RPANDA)",
                                  mtextcex = 1,
                                  legendx = 0.05,
                                  legendy = -50,
                                  ylim = c(-70, -10) )



# Β14 webppl clads1 vs rpanda clads1 --------------------------------------
source("plots/clads-input.R")
B14 = plot_vs_analytical_onegroup(d1 = clads1_panda_grid2,
                                  d2 = clads1_rpanda_grid2,
                                  meanvar = "clads1_panda_means",
                                  variance_var =   "clads1_panda_var",
                                  analytical_mean_var = "clads1_cmean",
                                  main = "WebPPL ClaDS1 vs RPANDA ClaDS1",
                                  mtext = latex2exp::TeX("B14. $\\alpha = 1$  $\\sigma = 0.05$"),
                                  xlab = latex2exp::TeX("$\\lambda_f$"),
                                  ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                  legend_suff = "$\\lambda_f$ (RPANDA)",
                                  mtextcex = 1,
                                  legendx = 0.05,
                                  legendy = -50,
                                  ylim = c(-70, -10))



# B13 - CRBD vs RPANDA vs PANDA -------------------------------------------
source("plots/clads-input.R")
B13 = plot_vs_analytical_onegroup(d1 = clads2_panda_grid3,
                                  d2 = clads2_rpanda_grid3,
                                  meanvar = "clads2_panda_means",
                                  variance_var =   "clads2_panda_var",
                                  analytical_mean_var = "clads2_cmean",
                                  main = "RPANDA ClaDS2 vs WebPPL ClaDS2 vs analytical CRBD",
                                  mtext = latex2exp::TeX("B13. $\\alpha = 1$  $\\sigma = 0.05$"),
                                  xlab = latex2exp::TeX("$\\lambda_f$"),
                                 xlim = c(0.018, 0.1),
                                 mtextcex = 1,
                                 ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                  legendx = 0.027,
                                  legendy = -45,
                                 groupvar1_name = "$\\mu \\equiv \\epsilon$",
                                 legend_suff = "(R ClaDS2)",
                                 colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"),
                                  ylim = c(-52, -15), tickw = 0.001, intersp = 1)

library(dplyr)
source("plots/crbd-input.R")
colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3")
# sorry about hardcoding :(
with(
   filter(crbd_analytical, epsilon == 0.0 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[1], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.1 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[2], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.5 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[3], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.9 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[4], lty = "solid")
   }
)

#legend(c("μ = 0 (CRB)", "μ = 0.1 λf (CRBD)", "μ = 0.5 λf (CRBD)", "μ = 0.9 λf (CRBD)"), col = colors, x = 0.054, y = -45, lty = "solid", bty = "n")
legend(
   latex2exp::TeX(
      c("$\\mu = 0$ (CRB)",
      "$\\mu = 0.1 \\lambda_f$ (CRBD)",
      "$\\mu = 0.5 \\lambda_f$ (CRBD)",
      "$\\mu = 0.9 \\lambda_f$ (CRBD)")
      ),
   col = colors,
   x = 0.054,
   y = -45,
   lty = "solid",
   bty = "n"
   )

legend(c("ε = 0 (W ClaDS2)", "ε = 0.1 (W ClaDS2)", "ε = 0.5 (W ClaDS2)", "ε = 0.9 (W ClaDS2)"), col = colors, x = 0.08, y = -45, pch = 3, bty = "n")


# B13 - CRBD vs RPANDA vs PANDA -------------------------------------------
source("plots/clads-input.R")
B15 = plot_vs_analytical_onegroup(d1 = clads1_panda_grid3,
                                  d2 = clads1_rpanda_grid3,
                                  meanvar = "clads1_panda_means",
                                  variance_var =   "clads1_panda_var",
                                  analytical_mean_var = "clads1_cmean",
                                  main = "RPANDA ClaDS1 vs WebPPL ClaDS1 vs analytical CRBD",
                                  mtext = latex2exp::TeX("B15. $\\alpha = 1$  $\\sigma = 0.05$"),
                                  xlab = latex2exp::TeX("$\\lambda_f$"),
                                  xlim = c(0.018, 0.1),
                                  mtextcex = 1,
                                  ylab =  latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                  legendx = 0.027,
                                  legendy = -45,
                                  legend_suff = "$\\lambda_f$ (R ClaDS1)",
                                  colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3"),
                                  ylim = c(-52, -15), tickw = 0.001, intersp = 1)



library(dplyr)
source("plots/crbd-input.R")
colors = c("#000000B3", "#E69F00B3", "#56B4E9B3", "#009E73B3")
# sorry about hardcoding :(
with(
   filter(crbd_analytical, epsilon == 0.0 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[1], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.1 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[2], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.5 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[3], lty = "solid")
   }
)

with(
   filter(crbd_analytical, epsilon == 0.9 & lambda <= 0.1),
   {
      lines(lambda, crbd_analytical_means + 128.7612, col = colors[4], lty = "solid")
   }
)

legend(
   latex2exp::TeX(c("$\\mu = 0$ (CRB)",
     "$\\mu = 0.1 \\lambda_f$ (CRBD)",
     "$\\mu = 0.5 \\lambda_f$ (CRBD)",
     "$\\mu = 0.9 \\lambda_f$ (CRBD)")),
   col = colors,
   x = 0.054,
   y = -45,
   lty = "solid",
   bty = "n")

legend(
   latex2exp::TeX(c("$\\mu = 0$ (W ClaDS1)",
     "$\\mu = 0.1 \\lambda_f$ (W ClaDS1)",
     "$\\mu = 0.5 \\lambda_f$ (W ClaDS1)",
     "$\\mu = 0.9 \\lambda_f$ (W ClaDS1)")),
   col = colors,
   x = 0.078,
   y = -45,
   pch = 3,
   bty = "n")




# -------------------------------------------------------------------------

dev.off()
