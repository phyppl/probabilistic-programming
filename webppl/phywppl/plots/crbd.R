# Init --------------------------------------------------------------------
rm(list = ls())
source("src/plotting-functions.R")

cat("\n")
cat("Evaluation of CRBD\n")
cat("==================\n")
cat("\n")
cat(date())
cat("\n")
cat("Please, run from the phywppl package directory.\n")
cat("Directory is now", getwd(), "\n")

# ----

cairo_pdf("plots/crbd.pdf", onefile = TRUE, width = 7, height = 7, pointsize = 8, fallback_resolution = 600)
#par(mfrow = c(4,3))



library(dplyr)
library(readr)
library(rppl)


# Settings --------------------------------------------------------------------


## Settings
## number of edges in the tree
nedges = 62

## directories and files

tdbd_f              = "verification/tdbd/tdbd-results.JSON"
tdbd_analytical_f   = "verification/tdbd/tdbd-analytical-results.JSON"
tdbd_birch_f        = "verification/tdbd/tdbd-birch.csv"

tdbd_grid2_f            = "verification/tdbd/tdbd-grid2-results.JSON"
tdbd_grid2_rho_f            = "verification/tdbd/tdbd-grid2-rho-results.JSON"
tdbd_grid2_analytical_f = "verification/tdbd/tdbd-grid2-analytical-results.JSON"
tdbd_grid2_analytical_rho_f = "verification/tdbd/tdbd-grid2-analytical-rho-results.JSON"

bamm_tdbd_grid2_f       = "verification/tdbd/bamm-tdbd-grid2-results.JSON"

plot_f              = "verification/tdbd/tdbd-plot.pdf"


# Input -------------------------------------------------------------------


#setwd(workdir)
tdbd = read_model(model = "tdbd", modelf = tdbd_f, reps = 12 )
tdbd$experiment = 1:nrow(tdbd)
tdbd = tdbd[, -sapply(c("tree", "lambdaFun", "muFun", "rho", "MAX_DIV", "MAX_LAMBDA", "MIN_LAMBDA" ), grep, colnames(tdbd) )]
tdbd_birch =  read_delim(tdbd_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
# order of the parameters in the filename: lambda, epsilon, z (edited)
tdbd_birch$z   = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = tdbd_birch$File, split = "_"), function(l) { l[5] } ) ) )
tdbd_birch$z[tdbd_birch$z == 0.00001] = 0
tdbd_birch$epsilon   = as.numeric(  sapply(strsplit(x = tdbd_birch$File, split = "_"), function(l) { l[4] } ) )
tdbd_birch$lambda_0   = as.numeric(  sapply(strsplit(x = tdbd_birch$File, split = "_"), function(l) { l[3] } ) )

tdbd_grid2 = read_model(model = "tdbd", modelf = tdbd_grid2_f, reps = 12 )
tdbd_grid2$experiment = 1:nrow(tdbd_grid2)

tdbd_grid2_rho = read_model(model = "tdbd", modelf = tdbd_grid2_rho_f, reps = 12 )
tdbd_grid2_rho$experiment = 1:nrow(tdbd_grid2_rho)

tdbd_grid2_analytical = read_model(model = "tdbd_analytical", modelf = tdbd_grid2_analytical_f, reps = 1 )
tdbd_grid2_analytical$experiment = 1:nrow(tdbd_grid2_analytical)

tdbd_grid2_analytical_rho = read_model(model = "tdbd_analytical", modelf = tdbd_grid2_analytical_rho_f, reps = 1 )
tdbd_grid2_analytical_rho$experiment = 1:nrow(tdbd_grid2_analytical_rho)




bamm_tdbd_grid2 = read_model(model = "bamm", modelf = bamm_tdbd_grid2_f, reps = 10)


# A1 ----------------------------------------------------------------------
cat("A1: ")
source("plots/crbd-input.R")
A1 = do.call(plot_vs_crbd, list (main = "WebPPL CRBD vs CRBD (analytical)",
  mtext = "A1",
  mtextcex = 1,
  ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
  xlab = latex2exp::TeX("$\\lambda$"),
  ylim = c(-240, -130),
  datafr = crbd, datafr_mean = "crbd_means", datafr_var = "crbd_var", crbd_analytical = crbd_analytical))
cat("=========================================\n\n")


