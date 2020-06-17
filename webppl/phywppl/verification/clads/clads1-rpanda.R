rm(list = ls())
library(RPANDA)
library(deSolve)

panda_dir = "~/Work/PANDA/" # needs trailing slash

source(paste0(panda_dir, 'R/fit_ClaDS0.R'))
source(paste0(panda_dir, 'R/fit_ClaDS.R'))
source(paste0(panda_dir, 'R/MPhiAbstract.class.R'))
source(paste0(panda_dir, 'R/MPhiFFT.class.R'))

set.seed(1)

##### Constants

treefile    = "../../data/bisse_32.nex" # set this to whereever you saved the tree

##### Read the bisse32 tree

bisse32 = ape::read.nexus(file = treefile)[[1]]
nedges  = nrow(bisse32$edge)
#plot(bisse32)

##### Parametrizations

sigma    =  c( 0.15,  0.6,   1.0 )
alpha    =  c(  0.4,  0.65,  1.0 )
epsilon  =  c( 0.015, 0.025, 0.065)
lambda_0 =  c( 0.03,  0.12,   1.0)
rho      =  c(  1.0)

##### Grid expansion

param = expand.grid(sigma = sigma, alpha = alpha, epsilon = epsilon, lambda = lambda_0, f = rho)

likelihood_est = numeric(nrow(param))

for(i in 1:nrow(param)) {
  ##### Likelihood estimations
  reparam = list( param = c(sigma = param[i,]$sigma, alpha = param[i,]$alpha, mu = param[i,]$epsilon * param[i, ]$lambda, lambda = c(param[i,]$lambda, rep(1, nedges))), f = param[i,]$f)
  cat("Processing", i, fill = TRUE)
  print(reparam)
  bisse32_clads1_f = createLikelihood_ClaDS1(bisse32)$ll
  likelihood_est[i] = do.call(bisse32_clads1_f, reparam)$LL  
}

results = data.frame(param, likelihood_est)
write.table(data.frame(param, likelihood_est), file = "verification/clads/clads1-rpanda-results.csv")
