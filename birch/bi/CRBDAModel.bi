class CRBDAModel < PhyModel<PhyNode, PhyParameter> {
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
    yield FactorEvent(
      - θ.λ * (1 - θ.ε) * (node.t_beg - node.t_end)
      - 2 * log(ρ - (ρ - 1 + θ.ε) * exp(-θ.λ * (1 - θ.ε) * node.t_beg))
      + 2 * log(ρ - (ρ - 1 + θ.ε) * exp(-θ.λ * (1 - θ.ε) * node.t_end))
    );

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ);
    }

    if node.isLeaf() {
      true ~> Bernoulli(ρ);
    }
  }

  fiber finish() -> Event {
    yield FactorEvent(
      -2 * log((1 - θ.ε) / (1 - (ρ - 1 + θ.ε) / ρ * exp(-θ.λ * (1 - θ.ε) * obs.age())))
    );
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