# ------ 
cat("A1b: ")
source("plots/crbd-input.R")
A1b = do.call(plot_vs_crbd, list (main = "WebPPL CRBD vs CRBD (analytical), ρ = 0.5",
                                 mtext = "A1b",
                                 mtextcex = 1,
                                 ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                 xlab = latex2exp::TeX("$\\lambda$"),
                                 ylim = c(-240, -130),
                                 datafr = crbd_rho, datafr_mean = "crbd_means", datafr_var = "crbd_var",
                                 crbd_analytical = crbd_analytical_rho))
cat("=========================================\n\n")



# A2 ----------------------------------------------------------------------
cat("A2: ")
source("plots/crbd-input.R")
A2 = do.call(plot_vs_crbd, list(main = "Birch CRBD vs CRBD (analytical)",
        mtext = "A2",
        mtextcex = 0.8,
        ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
        xlab = latex2exp::TeX("$\\lambda$"),
        datafr = crbd_birch_rho, datafr_mean = "birch_mean", datafr_var = "birch_var",
        crbd_analytical = crbd_analytical)
)
cat("=========================================\n\n")
  
#plot.new()



# A3 Clads0 ------------------------------------------------------------------
cat("A3: ")
source("plots/crbd-input.R")
A3 = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS0 vs CRBD (analytical)",
                           mtext = "A3",
                           datafr = clads0,
                           datafr_mean = "clads0_means",
                           datafr_var = "clads0_var",
                           epsvals = c(0.0),
                           xvar = "lambda_0",
                           xlab = latex2exp::TeX("$\\lambda^o$"),
                           mtextcex = 0.8,
                           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                           crbd_analytical = crbd_analytical
                           )
)
cat("=========================================\n\n")

# ----

cat("A3b: ")
source("plots/crbd-input.R")
A3b = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS0 vs CRBD (analytical), ρ = 0.5",
                                mtext = "A3b",
                                datafr = clads0_rho,
                                datafr_mean = "clads0_means",
                                datafr_var = "clads0_var",
                                epsvals = c(0.0),
                                xvar = "lambda_0",
                                xlab = latex2exp::TeX("$\\lambda^o$"),
                                mtextcex = 0.8,
                                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                crbd_analytical = crbd_analytical_rho
)
)
cat("=========================================\n\n")


# plot(NULL, xlim = c(0,1), ylim = c(-200, -95), ylab = "log Z", xlab = "λ", main = "WebPPL ClaDS0 vs CRBD")
# #mtext("Dotted line: CRBD. Circles: ClaDS0 simulation values. Bisse32")
# for (curre in c(0.0)) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = clads0$lambda_0, y = clads0$clads0_means, col = which(epsvals == curre))
#   arrows(clads0$lambda, clads0$clads0_means - 2*sqrt(clads0$clads0_var), clads0$lambda, clads0$clads0_means + 2*sqrt(clads0$clads0_var), length = 0.02, angle = 90, code = 3)
# }


# A4 ClaDS1 ---------------------------------------------------------------
cat("A4: ")
source("plots/crbd-input.R")
A4 = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS1 vs CRBD (analytical)",
                           mtext = "A4",
                           datafr = clads1,
                           datafr_mean = "clads1_means",
                           datafr_var = "clads1_var",
                           xvar = "lambda_0",
                           xlab = latex2exp::TeX("$\\lambda^o$"),
                           mtextcex = 0.8,
                           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                           crbd_analytical = crbd_analytical)

             )
cat("=========================================\n\n")

# ----------

cat("A4b: ")
source("plots/crbd-input.R")
A4b = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS1 vs CRBD (analytical), ρ = 0.5",
                                mtext = "A4b",
                                datafr = clads1_rho,
                                datafr_mean = "clads1_means",
                                datafr_var = "clads1_var",
                                xvar = "lambda_0",
                                xlab = latex2exp::TeX("$\\lambda^o$"),
                                mtextcex = 0.8,
                                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                crbd_analytical = crbd_analytical_rho)
             
)
cat("=========================================\n\n")


