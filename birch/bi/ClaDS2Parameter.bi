class ClaDS2Parameter < PhyParameter {
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

function ClaDS2Parameter(θ:ClaDS2Parameter) -> ClaDS2Parameter {
  θ':ClaDS2Parameter;
  θ'.λ <- θ.λ;
  θ'.ε <- θ.ε;
  θ'.log_α <- θ.log_α;
  θ'.σ2 <- θ.σ2;
  θ'.λ_factor <- θ.λ_factor;
  return θ';
}
