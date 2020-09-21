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

