# BAMM Evaluation ---------------------------------------------------------
rm(list = ls())
source("src/plotting-functions.R")
cairo_pdf("plots/bamm.pdf", onefile = TRUE, width = 5, height = 5,  fallback_resolution = 600)



# E1 ----------------------------------------------------------------------


# . μ ~ Exp(1)
source("plots/lsbds-input.R")
source("plots/bamm-input.R")
E1 = merge_plot(d1 = lsbds, d2 = bamm_lsbds,
           x = "EXPECTED_NUM_EVENTS", xlab = "Expected Number of Rate Shifts",
           d1_z = "lsbds_means", d1_var = "lsbds_var",
           d2_z = "bamm_lsbds_means", d2_var = "bamm_lsbds_var",
           mtext = "E1",
           main = "WebPPL LSBDS vs WebPPL BAMM (z = 0)", tickw = 0.05, arrowl = 0.02, legend = c("LSBDS", "BAMM"),
           low = -170, high = -140, legendx = 8, legendy = -145)



# E3 ----------------------------------------------------------------------
source("plots/lsbds-input.R")
source("plots/bamm-input.R")
E3 = merge_plot(d1 = lsbds_grid2, d2 = bamm_lsbds_birch_grid2,
           x = "EXPECTED_NUM_EVENTS", xlab = "Expected Number of Rate Shifts",
           d1_z = "lsbds_means", d1_var = "lsbds_var",
           d2_z = "mean", d2_var = "var",
           mtext = "E3",
           main = "WebPPL LSBDS vs Birch BAMM (z = 0).",  low = -155, high = -140,
           legend = c("LSBDS", "BAMM"), legendx = 8, legendy = -142, tickw = 0.05, arrowl = 0.02)


# E4 Plots -------------------------------------------------------------------
source("plots/lsbds-input.R")
source("plots/bamm-input.R")
bamm$z = bamm$z_template
bamm_birch_results$z = bamm_birch_results$z_template
E4 = merge_plot(d1 = bamm, d2 = bamm_birch_results,
           x = "z",
           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
           d1_z = "bamm_means", d1_var = "bamm_var",
           d2_z = "birch_mean", d2_var = "birch_var",
           mtext = "E4",
           mtextcex = 0.8,
           main = "WebPPL BAMM vs Birch BAMM.", low = -155, high = -138, tickw = 0.001, arrowl= 0.05,
           legendx = -0.06, legendy = -151, legend = c("WebPPL", "BIRCH"))



# TDBD --------------------------------------------------------------------


## TDBD
source("plots/bamm-input.R")
E5 = merge_plot(d1 = bamm_tdbd, d2 = tdbd,
           x = "experiment",
           d1_z = "bamm_means", d1_var = "bamm_var",
           d2_z = "tdbd_means", d2_var = "tdbd_var",
           mtext = "Black: BAMM η = 0 (WebPPL). Red: TDBD (WebPPL). Arrows: ± 1 st. dev. of the est.",
           main = "BAMM Verification. η = 0", high = -135)




# -------------------------------------------------------------------------

source("plots/bamm-input.R")
#cairo_pdf(plot_tdbd_f, onefile = TRUE, width = 10, height = 10,  fallback_resolution = 600)
par(mfrow = c(3,3))
a = c("a", "b", "c", "d", "e", "f", "g", "h", "i")
i = 1
for (e in unique(bamm_tdbd$epsilon)) {
  for (l in unique(bamm_tdbd$lambda_0)) {
    print(e)
    print(l)
    merge_plot(d1 = bamm_tdbd[bamm_tdbd$epsilon == e & bamm_tdbd$lambda_0 == l, ],
               d2 = tdbd[tdbd$epsilon ==e & tdbd$lambda_0 ==l , ],
               x = "z",
               d1_z = "bamm_means", d1_var = "bamm_var",
               d2_z = "tdbd_means", d2_var = "tdbd_var",
               mtext = paste0("(", a[i], ")  ε = ", e, ", λ_0 = ", l),
               legend = c("ΒΑΜΜ", "TDBD"),
               main = NULL, tickw = 0.003, arrowl = 0.03, )
    i = i +1
  }
}

title("WebPPL BAMM vs WebPPL TDBD (η = 0)", outer=TRUE,  line=-2 )

# Cleanup -----------------------------------------------------------------
dev.off()

