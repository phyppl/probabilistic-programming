class BAMMModel < PhyModel<PhyNode, BAMMParameter> {
  λ_k:Real;
  λ_θ:Real;
  ε_min:Real;
  ε_max:Real;
  η_k:Real;
  η_θ:Real;
  z_σ2:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.ε ~ Uniform(ε_min, ε_max);
    θ.z ~ Gaussian(0, z_σ2);
    θ.η ~ Gamma(η_k, η_θ);
    θ.ref <- 1;
    θ.ξ <- obs.age();
  }

  fiber step() -> Event {
    auto last_seg <- false;
    auto seg_beg <- node.t_beg;
    while !last_seg {
      Δ_rs:Random<Real>;  // waiting time until a rates shift event
      Δ_rs ~ Exponential(θ.η);
      seg_end:Real <- seg_beg - Δ_rs;
      if seg_end < node.t_end {
        last_seg <- true;
        seg_end <- node.t_end;
      }

      count_hs:Random<Integer>;  // number of speciation events in the segment
      auto L <- (exp(θ.z * (θ.ξ - seg_end)) -
                 exp(θ.z * (θ.ξ - seg_beg))) / θ.z;
      count_hs ~ Poisson(θ.λ * L);

      for i in 1..Integer(count_hs) {
        u:Random<Real>;
        u ~ Uniform(0.0, 1.0);
        auto t <- seg_beg -
                  log(u * exp(θ.z * (seg_beg - seg_end)) - u + 1) / θ.z;
        simulateUnobserved(t, θ.λ, θ.ε, θ.z, θ.ξ);
        yield duple();
      }

      0 ~> Poisson(θ.λ * θ.ε * (seg_beg - seg_end));

      if !last_seg {
        seg_beg <- seg_end;
        θ':BAMMParameter;
        θ'.λ ~ Gamma(λ_k, λ_θ);
        θ'.ε ~ Uniform(ε_min, ε_max);
        θ'.z ~ Gaussian(0, z_σ2);
        θ'.η <- θ.η;
        θ'.ref <- node.index;
        θ'.ξ <- seg_end;
        switchToParameter(θ');
      }
    }

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ * exp(θ.z * (θ.ξ - node.t_end)));
    } else {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real, λ:Random<Real>, ε:Random<Real>,
                           z:Random<Real>, ξ:Real) -> Event {
    auto rs <- false;  // the current segment ends with a rates shift event
    auto t_end <- 0.0;
    Δ_rs:Random<Real>;  // waiting time until a rates shift event
    Δ_rs ~ Exponential(θ.η);
    if Δ_rs < t_beg {
      rs <- true;
      t_end <- t_beg - Δ_rs;
    }

    Δ_d:Random<Real>;  // waiting time until an extinction event
    Δ_d ~ Exponential(λ * ε);
    if Δ_d < t_beg - t_end {
      rs <- false;
      t_end <- t_beg - Δ_d;
    }

    if t_end <= 0.0 {
      // Species survived to the present time
      detected:Random<Boolean>;
      detected ~ Bernoulli(ρ);
      if detected {
        yield impossible();
      }
    }

    if rs {
      λ':Random<Real>;
      λ' ~ Gamma(λ_k, λ_θ);
      ε':Random<Real>;
      ε' ~ Uniform(ε_min, ε_max);
      z':Random<Real>;
      z' ~ Gaussian(0, z_σ2);
      simulateUnobserved(t_end, λ', ε', z', t_end);
    }

    count_b:Random<Integer>;  // the number of speciation events in the segment
    auto L <- (exp(z * (ξ - t_end)) - exp(z * (ξ - t_beg))) / z;
    count_b ~ Poisson(λ * L);
    for i in 1..Integer(count_b) {
      u:Random<Real>;
      u ~ Uniform(0.0, 1.0);
      auto t <- t_beg - log(u * exp(z * (t_beg - t_end)) - u + 1) / z;
      simulateUnobserved(t, λ, ε, z, ξ);
    }
  }

  fiber simulateUnobserved() -> Event {
    simulateUnobserved(obs.age(), θ.λ, θ.ε, θ.z, θ.ξ);
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    ε_min <-? buffer.getReal("ε_min");
    ε_max <-? buffer.getReal("ε_max");
    η_k <-? buffer.getReal("η_k");
    η_θ <-? buffer.getReal("η_θ");
    z_σ2 <-? buffer.getReal("z_σ2");
    ρ <-? buffer.getReal("ρ");
  }
}
