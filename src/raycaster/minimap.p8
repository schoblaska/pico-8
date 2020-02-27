function draw_minimap()
  if minimap then
    for y = 1, #world do
      for x = 1, #world[1] do
        if world[x][y] == 0 then pset(128 - x, y - 1, 0) else pset(128 - x, y - 1, 5) end
      end
    end

    pset(129 - pos.x, pos.y - 1, 8)
  end
end
