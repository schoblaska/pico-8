function draw_rays()
  -- loop through each column of the screen
  for x = 0, 127 do
    -- set initial variables
    cameraX = 2 * x / 127 - 1

    rayDir = {
      x = dir.x + plane.x * cameraX,
      y = dir.y + plane.y * cameraX
    }

    mapPos = {x = flr(pos.x), y = flr(pos.y)} -- which square of the map we're evaluating
    sideDist = {} -- length of ray from current position to next x or y side
    deltaDist = {x = abs(1 / rayDir.x), y = abs(1/rayDir.y) } -- length of ray from one x or y side to the next
    step = {} -- what direction to step in (+1 or -1)

    -- determine step direction and sideDist for x and y
    for coord in all {"x", "y"} do
      if (rayDir[coord] < 0) then
        step[coord] = -1
        sideDist[coord] = (pos[coord] - mapPos[coord]) * deltaDist[coord]
      else
        step[coord] = 1
        sideDist[coord] = (mapPos[coord] + 1 - pos[coord]) * deltaDist[coord]
      end
    end

    -- trace the ray forward until a wall is hit
    hit = false
    wall = 0
    while (not hit) do
      if (sideDist.x < sideDist.y) then
        sideDist.x += deltaDist.x
        mapPos.x += step.x
        side = false
      else
        sideDist.y += deltaDist.y
        mapPos.y += step.y
        side = true
      end

      wall = world[mapPos.x][mapPos.y]
      if wall > 0 then hit = true end
    end

    -- calculate distance to wall (using camera plane)
    if side then coord = "y" else coord = "x" end
    wallDist = (mapPos[coord] - pos[coord] + (1 - step[coord]) / 2) / rayDir[coord]

    -- calculate line top and bottom
    lineHeight = 128 / wallDist
    drawTop = max(0, -lineHeight / 2 + 64)
    drawBot = min(127, lineHeight / 2 + 64)

    -- determine wall color
    if     wall == 1 and     side then lineColor = 3
    elseif wall == 1 and not side then lineColor = 11
    elseif wall == 2 and     side then lineColor = 12
    elseif wall == 2 and not side then lineColor = 13
    elseif wall == 3 and     side then lineColor = 6
    elseif wall == 3 and not side then lineColor = 7
    elseif wall == 4 and     side then lineColor = 8
    elseif wall == 4 and not side then lineColor = 2
    else                               lineColor = 10
    end

    line(x, drawTop, x, drawBot, lineColor)
  end
end