# plot(NULL, xlim = c(0,1), ylim = c(-200, -95), ylab = "log Z", xlab = "λ", main = "WebPPL ClaDS1 vs CRBD")
# #mtext("Dotted line: CRBD. Circles: ClaDS1 simulation values. Bisse32")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = clads1[clads1$epsilon == curre,]$lambda, y = clads1[clads1$epsilon == curre,]$clads1_means, col = which(epsvals == curre))
#   arrows(clads1[clads1$epsilon == curre,]$lambda, clads1[clads1$epsilon == curre,]$clads1_means - 2*sqrt(clads1[clads1$epsilon == curre,]$clads1_var), clads1[clads1$epsilon == curre,]$lambda, clads1[clads1$epsilon == curre,]$clads1_means + 2*sqrt(clads1[clads1$epsilon == curre,]$clads1_var), length = 0.02, angle = 90, code = 3, col = which(epsvals == curre))
# }

# legend(0.05, -95, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted")
#
#
# legend(0.1, -25, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted")






# A5 Clads2 ---------------------------------------------------------------
# Clads2: bisse32
cat("A5: ")
source("plots/crbd-input.R")
A5 = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS2 vs CRBD (analytical)",
                           mtext = "A5",
                           datafr = clads2,
                           datafr_mean = "clads2_means",
                           datafr_var = "clads2_var",
                           xvar = "lambda_0",
                           xlab = latex2exp::TeX("$\\lambda^o$"),
                           mtextcex = 0.8,
                           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                           crbd_analytical = crbd_analytical))
cat("=========================================\n\n")

# ------------------

cat("A5b: ")
source("plots/crbd-input.R")
A5b = do.call(plot_vs_crbd, list(main = "WebPPL ClaDS2 vs CRBD (analytical), ρ = 0.5",
                                mtext = "A5b",
                                datafr = clads2_rho,
                                datafr_mean = "clads2_means",
                                datafr_var = "clads2_var",
                                xvar = "lambda_0",
                                xlab = latex2exp::TeX("$\\lambda^o$"),
                                mtextcex = 0.8,
                                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                crbd_analytical = crbd_analytical_rho))
cat("=========================================\n\n")

# plot(NULL, xlim = c(0,1), ylim = c(-200, -95), ylab = "log Z", xlab = "λ", main = "WebPPL ClaDS2 vs CRBD")
# #mtext("Baseline (dots): CRBD (analytical). Circles: ClaDS2")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = clads2[clads2$epsilon == curre,]$lambda, y = clads2[clads2$epsilon == curre,]$clads2_means, col = which(epsvals == curre))
#   arrows(clads2[clads2$epsilon == curre,]$lambda, clads2[clads2$epsilon == curre,]$clads2_means - 2*sqrt(clads2[clads2$epsilon == curre,]$clads2_var), clads2[clads2$epsilon == curre,]$lambda, clads2[clads2$epsilon == curre,]$clads2_means + 2*sqrt(clads2[clads2$epsilon == curre,]$clads2_var), length = 0.02, angle = 90, code = 3, col = which(epsvals == curre))
# }
#
# legend(0.05, -95, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted")





# ClaDS2 (PANDA) ------------------------------------------------------
cat("A11: ")
source("plots/crbd-input.R")
plot(NULL, xlim = c(0,1), ylim = c(-200,-100), ylab = "log Z", xlab = "λ", main = "Validation of ClaDS2 (PANDA) vs CRBD")
mtext("A11: Dotted line: CRBD. Circles: ClaDS2 simulation values. Bisse32")
for (curre in epsvals) {
   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
   points(x = clads2_panda[clads2_panda$epsilon == curre,]$lambda_0, y = (clads2_panda[clads2_panda$epsilon == curre,]$clads2_means -clads2_panda[clads2_panda$epsilon == curre,]$ld ), col = which(epsvals == curre))
 }
#
 legend(0.1, -100, legend=paste("ε = ", epsvals),
        col=1:length(epsvals), lty="dotted")


# ClaDS1 (PANDA) ----------------------------------------------------------
#
 cat("A12: ")
 source("plots/crbd-input.R")
plot(NULL, xlim = c(0,1), ylim = c(-400,0), ylab = "log Z", xlab = "λ", main = "Validation of ClaDS1 (PANDA) vs CRBD")
mtext("A12: Dotted line: CRBD. Circles: ClaDS1 simulation values. Bisse32")
for (curre in epsvals) {
  lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
  points(x = clads1_panda[clads1_panda$epsilon == curre,]$lambda_0, y = (clads1_panda[clads1_panda$epsilon == curre,]$clads1_means -clads1_panda[clads1_panda$epsilon == curre,]$ld ), col = which(epsvals == curre))

}

