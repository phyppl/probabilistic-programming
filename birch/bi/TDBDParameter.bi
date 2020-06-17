class TDBDParameter < PhyParameter {
  z:Random<Real>;

  function write(buffer:Buffer) {
    super.write(buffer);
    buffer.set("z", z);
  }
}
