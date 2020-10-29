class CRBAModel < PhyModel<PhyNode, PhyParameter> {
  λ_k:Real;
  λ_θ:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
  }

  fiber step() -> Event {
    yield FactorEvent(
      - θ.λ * (node.t_beg - node.t_end)
      - 2 * log(ρ - (ρ - 1) * exp(-θ.λ * node.t_beg))
      + 2 * log(ρ - (ρ - 1) * exp(-θ.λ * node.t_end))
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
      2 * log(1 - (ρ - 1) / ρ * exp(-θ.λ * obs.age()))
    );
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    ρ <-? buffer.getReal("ρ");
  }
}
