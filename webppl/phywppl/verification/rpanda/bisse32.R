# Setup -------------------------------------------------------------------
library(TESS)
library(parallel)
worktree = function(filename = "../../data/bisse_32.nex") {
  ape::read.nexus(file = filename)[[1]]
}


# Run RPANDA ClaDS0 Posteriors on Bisse_32 ---------------------------------
sampler_clads0 = RPANDA::fit_ClaDS0(tree = worktree(),
                                    name = "verification/rpanda/clads0.Rdata",
                                    nCPU = 3,
                                    pamhLocalName = "local",
                                    iteration = 500000,
                                    thin = 2000,
                                    update = 1000,
                                    adaptation = 5000)



# Clads2 ------------------------------------------------------------------

sampler_clads2 = fit_ClaDS(
  tree = worktree(),
  res_ClaDS0 = sampler_clads0,
  sample_fraction = 1,
  file_name = "verification/rpanda/clads2.Rdata",
  #mcmcSampler = sampler_clads2,       # an object as returned by prepare ClaDS or fit_ClaDS
  iterations = 1000,            # number of iterations
  thin = 50,                   # number of iterations after which the chains state is recorded
  nCPU = 3)                    # number of cores to use (between 1 and the number of chains)

gelman = 10
id_g = 0
tree = worktree()
npar = nrow(tree$edge) + 3
while(gelman>1.05) {
  sampler_clads2 = fit_ClaDS(
    tree = worktree(),
    res_ClaDS0 = sampler_clads0,
    sample_fraction = 1,
    file_name = "verification/rpanda/clads2.Rdata",
    mcmcSampler = sampler_clads2,       # an object as returned by prepare ClaDS or fit_ClaDS
    iterations = 1000,            # number of iterations
    thin = 50,                   # number of iterations after which the chains state is recorded
    nCPU = 3)                    # number of cores to use (between 1 and the number of chains)

  nr=nrow(sampler_clads2$chains[[1]])
  print(nr)
  rep=mcmc.list(lapply(1:3,function(j){mcmc(sampler_clads2$chains[[j]][-(1:ceiling(nr/10)),-c((npar+1):(npar+3))])}))
  gelman=try(gelman.diag(rep))
  if(! inherits(gelman,"try-error")){
    id_g=which.max(gelman$psrf[,1])
    gelman=max(gelman$psrf[,1])
  }else{
    gelman=10
  }
  print(c(gelman, id_g))
}


    # Plot and prune ----------------------------------------------------------
sampler = sampler_clads0
mcmc.list(sampler_clads0)

plot(mcmc(sampler_clads0[[1]][-(1:10),c(1:3, 64+4)]))

plot(
  mcmc.list(
    lapply(1:3, function(j)
             {
              mcmc(sampler_clads0[[j]][-(1:10),c(1:3,nedges+4:6)])
             })
    )
)

sampler = sampler_clads2
plot(
  mcmc.list(
    lapply(1:3,
           function(j){
             mcmc(
                  sampler$chains[[j]][-(1:10),c(1:4)])}))
  )


