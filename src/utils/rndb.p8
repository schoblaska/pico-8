-- random number between two values (inclusive)
function rndb(low, high)
  return flr(rnd(high - low + 1) + low)
end
