function init_map()
  world = {}
  spriteInstances = {}

  for mapX = 96, 127 do
    worldX = mapX - 95
    world[worldX] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}

    for mapY = 96, 127 do
      worldY = 127 - mapY
      pixel = sget(mapX, mapY)

      if pixel == 7 then      -- white wall
        world[worldX][worldY] = 1
      elseif pixel == 12 then -- blue wall
        world[worldX][worldY] = 2
      elseif pixel == 8 then  -- red wall
        world[worldX][worldY] = 3
      elseif pixel == 1 then  -- prison wall
        world[worldX][worldY] = 4
      elseif pixel == 11 then -- player
        player.pos = {x = worldX + 0.5, y = worldY}
        player.dir = {x = 0, y = 1}
        plane = {x = 0.66, y = 0}
      elseif pixel == 9 then  -- doggo
        add(spriteInstances, {sprite = sprites.dogAngry, x = worldX + 0.5, y = worldY + 0.5})
      elseif pixel == 10 then -- light
        add(spriteInstances, {sprite = sprites.light, x = worldX + 0.5, y = worldY + 0.5})
      elseif pixel == 3 then  -- chest
        add(spriteInstances, {sprite = sprites.chest, x = worldX + 0.5, y = worldY + 0.5})
      end
    end
  end
end
