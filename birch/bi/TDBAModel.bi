class TDBAModel < PhyModel<PhyNode, TDBDParameter> {
  λ_k:Real;
  λ_θ:Real;
  z_σ2:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.z ~ Gaussian(0, z_σ2);
  }

  fiber step() -> Event {
    auto λ_beg <- θ.λ * exp(θ.z * (obs.age() - node.t_beg));
    auto λ_end <- θ.λ * exp(θ.z * (obs.age() - node.t_end));
    auto λ_0 <- θ.λ * exp(θ.z * obs.age());

    yield FactorEvent(-(λ_end - λ_beg) / θ.z);

    if node.isSpeciation() {
      0.0 ~> Exponential(λ_end);
    }
  }

  fiber finish() -> Event {
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    z_σ2 <-? buffer.getReal("z_σ2");
  }
}
