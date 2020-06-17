# LSBDS Evaluation --------------------------------------------------------
rm(list = ls())
source("src/plotting-functions.R")
cairo_pdf("plots/lsbds.pdf", onefile = TRUE, width = 7, height = 3.5, pointsize = 8, fallback_resolution = 600)
par(mfrow = c(1,2))

# C1 ---------------------------------------------------------
source("plots/lsbds-input.R")
C1 = merge_plot(d1 = lsbds[lsbds$rho == 1.0, ], d2 = lsbds_revbayes[lsbds_revbayes$rho == 1.0, ],
           x = "EXPECTED_NUM_EVENTS", xlab = "Expected Number of Rate Changes",
           d1_z = "lsbds_means", d1_var = "lsbds_var",
           d2_z = "revbayes", d2_var = "dummy",
           mtext = "C1",
           main = "WebPPL LSBDS vs RevBayes LSBDS (SCM)", arrowl = 0.02, legend = c("WebPPL", "RevBayes"), low = -170, high = -140,
           legendx = 6, legendy = -145, tickw = 0.05)



# C2 ----------------------------------------------------------------------
source("plots/lsbds-input.R")
C2 = merge_plot(d1 = lsbds_grid2, d2 = lsbds_grid2_birch[,-5],
           x = "EXPECTED_NUM_EVENTS", xlab = "Expected number of rate changes",
           d1_z = "lsbds_grid2_means", d1_var = "lsbds_grid2_var",
           d2_z = "birch_mean", d2_var = "birch_var",
           mtext = "C2",
           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
           mtextcex = 0.8,
           main = "WebPPL LSBDS vs Birch LSBDS", arrowl = 0.02, legend = c("WebPPL", "RevBayes"), low = -155, high = -138,
           legendx = 6, legendy = -142, tickw = 0.05)



# C3 ----------------------------------------------------------------------
source("plots/lsbds-input.R")
C3 = merge_plot(d1 = lsbds_grid2_birch,
                d2 = lsbds_grid2_revbayes,
                x = "EXPECTED_NUM_EVENTS",
                xlab = "Expected number of rate changes",
                d1_z = "birch_mean",
                d1_var = "birch_var",
                d2_z = "revbayes",
                d2_var = "dummy",
                mtext = "C3",
                mtextcex = 1,
                main = "Birch LSBDS vs RevBayes LSBDS",
                arrowl = 0.02, legend = c("Birch", "RevBayes"), low = -155, high = -140,
                legendx = 6, legendy = -142, tickw = 0.05)



# C4 ----------------------------------------------------------------------
source("plots/lsbds-input.R")
C4 = merge_plot(d1 = lsbds_grid2[, c("EXPECTED_NUM_EVENTS", "lsbds_grid2_means", "lsbds_grid2_var", "particles")],
                d2 = lsbds_grid2_revbayes,
                x = "EXPECTED_NUM_EVENTS",
                xlab = "Expected number of rate changes",
                d1_z = "lsbds_grid2_means",
                d1_var = "lsbds_grid2_var",
                d2_z = "revbayes",
                d2_var = "dummy",
                mtext = "C4",
                mtextcex = 1,
                main = "WebPPL LSBDS vs RevBayes LSBDS",
                arrowl = 0.02, legend = c("WebPPL", "RevBayes"), low = -155, high = -140,
                legendx = 6, legendy = -142, tickw = 0.05)





# WebPPL BAMM LSBDs WebPPL LSBDS-------------------------------------------------------------------------
source("plots/lsbds-input.R")
C5 = merge_plot(d2 = lsbds_grid2, d1 = bamm_grid2_lsbds,
                x = "EXPECTED_NUM_EVENTS",xlab = "Expected number of rate shifts",
                d2_z = "lsbds_grid2_means", d2_var = "lsbds_grid2_var",
                d1_z = "bamm_lsbds_means", d1_var = "bamm_lsbds_var",
                mtext = "C5",
                main = "WebPPL BAMM (z = 0) vs WebPPL LSBDS", tickw = 0.05, arrowl = 0.02, legend = c("WebPPL BAMM", "WebPPL LSBDS"),
                low = -155, high = -140, legendx = 7, legendy = -145)



# Birch BAMM (z = 0) vs Birch LSBDS-------------------------------------------------------------------------
source("plots/lsbds-input.R")
C6 = merge_plot(d1 = bamm_lsbds_birch_grid2[,-c(1)], d2 = lsbds_grid2_birch[,-c(1)],
                x = "EXPECTED_NUM_EVENTS",xlab = "Expected number of rate shifts",
                d1_z = "mean", d1_var = "var",
                d2_z = "birch_mean", d2_var = "birch_var",
                mtext = "C6",
                main = "Birch BAMM (z = 0) vs Birch LSBDS", tickw = 0.05, arrowl = 0.02, legend = c("Birch BAMM", "Birch LSBDS"),
                low = -155, high = -140, legendx = 7, legendy = -145)




# Cleanup -----------------------------------------------------------------

dev.off()