legend(0.1, -250, legend=paste("ε = ", epsvals),
       col=1:length(epsvals), lty="dotted")





# ClaDS0 (PANDA) ----------------------------------------------------------
cat("A13: ")
source("plots/crbd-input.R")
plot(NULL, xlim = c(0,1), ylim = c(-400,0), ylab = "log Z", xlab = "λ", main = "Validation of ClaDS0 (PANDA) vs CRBD")
mtext("A13: Dotted line: CRBD. Circles: ClaDS0 simulation values. Bisse32")
curre = 0.0
lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
points(x = clads0_panda$lambda_0, y = clads0_panda$clads0_means - clads0_panda$ld , col = 1)
#
legend(0.1, -250, legend=paste("ε = ", epsvals),
      col=1:length(epsvals), lty="dotted")









# ClaDS0 (RPANDA) ---------------------------------------------------
cat("A14: ")
source("plots/crbd-input.R")
lp = with(crbd_analytical, {crbd_analytical_1[which(lambda == 0.1 & epsilon == 0.0)]}) - with(clads0_rpanda, {likelihood_est[which(lambda == 0.1)] - ld[1]})

plot(NULL, xlim = c(0,1), ylim = c(-300,0), ylab = "log Z - Ld", xlab = "λ", main = "ClaDS0 (RPANDA) vs CRBD")
mtext("A14: Dotted line: CRBD. Circles: ClaDS0  simulation values. Bisse32")
lines(x = crbd_analytical[crbd_analytical$epsilon == 0,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == 0,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == 0))
points(x = clads0_rpanda$lambda, y = (clads0_rpanda$likelihood_est - clads0_rpanda$ld + lp)  , pch = 2)
points(x = clads0_rpanda$lambda, y = (clads0_rpanda$likelihood_est - clads0_rpanda$ld)  , pch = 1)

legend(0.1, -200,
       legend=c("No correction for labeled unoriented trees.",
                "Values corrected for labeled unoriented trees."),
        pch = c(1,2))



# Clads1 (RPANDA) ---------------------------------------------------------
cat("A15: ")
source("plots/crbd-input.R")
plot(NULL, xlim = c(0,1), ylim = c(-350,0), ylab = "log Z - Ld", xlab = "λ", main = "ClaDS1 (RPANDA) vs CRBD")
mtext("A15: Dotted line: CRBD. Circles: ClaDS1  simulation values. Bisse32")
 for (curre in epsvals) {
   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
   points(x = clads1_rpanda[clads1_rpanda$epsilon == curre,]$lambda, y = (clads1_rpanda[clads1_rpanda$epsilon == curre,]$likelihood_est - clads1_rpanda[clads1_rpanda$epsilon == curre,]$ld), col = which(epsvals == curre))
 }
#
 legend(0.1, -10, legend=paste("ε = ", epsvals),
        col=1:length(epsvals), lty="dotted")
#
#

 # ClaDS2 (RPANDA) ---------------------------------------------------------
 # ## Clads2 (RPANDA)
 cat("A16: ")
 source("plots/crbd-input.R")
 plot(NULL, xlim = c(0,1), ylim = c(-500,0), ylab = "log Z", xlab = "λ", main = "ClaDS2 (RPANDA) vs CRBD")
 mtext("A16: Dotted line: CRBD. Circles: ClaDS2  simulation values. Bisse32")
 for (curre in epsvals) {
   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
   points(x = clads2_rpanda[clads2_rpanda$epsilon == curre,]$lambda, y = (clads2_rpanda[clads2_rpanda$epsilon == curre,]$likelihood_est - clads2_rpanda[clads2_rpanda$epsilon == curre,]$ld), col = which(epsvals == curre))

 }
#
 legend(0.1, -300, legend=paste("ε = ", epsvals),
        col=1:length(epsvals), lty="dotted")






# LSBDS -------------------------------------------------------------------
source("plots/crbd-input.R")
cat("A6: ")
A6   = do.call(plot_vs_crbd, list(main = "WebPPL LSBDS vs CRBD (analytical)",
                           mtext = "A6",
                           datafr = lsbds,
                           datafr_mean = "lsbds_means",
                           datafr_var = "lsbds_var",
                           xvar = "lambda_0",
                           xlab = latex2exp::TeX("$\\lambda^o$"),
                           mtextcex = 0.8,
                           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                           crbd_analytical = crbd_analytical))
