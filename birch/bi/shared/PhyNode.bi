class PhyNode {
  index:Integer;
  taxon:Integer?;
  t_beg:Real <- 0.0;
  t_end:Real <- 0.0;
  parent:Integer;
  // parent is an index into the depth-first ordered list of all nodes
  // (performance/memory usage optimization)
  children:Boolean <- false;

  function isRoot() -> Boolean {
    return parent == 0;
  }

  function isLeaf() -> Boolean {
    return !children;
  }

  function noStalk() -> Boolean {
    return t_beg - t_end < 1e-5;
  }

  function isSpeciation() -> Boolean {
    return children;
  }
}
