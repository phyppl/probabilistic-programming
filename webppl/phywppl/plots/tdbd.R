# TDBD --------------------------------------------------------------------
rm(list = ls())
library(rppl)
source("src/plotting-functions.R")
cairo_pdf("plots/tdbd.pdf", onefile = TRUE, width = 10, height = 10,  fallback_resolution = 600)
par(mfrow = c(3,3))


# Plot D1 -------------------------------------------------------------------
source("plots/tdbd-input.R")
D1 = merge_plot(d1 = tdbd, d2 = tdbd_birch,
           x = "experiment",
           d1_z = "tdbd_means", d1_var = "tdbd_var",
           d2_z = "birch_mean", d2_var = "birch_var",
           mtext = "Black: TDBD (WebPPL). Red: TDBD (Birch). Arrows denote ± 1 st. dev. of the estimate.",
           main = "TDBD Verification", low = -210, high = -135, tickw = 0.15, arrowl = 0.02)



# Plot ----------------------------------------------------------------------
source("plots/tdbd-input.R")
a = c("a", "b", "c", "d", "e", "f", "g", "h", "i")
i = 1
for ( e in unique(tdbd$epsilon) ) {
  for (l in unique(tdbd$lambda) ) {
    cat("eps =", e, "lam= ", l, "\n")
    merge_plot(d1 = tdbd[tdbd$epsilon == e & tdbd$lambda_0 == l ,], d2 = tdbd_birch[tdbd_birch$epsilon == e & tdbd_birch$lambda_0 == l,],
               x = "z",
               d1_z = "tdbd_means", d1_var = "tdbd_var",
               d2_z = "birch_mean", d2_var = "birch_var",
               mtext = paste0("(", a[i], ")  ε = ", e, ", λ_0 = ", l), mtextcex = 0.8,
               main = NULL, tickw = 0.003, arrowl = 0.03,
               low = -170, high = -135,
               legend = c("WebPPL", "Birch"),
               legendx= 0.05, legendy = -160)
  i = i + 1
  }
}
title("WebPPL TDBD vs Birch TDBD", outer=TRUE,  line=-2 )
par(mfrow = c(1,1))




# D2 ----------------------------------------------------------------------
source("plots/tdbd-input.R")
D2 = plot_vs_analytical(d1 = tdbd_grid2,
                   d2 = tdbd_grid2_analytical,
                   meanvar = "tdbd_means",
                   mtext = "D2",
                   mtextcex = 1,
                   variance_var = "tdbd_var",
                   analytical_mean_var = "tdbd_analytical_means",
                   xvar = "lambda_0", ylim = c(-240, -130),
                   ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                   xlab = latex2exp::TeX("$\\lambda^o$"),
                   main = "WebPPL TDBD vs TDBD (analytical)",
                   legendy = -160,
                   legengx = 0.75)


# D2 ----------------------------------------------------------------------
source("plots/tdbd-input.R")
D2b = plot_vs_analytical(d1 = tdbd_grid2_rho,
                        d2 = tdbd_grid2_analytical_rho,
                        meanvar = "tdbd_means",
                        mtext = "D2b",
                        mtextcex = 1,
                        variance_var = "tdbd_var",
                        analytical_mean_var = "tdbd_analytical_means",
                        xvar = "lambda_0", ylim = c(-240, -130),
                        ylab = latex2exp::TeX("$\\log$ $\\hat{Z}$"),
                        xlab = latex2exp::TeX("$\\lambda^o$"),
                        main = "WebPPL TDBD vs TDBD (analytical), ρ = 0.5",
                        legendy = -160,
                        legengx = 0.75)


# D2 ----------------------------------------------------------------------
source("plots/tdbd-input.R")
D3 = plot_vs_analytical(d1 = bamm_tdbd_grid2,
                        d2 = tdbd_grid2_analytical,
                        meanvar = "bamm_means",
                        mtext = "D3",
                        variance_var = "bamm_var",
                        analytical_mean_var = "tdbd_analytical_means",
                        xvar = "lambda_0", ylim = c(-240, -130),
                        xlab = latex2exp::TeX("$\\lambda_0$"),
                        main = "WebPPL BAMM (z = 0) vs TDBD (analytical)",
                        legendy = -160,
                        legengx = 0.75)




# Clean up ------------------------------------------------------------------
dev.off()

