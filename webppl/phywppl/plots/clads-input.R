
# Initialization ----------------------------------------------------------
workdir         = "~/Work/ppl-phylogenetics/webppl/phywppl"
library(dplyr)
setwd(workdir)
library(readr)
library(rppl)
require(xtable)
source("src/plotting-functions.R")

# Settings ----------------------------------------------------------------

## Settings
### Number of edges in the tree
nedges = 62

### Files

plots_f         = "verification/clads/clads0-2.pdf"
clads0_2_diagonstic = "verification/clads/clads0-2-diagnostic.pdf"


clads0_tex      = "verification/clads/clads0.tex"
clads0_panda_tex = "verification/clads/clads0-panda.tex"
clads1_tex = "verification/clads/clads1.tex"

clads2_panda_birch_f = "verification/clads/clads2-panda-birch.csv"
clads2_panda_f       = "verification/clads/clads2-panda-results.JSON"
clads2_panda_grid2_f = "verification/clads/clads2-panda-grid2-results.JSON"
clads2_panda_grid3_f = "verification/clads/clads2-panda-grid3-results.JSON"
clads1_panda_grid3_f = "verification/clads/clads1-panda-grid3-results.JSON"
clads2_rpanda_f = "verification/clads/clads2-rpanda-results.csv"
clads2_birch_f       = "verification/clads/clads2-birch.csv"
clads2_f        = "verification/clads/clads2-results.JSON"
clads2_rpanda_grid2_f = "verification/clads/clads2-rpanda-grid2-results.csv"
clads2_rpanda_grid3_f = "verification/clads/clads2-rpanda-grid3-results.csv"
clads1_rpanda_grid3_f = "verification/clads/clads1-rpanda-grid3-results.csv"


clads1_f        = "verification/clads/clads1-results.JSON"
clads1_birch_f = "verification/clads/clads1-birch.csv"
clads1_panda_f  = "verification/clads/clads1-panda-results.JSON"
clads1_rpanda_f = "verification/clads/clads1-rpanda-results.csv"
clads1_rpanda_grid2_f = "verification/clads/clads1-rpanda-grid2-results.csv"
clads1_panda_grid2_f = "verification/clads/clads1-panda-grid2-results.JSON"


clads0_f        = "verification/clads/clads0-results.JSON"
clads0_panda_f  = "verification/clads/clads0-panda-results.JSON"
clads0_panda_grid2_f = "verification/clads/clads0-panda-grid2-results.JSON"
clads0_rpanda_f = "verification/clads/clads0-rpanda-results.csv"
clads0_rpanda_grid2_f = "verification/clads/clads0-rpanda-grid2-results.csv"
clads0_birch_f = "verification/clads/clads0-birch.csv"

clads0_grid2_f = "verification/clads/clads0-grid2-results.JSON"
clads0_grid2_birch_f = "verification/clads/clads0-grid2-birch.csv"

clads1_grid2_f = "verification/clads/clads1-grid2-results.JSON"
clads1_grid2_birch_f = "verification/clads/clads1-grid2-birch.csv"

clads2_grid2_f = "verification/clads/clads2-grid2-results.JSON"
clads2_grid2_birch_f = "verification/clads/clads2-grid2-birch.csv"



treefile    = "../../data/bisse_32.nex" # set this to whereever you saved the tree

##### Read the bisse32 tree

bisse32 = ape::read.nexus(file = treefile)[[1]]
# Input --------------------------------------------------------------------


### ClaDS0
clads0_birch <- read_delim(clads0_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
# vt_clads0_${SIGMA}_${ALPHA}_${LAMBDA}.json
clads0_birch$sigma = as.numeric( sapply(strsplit(x = clads0_birch$File, split = "_"), function(l) { l[3] } ) )
clads0_birch$alpha = as.numeric( sapply(strsplit(x = clads0_birch$File, split = "_"), function(l) { l[4] } ) )
clads0_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads0_birch$File, split = "_"), function(l) { l[5] } ) ) )
clads0_birch$experiment = 1:nrow(clads0_birch)
clads0 = read_model(model = "clads0", modelf = clads0_f, reps = 12)
clads0 = clads0[clads0$rho == 1.0,]

