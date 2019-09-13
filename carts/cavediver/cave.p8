function make_cave()
  cave = {{
    ["top"] = 5,
    ["btm"] = 119
  }}

  top = 45
  btm = 85
end

function update_cave()
  cave_colors = {5, 13}

  if (#cave > player.speed) then
    for i = 1, player.speed do
      del(cave, cave[1])
    end
  end

  while (#cave < 128) do
    local up = flr(rnd(7) - 3)
    local dwn = flr(rnd(7) - 3)

    local col = {
      top = mid(3, cave[#cave].top + up, top),
      btm = mid(btm, cave[#cave].btm + dwn, 124),
      clr = cave_colors[flr(rnd(#cave_colors)) + 1]
    }

    add(cave, col)
  end
end

function draw_cave()
  for i = 1, #cave do
    line(i - 1, 0,   i - 1, cave[i].top, cave[i].clr)
    line(i - 1, 127, i - 1, cave[i].btm, cave[i].clr)
  end
end
