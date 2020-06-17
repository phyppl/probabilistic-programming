class ClaDS0Parameter < PhyParameter {
  log_α:Random<Real>;
  σ2:Random<Real>;
  λ_factor:Real <- 1.0;
  ref:Integer;

  function write(buffer:Buffer) {
    super.write(buffer);
    buffer.set("log_α", log_α);
    buffer.set("σ2", σ2);
    buffer.set("λ_factor", λ_factor);
    buffer.set("ref", ref);
  }
}

function ClaDS0Parameter(θ:ClaDS0Parameter) -> ClaDS0Parameter {
  θ':ClaDS0Parameter;
  θ'.λ <- θ.λ;
  θ'.log_α <- θ.log_α;
  θ'.σ2 <- θ.σ2;
  θ'.λ_factor <- θ.λ_factor;
  return θ';
}
