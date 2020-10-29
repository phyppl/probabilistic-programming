class TDBAModel < PhyModel<PhyNode, TDBDParameter> {
  λ_k:Real;
  λ_θ:Real;
  z_σ2:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.z ~ Gaussian(0, z_σ2);
  }

  fiber step() -> Event {
    auto λ_beg <- θ.λ * exp(θ.z * (obs.age() - node.t_beg));
    auto λ_end <- θ.λ * exp(θ.z * (obs.age() - node.t_end));
    auto λ_0 <- θ.λ * exp(θ.z * obs.age());

    yield FactorEvent(
      -(λ_end - λ_beg) / θ.z
      - 2 * log(ρ - (ρ - 1) * exp((λ_beg - λ_0) / θ.z))
      + 2 * log(ρ - (ρ - 1) * exp((λ_end - λ_0) / θ.z))
    );

    if node.isSpeciation() {
      0.0 ~> Exponential(λ_end);
    }

    if node.isLeaf() {
      true ~> Bernoulli(ρ);
    }
  }

  fiber finish() -> Event {
    yield FactorEvent(
      2 * log(1 - (ρ - 1) / ρ * exp((θ.λ - θ.λ * exp(θ.z * obs.age())) / θ.z))
    );
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    z_σ2 <-? buffer.getReal("z_σ2");
    ρ <-? buffer.getReal("ρ");
  }
}
