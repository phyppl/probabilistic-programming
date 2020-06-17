library(dplyr)
library(readr)
library(rppl)


# Settings ----------------------------------------------------------------

## number of edges in the tree
nedges = 62

## directories and files
workdir             = "~/Work/ppl-phylogenetics/webppl/phywppl"
lsbds_f             = "verification/lsbds/lsbds-results.JSON"
lsbds_revbayes_f    = "verification/lsbds/bisse_32-results.csv"
lsbds_grid2_revbayes_f = "verification/lsbds/bisse_32-grid2-results.csv"
lsbds_grid2_f       = "verification/lsbds/lsbds-birch-grid-results.JSON"
lsbds_birch_grid2_f = "verification/lsbds/lsbds-birch.csv"


bamm_lsbds_f    = "verification/lsbds/bamm-lsbds-results.JSON"
bamm_grid2_lsbds_f = "verification/lsbds/bamm-grid2-lsbds-results.JSON"

bamm_lsbds_birch_grid2_f = "verification/lsbds/bamm_birch_lsbds_grid2.csv"

# Input ----------------------------------------------------------

setwd(workdir)

lsbds = read_model(model = "lsbds", modelf = lsbds_f, reps = 12 )
lsbds = lsbds[,c("EXPECTED_NUM_EVENTS", "rho", "lsbds_1", "lsbds_2", "lsbds_3", "lsbds_4", "lsbds_5", "lsbds_6", "lsbds_7", "lsbds_8", "lsbds_9", "lsbds_10", "lsbds_11", "lsbds_12", "lsbds_means", "lsbds_var", "particles")]
lsbds$experiment = 1:nrow(lsbds)

# recalculate eta

lsbds_revbayes = read.table(lsbds_revbayes_f, header = TRUE)
lsbds_grid2_revbayes = read.table(lsbds_grid2_revbayes_f, header = TRUE)


lsbds_grid2 = read_model(model = "lsbds_grid2", modelf = lsbds_grid2_f, reps = 12 )
lsbds_grid2_birch <- read_delim("~/Work/ppl-phylogenetics/webppl/phywppl/verification/lsbds/lsbds-birch.csv",
                                "|", escape_double = FALSE, trim_ws = TRUE)
# vt_lsbds_$EXPECTED_NUM_EVENTS.json
lsbds_grid2_birch$EXPECTED_NUM_EVENTS   = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = lsbds_grid2_birch$File, split = "_"), function(l) { l[4] } ) ) )
lsbds_grid2_birch$particles = rep(5000, nrow(lsbds_grid2_birch))

bamm_lsbds = read_model(model = "bamm_lsbds", modelf = bamm_lsbds_f, reps = 12 )
bamm_lsbds = bamm_lsbds[, -sapply(c("tree", "DistLambda", "DistMu", "eta",  "MAX_DIV", "MAX_LAMBDA", "lambda_0", "DistZ", "z_0", "lambdaFun_0", "mu_0", "eta"), grep, colnames(bamm_lsbds) )]

bamm_grid2_lsbds = read_model(model = "bamm_lsbds", modelf = bamm_grid2_lsbds_f, reps = 12 )
bamm_grid2_lsbds = bamm_grid2_lsbds[, -sapply(c("tree", "DistLambda", "DistMu", "eta", "MAX_DIV", "MAX_LAMBDA", "lambda_0", "DistZ", "z_0", "lambdaFun_0", "mu_0", "eta"), grep, colnames(bamm_grid2_lsbds) )]

bamm_lsbds_birch_grid2 =  read_delim(bamm_lsbds_birch_grid2_f, "|", escape_double = FALSE, trim_ws = TRUE)
bamm_lsbds_birch_grid2$EXPECTED_NUM_EVENTS   = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = bamm_lsbds_birch_grid2$File, split = "_"), function(l) { l[4] } ) ) )

