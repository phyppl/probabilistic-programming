class TDBDModel < PhyModel<PhyNode, TDBDParameter> {
  λ_k:Real;
  λ_θ:Real;
  ε_min:Real;
  ε_max:Real;
  z_σ2:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.ε ~ Uniform(ε_min, ε_max);
    θ.z ~ Gaussian(0, z_σ2);
  }

  fiber step() -> Event {
    count_hs:Random<Integer>;  // number of speciation events in the segment
    auto L <- (exp(θ.z * (obs.age() - node.t_end)) -
               exp(θ.z * (obs.age() - node.t_beg))) / θ.z;
    count_hs ~ Poisson(θ.λ * L);

    for i in 1..Integer(count_hs) {
      u:Random<Real>;
      u ~ Uniform(0.0, 1.0);
      auto t <- node.t_beg -
                log(u * exp(θ.z * (node.t_beg - node.t_end)) - u + 1) / θ.z;
      simulateUnobserved(t);
      yield duple();
    }

    0 ~> Poisson(θ.λ * θ.ε * L);

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ * exp(θ.z * (obs.age() - node.t_end)));
    } else {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real) -> Event {
    // A little bit more complicated way of determining the time of death due to delayed sampling
    t_end:Real <- 0.0;
    auto L_d <- (exp(θ.z * obs.age()) -
                 exp(θ.z * (obs.age() - t_beg))) / θ.z;
    count_d:Random<Integer>;
    count_d ~ Poisson(θ.λ * θ.ε * L_d);
    if Integer(count_d) == 0 {
      // Species survived to the present time
      detected:Random<Boolean>;
      detected ~ Bernoulli(ρ);
      if detected {
        yield impossible();
      }
    }
    for i in 1..Integer(count_d) {
      u:Random<Real>;
      u ~ Uniform(0.0, 1.0);
      auto t <- t_beg - log(u * exp(θ.z * t_beg) - u + 1) / θ.z;
      if t > t_end {
        t_end <- t;
      }
    }

    count_b:Random<Integer>;  // the number of speciation events
    auto L <- (exp(θ.z * (obs.age() - t_end)) -
               exp(θ.z * (obs.age() - t_beg))) / θ.z;
    count_b ~ Poisson(θ.λ * L);
    for i in 1..Integer(count_b) {
      u:Random<Real>;
      u ~ Uniform(0.0, 1.0);
      auto t <- t_beg - log(u * exp(θ.z * (t_beg - t_end)) - u + 1) / θ.z;
      simulateUnobserved(t);
    }
  }

  fiber simulateUnobserved() -> Event {
    simulateUnobserved(obs.age());
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    ε_min <-? buffer.getReal("ε_min");
    ε_max <-? buffer.getReal("ε_max");
    z_σ2 <-? buffer.getReal("z_σ2");
    ρ <-? buffer.getReal("ρ");
  }
}
