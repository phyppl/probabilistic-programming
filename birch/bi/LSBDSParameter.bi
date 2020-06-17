class LSBDSParameter < PhyParameter {
  η:Random<Real>;
  ref:Integer;
  ξ:Real;

  function write(buffer:Buffer) {
    super.write(buffer);
    buffer.set("η", η);
    buffer.set("ref", ref);
    buffer.set("ξ", ξ);
  }
}
