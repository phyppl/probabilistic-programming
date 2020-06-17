rm(list = ls())
library(rppl)
library(vioplot)
source("src/plotting-functions.R")

crbd_analytical = read_model("crbd_analytical_priors", modelf = "verification/alignment/crbd-analytical-results.JSON", reps = 1)
crbd_analytical$tree = sapply(crbd_analytical$tree, strip_read_phyjson)

crbd = read_model("crbd", modelf = "verification/alignment/crbd-results.JSON", reps = 12)
crbd$tree = sapply(crbd$tree, strip_read_phyjson)

crbd_naive = read_model("crbd", modelf = "verification/alignment/crbd-naive-results.JSON", reps = 12)
crbd_naive$tree = sapply(crbd_naive$tree, strip_read_phyjson)


ptrees = crbd_analytical$tree
m = crbd_analytical$crbd_analytical_priors_means
l = 140
u = 15

cairo_pdf("plots/alignment.pdf", onefile = TRUE, width = 10, height = 4, pointsize = 12, fallback_resolution = 600)

par(mfrow = c(1,3))
scale = list(c(m[1] - l, m[1] + u), c(m[2] - l, m[2] + u), c(m[3] - l, m[3] + u))
ttls = c("32 Taxa", "87 Taxa", "233 Taxa")
for (tr in seq(from = 1, to = 3, by = 1)) {
  plframe = data.frame("Aligned" = as.numeric(crbd[tr, 9:18]), "Naive" = as.numeric(crbd_naive[tr, 9:18]))
  #plotmain = paste("Alignment Test On", ptrees[tr], "Tree")
  vioplot(plframe, main = ttls[tr], ylab = "log Z", ylim = scale[[tr]])
  abline(h = as.numeric(crbd_analytical[tr, 6]), lty = "dotted")
  #  mtext("Baseline (dotted): analytical solution.")
}

dev.off()


