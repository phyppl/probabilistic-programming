class PhyTree<T> {
  queue:Queue<T>;
  auto treeAge <- 0.0;

  function size() -> Integer {
    return queue.size();
  }

  function age() -> Real {
    return treeAge;
  }

  function extantCount() -> Integer {
    auto walk <- queue.walk();
    auto count <- 0;
    while walk? {
      if walk!.t_end < 1e-5 {
        count <- count + 1;
      }
    }
    return count;
  }

  fiber walk() -> PhyNode {
    queue.walk();
  }

  function readNode(node:T, buffer:Buffer) {
    auto branch_length <- max(0.0, buffer.getReal("branch_length")!);
    node.taxon <- buffer.getInteger("taxon");
    node.t_end <- 0.0;
    node.t_beg <- branch_length;
    queue.pushBack(node);
    node.index <- queue.size();
    childBuffer:Buffer! <- buffer.walk("children");
    while childBuffer? {
      child:T;
      node.children <- true;
      child.parent <- node.index;
      readNode(child, childBuffer!);
      node.t_end <- child.t_beg;
      node.t_beg <- node.t_end + branch_length;
    }
  }

  function read(buffer:Buffer) {
    root:T;
    root.parent <- 0;
    tree:Buffer! <- buffer.walk("trees");
    if tree? {
      // We will read the first tree in the file
      readNode(root, tree!.getObject("root")!);
    }
    treeAge <- root.t_beg;
  }
}
