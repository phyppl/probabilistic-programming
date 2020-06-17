class CRBModel < PhyModel<PhyNode, PhyParameter> {
  λ_k:Real;
  λ_θ:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
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

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ);
    } else {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real) -> Event {
    if ρ == 1.0 {
      yield impossible();
    }
    Δ:Random<Real>;  // waiting time until an speciation event
    Δ ~ Exponential(θ.λ);
    if Δ > t_beg {
      detected:Random<Boolean>;
      detected ~ Bernoulli(ρ);
      if detected {
        yield impossible();
      }
    } else {
      simulateUnobserved(t_beg-Δ);
      simulateUnobserved(t_beg-Δ);
    }
  }

  fiber simulateUnobserved() -> Event {
    if ρ == 1.0 {
      yield impossible();
    }
    simulateUnobserved(obs.age());
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    ρ <-? buffer.getReal("ρ");
  }
}
