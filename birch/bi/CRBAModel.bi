class CRBAModel < PhyModel<PhyNode, PhyParameter> {
  λ_k:Real;
  λ_θ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
  }

  fiber step() -> Event {
    yield FactorEvent(-θ.λ * (node.t_beg - node.t_end));

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ);
    }
  }

  fiber finish() -> Event {
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
  }
}
