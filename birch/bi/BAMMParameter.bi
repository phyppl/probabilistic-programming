class BAMMParameter < PhyParameter {
  η:Random<Real>;
  z:Random<Real>;
  ref:Integer;
  ξ:Real;

  function write(buffer:Buffer) {
    super.write(buffer);
    buffer.set("η", η);
    buffer.set("z", z);
    buffer.set("ref", ref);
    buffer.set("ξ", ξ);
  }
}