cat("=========================================\n\n")

# --------

source("plots/crbd-input.R")
cat("A6b: ")
A6b = do.call(plot_vs_crbd, list(main = "WebPPL LSBDS vs CRBD (analytical), ρ = 0.5",
                                  mtext = "A6b",
                                  datafr = lsbds_rho,
                                  datafr_mean = "lsbds_means",
                                  datafr_var = "lsbds_var",
                                  xvar = "lambda_0",
                                  xlab = latex2exp::TeX("$\\lambda^o$"),
                                  mtextcex = 0.8,
                                  ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                  crbd_analytical = crbd_analytical_rho))
cat("=========================================\n\n")


# plot(NULL, xlim = c(0,1), ylim = c(-200,-100), ylab = "log Z", xlab = "λ", main = "WebPPL LSBDS vs WebPPL CRBD")
# #mtext("Dotted line: CRBD. Circles: LSBDS simulation values. Bisse32")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = lsbds[lsbds$epsilon == curre,]$lambda, y = lsbds[lsbds$epsilon == curre,]$lsbds_means, col = which(epsvals == curre))
#   arrows(lsbds[lsbds$epsilon == curre,]$lambda, lsbds[lsbds$epsilon == curre,]$lsbds_means - 2*sqrt(lsbds[lsbds$epsilon == curre,]$lsbds_var), lsbds[lsbds$epsilon == curre,]$lambda, lsbds[lsbds$epsilon == curre,]$lsbds_means + 2*sqrt(lsbds[lsbds$epsilon == curre,]$lsbds_var), length = 0.02, angle = 90, code = 3, col = which(epsvals == curre))
# }
#
# legend(0.05, -100, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted", cex = 0.7)






# LSBDS RevBayes (DA) -----------------------------------------------------
cat("A7:")
A7 = do.call(plot_vs_crbd, list(main = "RevBayes LSBDS vs CRBD (DA)",
                           mtext = "A7",
                           datafr = lsbds_revbayes,
                           datafr_mean = "DA",
                           datafr_var = NA,
                           novar = TRUE))
cat("=========================================\n\n")

cat("A8: ")
A8 = do.call(plot_vs_crbd, list(main = "RevBayes LSBDS vs CRBD (SCM)",
                           mtext = "A8",
                           datafr = lsbds_revbayes,
                           datafr_mean = "SCM",
                           datafr_var = NA,
                           novar = TRUE))
cat("=========================================\n\n")


# plot(NULL, xlim = c(0,1), ylim = c(-200,-100), ylab = "log Z", xlab = "λ", main = "RevBayes LSBDS vs WebPPL CRBD")
# #mtext("Dotted line: CRBD. Circles: LSBDS (RevBayes, DA). Triangles (RevBayes, SCM)")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = lsbds_revbayes[lsbds_revbayes$epsilon == curre,]$lambda, y = lsbds_revbayes[lsbds_revbayes$epsilon == curre,]$DA, col = which(epsvals == curre))
#   points(x = lsbds_revbayes[lsbds_revbayes$epsilon == curre,]$lambda, y = lsbds_revbayes[lsbds_revbayes$epsilon == curre,]$SCM, col = which(epsvals == curre), pch = 2)
# }
#
# legend(0.05, -100, legend=c(paste("ε = ", epsvals), "RevBayes, Data Augmentation", "RevBayes, Stochastic Character Mapping"),
#        col=c(1:length(epsvals), 1, 1), lty=c("dotted", "dotted", "dotted", "dotted", NA, NA), pch = c(NA, Npar(mfrow = c(2,2))A, NA, NA, 1, 2), cex = 0.7)





# BAMM --------------------------------------------------------------------
source("plots/crbd-input.R")
cat("A9: ")
A9 = do.call(plot_vs_crbd, list(main = "WebPPL BAMM vs CRBD (analytical)",
                           mtext = "A9",
                           xlab = latex2exp::TeX("$\\lambda^o$"),
                           xvar = "lambda_0",
                           datafr = bamm,
                           datafr_mean = "bamm_means",
                           datafr_var = "bamm_var",
                           mtextcex = 0.8,
                           ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$")        ,
                           crbd_analytical = crbd_analytical))
