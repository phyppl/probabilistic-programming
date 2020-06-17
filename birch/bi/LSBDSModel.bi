class LSBDSModel < PhyModel<PhyNode, LSBDSParameter> {
  λ_k:Real;
  λ_θ:Real;
  ε_min:Real;
  ε_max:Real;
  η_k:Real;
  η_θ:Real;
  ρ:Real;

  fiber initial() -> Event {
    super.initial();
    θ.λ ~ Gamma(λ_k, λ_θ);
    θ.ε ~ Uniform(ε_min, ε_max);
    θ.η ~ Gamma(η_k, η_θ);
    θ.ref <- 1;
    θ.ξ <- obs.age();
  }

  fiber step() -> Event {
    auto last_seg <- false;
    auto seg_beg <- node.t_beg;

    while !last_seg {
      Δ_rs:Random<Real>;  // waiting time until a parameter shift event
      Δ_rs ~ Exponential(θ.η);
      seg_end:Real <- seg_beg - Δ_rs;
      if seg_end < node.t_end {
        last_seg <- true;
        seg_end <- node.t_end;
      }

      count_hs:Random<Integer>;  // number of speciation events in the segment
      count_hs ~ Poisson(θ.λ * (seg_beg - seg_end));
      for i in 1..Integer(count_hs) {
        t:Random<Real>;
        t ~ Uniform(seg_end, seg_beg);
        simulateUnobserved(t, θ.λ, θ.ε);
        yield duple();
      }

      0 ~> Poisson(θ.λ * θ.ε * (seg_beg - seg_end));

      if !last_seg {
        seg_beg <- seg_end;
        θ':LSBDSParameter;
        θ'.λ ~ Gamma(λ_k, λ_θ);
        θ'.ε ~ Uniform(ε_min, ε_max);
        θ'.η <- θ.η;
        θ'.ξ <- seg_end;
        θ'.ref <- node.index;
        switchToParameter(θ');
      }
    }

    if node.isSpeciation() {
      0.0 ~> Exponential(θ.λ);
    } else {
      true ~> Bernoulli(ρ);
    }
  }

  fiber simulateUnobserved(t_beg:Real, λ:Random<Real>, ε:Random<Real>) -> Event {
    auto rs <- true;  // the current segment ends with a rates shift event
    Δ_rs:Random<Real>;  // waiting time until a rates shift event
    Δ_rs ~ Exponential(θ.η);
    t_end:Real <- t_beg - Δ_rs;
    if t_end < 0 {
      rs <- false;
      t_end <- 0;
    }

    Δ_d:Random<Real>;  // waiting time until an extinction event
    Δ_d ~ Exponential(λ * ε);
    if Δ_d < t_beg - t_end {
      rs <- false;
      t_end <- t_beg - Δ_d;
    } else if !rs {
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
      simulateUnobserved(t_end, λ', ε');
    }

    count_b:Random<Integer>;  // number of speciation events in the segment
    count_b ~ Poisson(λ * (t_beg - t_end));
    for i in 1..Integer(count_b) {
      t:Random<Real>;
      t ~ Uniform(t_end, t_beg);
      simulateUnobserved(t, λ, ε);
    }
  }

  fiber simulateUnobserved() -> Event {
    simulateUnobserved(obs.age(), θ.λ, θ.ε);
  }

  function read(buffer:Buffer) {
    super.read(buffer);
    λ_k <-? buffer.getReal("λ_k");
    λ_θ <-? buffer.getReal("λ_θ");
    ε_min <-? buffer.getReal("ε_min");
    ε_max <-? buffer.getReal("ε_max");
    η_k <-? buffer.getReal("η_k");
    η_θ <-? buffer.getReal("η_θ");
    ρ <-? buffer.getReal("ρ");
  }
}
