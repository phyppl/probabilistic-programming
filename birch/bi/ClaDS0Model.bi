class ClaDS0Model < PhyModel<PhyNode, ClaDS0Parameter> {
  λ_k:Real;
  λ_θ:Real;
  σ2_α:Real;
  σ2_β:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.σ2 ~ InverseGamma(σ2_α, σ2_β);
    θ.log_α ~ Gaussian(0, θ.σ2);
    θ.ref <- 1;
  }

  fiber step() -> Event {
    switchToParameter(ClaDS0Parameter(θ));  // Each branch has its own parameter
    θ.ref <- node.index;

    auto last <- false;
    auto seg_beg <- node.t_beg;

    while !last {
      φ:Random<Real>;
      φ ~ Gaussian(θ.log_α, θ.σ2);
      θ.λ_factor <- θ.λ_factor * exp(φ);
      Δ:Random<Real>;  // waiting time until a speciation event
      if θ.λ_factor < 1e-5 || θ.λ_factor > 1e5 { yield impossible(); }
      Δ ~ Exponential(θ.λ * θ.λ_factor);
      seg_end:Real <- seg_beg - Δ;
      if seg_end < node.t_end {
        last <- true;
        seg_end <- node.t_end;
      } else {
        simulateUnobserved(seg_end, θ.λ_factor);
        yield duple();
      }

      seg_beg <- seg_end;
    }

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ * θ.λ_factor);
    } else {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real, λ_factor_parent:Real) -> Event {
    if ρ == 1.0 {
      yield impossible();
    }
    φ:Random<Real>;
    φ ~ Gaussian(θ.log_α, θ.σ2);
    auto λ_factor <- λ_factor_parent * exp(φ);
    if λ_factor < 1e-5 || λ_factor > 1e5 { yield impossible(); }
    Δ:Random<Real>;  // waiting time until an speciation event
    Δ ~ Exponential(θ.λ * λ_factor);
    if Δ > t_beg {
      detected:Random<Boolean>;
      detected ~ Bernoulli(ρ);
      if detected {
        yield impossible();
      }
    } else {
      simulateUnobserved(t_beg-Δ, λ_factor);
      simulateUnobserved(t_beg-Δ, λ_factor);
    }
  }

  fiber simulateUnobserved() -> Event {
    if ρ == 1.0 {
      yield impossible();
    }
    simulateUnobserved(obs.age(), 1.0);
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    σ2_α <-? buffer.getReal("σ2_α");
    σ2_β <-? buffer.getReal("σ2_β");
    ρ <-? buffer.getReal("ρ");
  }
}
