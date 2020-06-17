class PhyParameter {
  λ:Random<Real>;
  ε:Random<Real>;

  function write(buffer:Buffer) {
    buffer.set("λ", λ);
    buffer.set("ε", ε);
  }
}