clads0_grid2         = read_model(model = "clads0", modelf = clads0_grid2_f, reps = 10)
clads0_grid2_birch = read_delim(clads0_grid2_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
clads0_grid2_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads0_grid2_birch$File, split = "_"), function(l) { l[3] } ) ) )

clads1_grid2         = read_model(model = "clads1", modelf = clads1_grid2_f, reps = 10)
clads1_grid2_birch = read_delim(clads1_grid2_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
clads1_grid2_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads1_grid2_birch$File, split = "_"), function(l) { l[3] } ) ) )

clads2_grid2         = read_model(model = "clads2", modelf = clads2_grid2_f, reps = 10)
clads2_grid2_birch = read_delim(clads2_grid2_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
clads2_grid2_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads2_grid2_birch$File, split = "_"), function(l) { l[3] } ) ) )



clads0_panda = read_model(model = "clads0_panda", modelf = clads0_panda_f, reps = 12)
clads0_panda = clads0_panda[clads0_panda$rho == 1,]
clads0_panda$ld = sapply(1:nrow(clads0_panda), function(i) {
  panda_correction(clads0_panda[i,]$lambda, clads0_panda[i,]$sigma, nedges = nedges)
})
clads0_panda$webppl_cmean = clads0_panda$clads0_panda_means - clads0_panda$ld



clads2_panda_grid2 = read_model(model = "clads2_panda", modelf = clads2_panda_grid2_f, reps = 10)
#clads2_panda_grid2 = clads0_panda[clads0_panda$rho == 1,]
clads2_panda_grid2$ld = sapply(1:nrow(clads2_panda_grid2), function(i) {
  panda_correction(clads2_panda_grid2[i,]$lambda, clads2_panda_grid2[i,]$sigma, nedges = nedges)
})
clads2_panda_grid2$webppl_cmean = clads2_panda_grid2$clads2_panda_means - clads2_panda_grid2$ld


clads2_panda_grid3 = read_model(model = "clads2_panda", modelf = clads2_panda_grid3_f, reps = 10)
clads1_panda_grid3 = read_model(model = "clads1_panda", modelf = clads1_panda_grid3_f, reps = 10)

clads1_panda_grid2 = read_model(model = "clads1_panda", modelf = clads1_panda_grid2_f, reps = 10)
#clads2_panda_grid2 = clads0_panda[clads0_panda$rho == 1,]
clads1_panda_grid2$ld = sapply(1:nrow(clads1_panda_grid2), function(i) {
  panda_correction(clads1_panda_grid2[i,]$lambda, clads1_panda_grid2[i,]$sigma, nedges = nedges)
})
clads1_panda_grid2$webppl_cmean = clads1_panda_grid2$clads1_panda_means - clads1_panda_grid2$ld



clads0_panda_grid2 = read_model(model = "clads0_panda", modelf = clads0_panda_grid2_f, reps = 12)
#clads0_panda_grid2 = clads0_panda_grid2[clads0_panda_grid2$rho == 1,]
clads0_panda_grid2$ld = sapply(1:nrow(clads0_panda_grid2), function(i) {
  panda_correction(clads0_panda_grid2[i,]$lambda, clads0_panda_grid2[i,]$sigma, nedges = nedges)
})
clads0_panda_grid2$webppl_cmean = clads0_panda_grid2$clads0_panda_means - clads0_panda_grid2$ld



# clads0_rpanda

clads0_rpanda = read.table(file = clads0_rpanda_f)

clads0_rpanda$ld_log = sapply(1:nrow(clads0_rpanda), function(i) {
  rpanda_correction(clads0_rpanda[i,]$lambda, clads0_rpanda[i,]$sigma, nedges = nedges)
})

clads0_rpanda_grid2 = read.table(file = clads0_rpanda_grid2_f)

clads0_rpanda_grid2$ld_log = sapply(1:nrow(clads0_rpanda_grid2), function(i) {
  rpanda_correction(clads0_rpanda_grid2[i,]$lambda, clads0_rpanda_grid2[i,]$sigma, nedges = nedges)
})
n = bisse32$Nnode
lp = log( 2^(n) / factorial(n+1) )
#clads0_rpanda_grid2$cmean = clads0_rpanda_grid2$likelihood_est - clads0_rpanda_grid2$ld_log + lp
clads0_rpanda_grid2$cmean = clads0_rpanda_grid2$likelihood_est + lp