cat("=========================================\n\n")

# -------

source("plots/crbd-input.R")
cat("A9b: ")
A9b = do.call(plot_vs_crbd, list(main = "WebPPL BAMM vs CRBD (analytical), ρ = 0.5",
                                mtext = "A9b",
                                xlab = latex2exp::TeX("$\\lambda^o$"),
                                xvar = "lambda_0",
                                datafr = bamm_rho,
                                datafr_mean = "bamm_means",
                                datafr_var = "bamm_var",
                                mtextcex = 0.8,
                                ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                                crbd_analytical = crbd_analytical_rho))
cat("=========================================\n\n")


# plot(NULL, xlim = c(0,1), ylim = c(-200,-120), ylab = "log Z", xlab = "λ_0", main = "WebPPL BAMM vs CRBD")
# #mtext("Dotted line: CRBD. Circles: BAMM simulation values. Bisse32")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = bamm[bamm$epsilon == curre,]$lambda_0, y = bamm[bamm$epsilon == curre,]$bamm_means, col = which(epsvals == curre))
#   arrows(bamm[bamm$epsilon == curre,]$lambda_0, bamm[bamm$epsilon == curre,]$bamm_means - 2*sqrt(bamm[bamm$epsilon == curre,]$bamm_var), bamm[bamm$epsilon == curre,]$lambda_0, bamm[bamm$epsilon == curre,]$bamm_means + 2*sqrt(bamm[bamm$epsilon == curre,]$bamm_var), length = 0.02, angle = 90, code = 3, col = which(epsvals == curre))
# }
#
# legend(0.1, -160, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted")
#
#







# TDBD --------------------------------------------------------------------
cat("A10: ")
source("plots/crbd-input.R")
A10 = do.call(plot_vs_crbd, list(main = "WebPPL TDBD vs CRBD",
                           mtext = "A10",
                           xlab = "λ_0",
                           xvar = "lambda_0",
                           datafr = tdbd,
                           datafr_mean = "tdbd_means",
                           source("plots/crbd-input.R")      datafr_var = "tdbd_var",
                           crbd_analytical  = crbd_analytical))
cat("=========================================\n\n")

# ------

cat("A10b: ")
source("plots/crbd-input.R")
A10b = do.call(plot_vs_crbd, list(main = "WebPPL TDBD vs CRBD",
                                 mtext = "A10b",
                                 xlab = "λ_0",
                                 xvar = "lambda_0",
                                 datafr = tdbd_rho,
                                 datafr_mean = "tdbd_means",
                                 datafr_var = "tdbd_var",
                                 crbd_analytical  = crbd_analytical_rho))
cat("=========================================\n\n")



# plot(NULL, xlim = c(0,1), ylim = c(-200,-120), ylab = "log Z", xlab = "λ_0", main = "WebPPL TDBD vs CRBD")
#
# #mtext("Dotted line: CRBD. Circles: TDBD simulation values. Bisse32")
# for (curre in epsvals) {
#   lines(x = crbd_analytical[crbd_analytical$epsilon == curre,]$lambda, y = crbd_analytical[crbd_analytical$epsilon == curre,]$crbd_analytical_1, lty = "dotted",  col = which(epsvals == curre))
#   points(x = tdbd[tdbd$epsilon == curre,]$lambda_0, y = tdbd[tdbd$epsilon == curre,]$tdbd_means, col = which(epsvals == curre))
#   arrows(tdbd[tdbd$epsilon == curre,]$lambda_0, tdbd[tdbd$epsilon == curre,]$tdbd_means - 2*sqrt(tdbd[tdbd$epsilon == curre,]$tdbd_var), tdbd[tdbd$epsilon == curre,]$lambda_0, tdbd[tdbd$epsilon == curre,]$tdbd_means + 2*sqrt(tdbd[tdbd$epsilon == curre,]$tdbd_var), length = 0.02, angle = 90, code = 3, col = which(epsvals == curre))
# }
#
# legend(0.1, -160, legend=paste("ε = ", epsvals),
#        col=1:length(epsvals), lty="dotted")





# Cleanup -----------------------------------------------------------------

cat("The following is a plotting message:\n")
dev.off()
cat("\n")
cat("Plots have been written to crbd.pdf\n")







