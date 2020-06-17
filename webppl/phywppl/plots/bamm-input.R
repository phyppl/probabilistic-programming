library(dplyr)
library(readr)
library(rppl)



# Settings ----------------------------------------------------------------

## number of edges in the tree
nedges = 62

## directories and files
workdir          = "~/Work/ppl-phylogenetics/webppl/phywppl"

bamm_f = "verification/bamm/bamm-results.JSON"
bamm_birch_f = "verification/bamm/bamm-birch-results.csv"


plot_f = "verification/bamm/bamm-plots.pdf"
plot_tdbd_f = "verification/bamm/bamm-tdbd-plots.pdf"

bamm_tdbd_f = "verification/bamm/bamm-tdbd-results.JSON"
tdbd_f = "verification/bamm/tdbd-results.JSON"

bamm_tdbd_birch_f = "verification/bamm/bamm_tdbd_birch.csv"


# Input -------------------------------------------------------------------

setwd(workdir)

lsbds = read_model(model = "lsbds", modelf = lsbds_f, reps = 12 )
lsbds = lsbds[, -sapply(c("tree", "DistLambda", "DistMu", "eta",  "MAX_DIV", "MAX_LAMBDA"), grep, colnames(lsbds) )]
lsbds = lsbds[lsbds$rho == 1.0,]

lsbds_grid2 = read_model(model = "lsbds", modelf = lsbds_grid2_f, reps = 12 )
lsbds_grid2 = lsbds_grid2[, -sapply(c("tree", "DistLambda", "DistMu", "eta",  "MAX_DIV", "MAX_LAMBDA"), grep, colnames(lsbds_grid2) )]
lsbds_grid2 = lsbds_grid2[lsbds_grid2$rho == 1.0,]

bamm_birch_results = read_delim(bamm_birch_f, "|",  escape_double = FALSE, trim_ws = TRUE)
bamm = read_model(model = "bamm", modelf = bamm_f, reps = 12)
bamm = bamm[, -sapply(c("tree", "DistLambda", "DistMu", "eta",  "MAX_DIV", "MAX_LAMBDA", "lambda_0", "DistZ", "z_0", "lambdaFun_0", "mu_0", "eta", "EXPECTED_NUM_EVENTS"), grep, colnames(bamm) )]

bamm_tdbd = read_model(model = "bamm", modelf = bamm_tdbd_f, reps = 12 )
bamm_tdbd = bamm_tdbd[, -sapply(c("tree", "DistLambda", "DistMu", "DistZ", "z_0", "lambdaFun_0", "eta", "rho", "MAX_DIV", "MAX_LAMBDA", "MIN_LAMBDA"), grep, colnames(bamm_tdbd) )]
bamm_tdbd$experiment = 1:nrow(bamm_tdbd)

tdbd = read_model(model = "tdbd", modelf = tdbd_f, reps = 12)
tdbd = tdbd[, -sapply(c("tree", "lambdaFun", "muFun", "rho",  "MAX_DIV", "MAX_LAMBDA", "MIN_LAMBDA"), grep, colnames(tdbd) )]

bamm_tdbd_birch = read_delim(bamm_tdbd_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
bamm_tdbd_birch$z   = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = bamm_tdbd_birch$File, split = "_"), function(l) { l[6] } ) ) )
bamm_tdbd_birch$epsilon   = as.numeric( sapply(strsplit(x = bamm_tdbd_birch$File, split = "_"), function(l) { l[5] } ) )
bamm_tdbd_birch$lambda   = as.numeric( sapply(strsplit(x = bamm_tdbd_birch$File, split = "_"), function(l) { l[4] } ) )
