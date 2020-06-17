class PhyModel<NodeType, ParameterType> < Model {
  obs:PhyTree<NodeType>;  // Observed tree
  obsWalk:NodeType!;

  θs:Vector<ParameterType>;
  indexByNode:Integer[_];

  node:NodeType;    // Current node
  θ:ParameterType;  // Current parameter
  index:Integer;    // Current parameter's index

  function switchToParameter(θ:ParameterType) -> Integer {
    θs.pushBack(θ);
    this.θ <- θ;
    index <- θs.size();
    return index;
  }

  function switchToRegisteredParameter(index:Integer) {
    θ <- θs.get(index);
    this.index <- index;
  }

  function size() -> Integer {
    return 1 + obs.size();
  }

  fiber initial() -> Event {
    auto N <- obs.extantCount();
    yield FactorEvent((N-1)*log(2) - log_factorial(N));
  }

  fiber step() -> Event {}

  fiber simulateUnobserved() -> Event {
    // Used for the survivorship bias correction, see finish() below
    yield impossible();
  }

  fiber simulate() -> Event {
    θs.clear();
    indexByNode <- vector(0, size());
    θ:ParameterType;
    switchToParameter(θ);
    initial();
    obsWalk <- obs.walk();
  }

  fiber simulate(t:Integer) -> Event {
    if obsWalk? {
      node <- obsWalk!;
      if !node.isRoot() {
        if indexByNode[node.parent] == 0 {
          return;
        }
        switchToRegisteredParameter(indexByNode[node.parent]);
      }
      if !node.isRoot() || !node.noStalk() {
        step();
      }
      indexByNode[t] <- index;
    } else if t == size() {
      switchToRegisteredParameter(1);
      finish();
    }
  }

  fiber finish() -> Event {
    auto i <- 0;
    while true {
      i <- i + 1;
      if delay.handle(simulateUnobserved()) == -inf {
        if delay.handle(simulateUnobserved()) == -inf {
          yield FactorEvent(log(i));
          return;
        }
      }
    }
  }

  function read(buffer:Buffer) {
    auto treePath <- buffer.getString("tree");
    if treePath? {
      treeReader:JSONReader;
      treeBuffer:MemoryBuffer;
      treeReader.open(treePath!);
      treeReader.read(treeBuffer);
      treeReader.close();
      obs.read(treeBuffer);
    }
  }

  function write(buffer:Buffer) {
    if θs.size() > 0 {
      θs.get(1).write(buffer);
    }
    /*  // Uncomment to store all θs
    buffer.setArray();
    auto θ <- θs.walk();
    while θ? {
      θ!.write(buffer.push());
    }
    */
  }
}
