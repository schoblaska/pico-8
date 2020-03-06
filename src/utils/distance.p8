-- distance between two objects that have an x and y
function distance(a, b)
  return (a.x - b.x) * (a.x - b.x) + (a.y - b.y) * (a.y - b.y)
end
