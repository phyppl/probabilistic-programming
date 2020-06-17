class PhySampler {
  filter:ParticleFilter;
  nsamples:Integer <- 1;

  fiber sample(model:Model) -> (Model[_], Real[_], Real[_], Real[_], Integer[_]) {
    auto nsteps <- model.size();
    if filter.nsteps? {
      nsteps <- filter.nsteps!;
    }
    x:Model[_];
    w:Real[_];
    lnormalize:Real[nsteps + 1];
    ess:Real[nsteps + 1];
    npropagations:Integer[nsteps + 1];
    for n in 1..nsamples {
      auto f <- filter.filter(model);
      for t in 1..nsteps + 1 {
        f?;
        (x, w, lnormalize[t], ess[t], npropagations[t]) <- f!;
      }
      yield (x, w, lnormalize, ess, npropagations);
    }
  }

  function read(buffer:Buffer) {
    nsamples <-? buffer.get("nsamples", nsamples);
  }
}
