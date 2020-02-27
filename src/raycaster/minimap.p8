function draw_minimap()
  if minimap then
    for y = 1, #world do
      for x = 1, #world[1] do
        if world[x][y] == 0 then pset(127 - x, y, 0) else pset(127 - x, y, 5) end
      end
    end

    pset(128 - pos.x, pos.y, 8)
  end
end