clads1_rpanda_grid2 = read.table(file = clads1_rpanda_grid2_f)
n = bisse32$Nnode
lp = log( 2^(n) / factorial(n+1) )
clads1_rpanda_grid2$clads1_cmean = clads1_rpanda_grid2$likelihood_est + lp




clads2_rpanda_grid2 = read.table(file = clads2_rpanda_grid2_f)
clads2_rpanda_grid2$ld_log = sapply(1:nrow(clads2_rpanda_grid2), function(i) {
  rpanda_correction(clads2_rpanda_grid2[i,]$lambda, clads2_rpanda_grid2[i,]$sigma, nedges = nedges)
})
n = bisse32$Nnode
lp = log( 2^(n) / factorial(n+1) )
#clads2_rpanda_grid2$clads2_cmean = clads2_rpanda_grid2$clads2_likelihood_est - clads2_rpanda_grid2$ld_log + lp
clads2_rpanda_grid2$clads2_cmean = clads2_rpanda_grid2$clads2_likelihood_est + lp

clads2_rpanda_grid3 = read.table(file = clads2_rpanda_grid3_f)
n = bisse32$Nnode
lp = log( 2^(n) / factorial(n+1) )
#clads2_rpanda_grid2$clads2_cmean = clads2_rpanda_grid2$clads2_likelihood_est - clads2_rpanda_grid2$ld_log + lp
clads2_rpanda_grid3$clads2_cmean = clads2_rpanda_grid3$clads2_likelihood_est + lp

clads1_rpanda_grid3 = read.table(file = clads1_rpanda_grid3_f)
n = bisse32$Nnode
lp = log( 2^(n) / factorial(n+1) )
#clads2_rpanda_grid2$clads2_cmean = clads2_rpanda_grid2$clads2_likelihood_est - clads2_rpanda_grid2$ld_log + lp
clads1_rpanda_grid3$clads1_cmean = clads1_rpanda_grid3$likelihood_est + lp



data = merge(clads0_panda[clads0_panda$rho == 1.0,], clads0_rpanda)
lp = mean((data$clads0_panda_means - data$ld) - (data$likelihood_est - data$ld_log), na.rm = TRUE)
clads0_rpanda$rpanda_cmean = clads0_rpanda$likelihood_est - clads0_rpanda$ld_log + lp
clads0_rpanda$experiment = 1:nrow(clads0_rpanda)

clads1_birch <- readr::read_delim(clads1_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
# vt_clads1_${SIGMA}_${ALPHA}_${EPSILON}_${LAMBDA}
clads1_birch$sigma = as.numeric( sapply(strsplit(x = clads1_birch$File, split = "_"), function(l) { l[3] } ) )
clads1_birch$alpha = as.numeric( sapply(strsplit(x = clads1_birch$File, split = "_"), function(l) { l[4] } ) )
clads1_birch$epsilon = as.numeric( sapply(strsplit(x = clads1_birch$File, split = "_"), function(l) { l[5] } ) )
clads1_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads1_birch$File, split = "_"), function(l) { l[6] } ) ) )
clads1_birch$experiment = 1:nrow(clads1_birch)

clads1 = read_model(model = "clads1", modelf = clads1_f, reps = 12)
clads1 = clads1[clads1$rho == 1.0, ]

clads2_birch <- read_delim(clads2_birch_f, "|", escape_double = FALSE, trim_ws = TRUE)
# vt_clads1_${SIGMA}_${ALPHA}_${EPSILON}_${LAMBDA}
clads2_birch$sigma = as.numeric( sapply(strsplit(x = clads2_birch$File, split = "_"), function(l) { l[3] } ) )
clads2_birch$alpha = as.numeric( sapply(strsplit(x = clads2_birch$File, split = "_"), function(l) { l[4] } ) )
clads2_birch$epsilon = as.numeric( sapply(strsplit(x = clads2_birch$File, split = "_"), function(l) { l[5] } ) )
clads2_birch$lambda = as.numeric( sub(pattern = ".json", replacement = "", x = sapply(strsplit(x = clads2_birch$File, split = "_"), function(l) { l[6] } ) ) )
clads2_birch$experiment = 1:nrow(clads2_birch)

clads2 = read_model(model = "clads2", modelf = clads2_f, reps = 12)
