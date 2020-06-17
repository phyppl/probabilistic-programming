
##### 
# Likelihood Computations with ClaDS0 for the Bisse32 Tree ----------------
##### 

##### Setup
rm(list = ls())
nedges = 62
panda_dir   = "/home/viktsend/Work/PANDA/" # edit this, if needed
treefile    = "../../data/bisse_32.nex" # set this to whereever you saved the tree

##### Initialization
library(RPANDA)
library(deSolve)


source(paste0(panda_dir, 'R/fit_ClaDS0.R'))
source(paste0(panda_dir,'R/fit_ClaDS.R'))
source(paste0(panda_dir,'R/MPhiAbstract.class.R'))
source(paste0(panda_dir,'R/MPhiFFT.class.R'))
source(paste0(panda_dir,'inst/initialize-lambda.R'))

set.seed(1)

bisse32 = ape::read.nexus(file = treefile)[[1]]
nedges  = nrow(bisse32$edge)

##### Parametrization
sigma    =   c( 0.15,  0.6,   1.0 )
alpha    =   c(  0.4,  0.65,  1.0 )
lambda_0 =   c( 0.03,  0.12,   1.0)
rho      =  c(   1.0)
# f is unused!!


##### Grid expansion
param = expand.grid(sigma = sigma, alpha = alpha, lambda = lambda_0)
rpanda_clads0 = numeric(nrow(param))

for(i in 1:nrow(param)) {
  reparam = list(lambda = rep(param[i,]$lambda, nedges + 1), sigma = param[i,]$sigma, alpha = param[i,]$alpha)
  #reparam = list(lambda = initialize_lambda(lambda_0 = param[i,]$lambda, lvect_length = nedges + 1), sigma = param[i,]$sigma, alpha = param[i,]$alpha)
  cat("Processing Clads0: ", i, fill = TRUE)
  print(reparam)
  f = createLikelihood_ClaDS0(bisse32, relative = FALSE)$ll
  rpanda_clads0[i] = do.call(f, reparam)
}

results = data.frame(param, rpanda_clads0)
results = cbind(rep("phyjs.bisse_32", nrow(results)), results)
names(results) = c("tree", "sigma", "alpha", "lambda", "likelihood_est")
write.table(results, file = "verification/clads/clads0-rpanda-results.csv")

