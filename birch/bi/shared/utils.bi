function duple() -> FactorEvent {
  return FactorEvent(log(2));
}

function impossible() -> FactorEvent {
  return FactorEvent(-inf);
}

function log_factorial(N:Integer) -> Real {
  assert N >= 0;
  res:Real <- 0.0;
  for n in 2..N {
    res <- res + log(n);
  }
  return res;
}
