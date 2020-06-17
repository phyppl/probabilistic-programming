class CRBDModel < PhyModel<PhyNode, PhyParameter> {
  λ_k:Real;
  λ_θ:Real;
  ε_min:Real;
  ε_max:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.ε ~ Uniform(ε_min, ε_max);
  }

  fiber step() -> Event {
    count:Random<Integer>;  // number of (hidden) speciation events
    count ~ Poisson(θ.λ * (node.t_beg - node.t_end));
    for i in 1..Integer(count) {
      t:Random<Real>;
      t ~ Uniform(node.t_end, node.t_beg);
      simulateUnobserved(t);
      yield duple();
    }

    0 ~> Poisson(θ.λ * θ.ε * (node.t_beg - node.t_end));

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ);
    }

    if node.isLeaf() {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real) -> Event {
    Δ_d:Random<Real>;  // waiting time until an extinction event
    Δ_d ~ Exponential(θ.λ * θ.ε);
    t_end:Real <- t_beg - Δ_d;
    if t_end < 0 {
      // Species survived to the present time
      detected:Random<Boolean>;
      detected ~ Bernoulli(ρ);
      if detected {
        yield impossible();
      }
      t_end <- 0;
    }
    count:Random<Integer>;  // number of speciation events
    count ~ Poisson(θ.λ * (t_beg - t_end));
    for i in 1..Integer(count) {
      t:Random<Real>;
      t ~ Uniform(t_end, t_beg);
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
    ρ <-? buffer.getReal("ρ");
  }
}
