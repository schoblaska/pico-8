pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- raycaster
-- by thrillhouse

function _init()
  world = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,0,0,0,5,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,4,4,4,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  }

  pos = {x = 22, y = 12}
  dir = {x = -1, y = 0}
  plane = {x = 0, y = 0.66}

  rotSpeed = 0.01
  moveSpeed = 0.25
end

function _update()
  oldDir = dir
  oldPlane = plane

  -- rotate left
  if btn(0) and not btn(4) then
    dir = { x = oldDir.x * cos(-rotSpeed) - oldDir.y * sin(-rotSpeed),
            y = oldDir.x * sin(-rotSpeed) + oldDir.y * cos(-rotSpeed) }
    plane = { x = oldPlane.x * cos(-rotSpeed) - oldPlane.y * sin(-rotSpeed),
              y = oldPlane.x * sin(-rotSpeed) + oldPlane.y * cos(-rotSpeed) }
  end

  -- rotate right
  if btn(1) and not btn(4) then
    dir = { x = oldDir.x * cos(rotSpeed) - oldDir.y * sin(rotSpeed),
            y = oldDir.x * sin(rotSpeed) + oldDir.y * cos(rotSpeed) }
    plane = { x = oldPlane.x * cos(rotSpeed) - oldPlane.y * sin(rotSpeed),
              y = oldPlane.x * sin(rotSpeed) + oldPlane.y * cos(rotSpeed) }
  end

  -- walk forward
  if btn(2) then
    if world[flr(pos.x + dir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x += dir.x * moveSpeed end
    if world[flr(pos.x)][flr(pos.y + dir.y * moveSpeed)] == 0 then pos.y += dir.y * moveSpeed end
  end

  -- walk backward
  if btn(3) then
    if world[flr(pos.x - dir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x -= dir.x * moveSpeed end
    if world[flr(pos.x)][flr(pos.y - dir.y * moveSpeed)] == 0 then pos.y -= dir.y * moveSpeed end
  end

  -- strafe left
  if btn(0) and btn(4) then
    moveDir = { x = dir.x * cos(0.25) - dir.y * sin(0.25),
                y = dir.x * sin(0.25) + dir.y * cos(0.25) }

    if world[flr(pos.x - moveDir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x -= moveDir.x * moveSpeed end
    if world[flr(pos.x)][flr(pos.y - moveDir.y * moveSpeed)] == 0 then pos.y -= moveDir.y * moveSpeed end
  end

  -- strafe right
  if btn(1) and btn(4) then
    moveDir = { x = dir.x * cos(0.25) - dir.y * sin(0.25),
                y = dir.x * sin(0.25) + dir.y * cos(0.25) }

    if world[flr(pos.x + moveDir.x * moveSpeed)][flr(pos.y)] == 0 then pos.x += moveDir.x * moveSpeed end
    if world[flr(pos.x)][flr(pos.y + moveDir.y * moveSpeed)] == 0 then pos.y += moveDir.y * moveSpeed end
  end
end

function _draw()
  cls()

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

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
