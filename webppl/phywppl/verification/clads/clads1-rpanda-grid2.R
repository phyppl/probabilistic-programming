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

sigma    =   c( 0.05 )
alpha    =  c( 1.0 )
epsilon  =  c( 0.00, 0.1, 0.5, 0.9 )
lambda_0 =    c(0.05,0.1,0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95,1)
rho      =  c(  1.0)

##### Grid expansion

param = expand.grid(sigma = sigma, alpha = alpha, epsilon = epsilon, lambda = lambda_0, f = rho)

likelihood_est = numeric(nrow(param))

for(i in 1:nrow(param)) {
  ##### Likelihood estimations
  reparam = list( param = c(sigma = param[i,]$sigma, alpha = param[i,]$alpha, mu = param[i,]$epsilon * param[i, ]$lambda, lambda = log(rep(param[i,]$lambda, nedges + 1))), f = param[i,]$f)
  cat("Processing", i, fill = TRUE)
  print(reparam)
  bisse32_clads1_f = createLikelihood_ClaDS1(bisse32, relative = FALSE)$ll
  likelihood_est[i] = do.call(bisse32_clads1_f, reparam)$LL
}

results = data.frame(param, likelihood_est)
write.table(data.frame(param, likelihood_est), file = "verification/clads/clads1-rpanda-grid2-results.csv")
