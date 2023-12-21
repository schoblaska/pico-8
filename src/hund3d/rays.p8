-- 1200  there are 6 wall textures, arranged on the sprite sheet
-- 3400  like this. even-numbered textures are the shadowy versions
-- 5600  of the odd-numbered texture to their left
-- 0000
local texOrigins = {
  {x = 0,  y = 0},
  {x = 32, y = 0},
  {x = 0,  y = 32},
  {x = 32, y = 32},
  {x = 0,  y = 64},
  {x = 32, y = 64},
  {x = 0,  y = 96}
}

function draw_rays()
  rectfill(0, 0, 127, 63, 13)
  zBuf = {}

  -- loop through each column of the screen
  for x = 0, 127 do
    -- set initial variables
    cameraX = 2 * x / 127 - 1

    rayDir = {
      x = player.dir.x + plane.x * cameraX,
      y = player.dir.y + plane.y * cameraX
    }

    mapPos = {x = flr(player.pos.x), y = flr(player.pos.y)} -- which square of the map we're evaluating
    sideDist = {} -- length of ray from current position to next x or y side
    deltaDist = {x = abs(1 / rayDir.x), y = abs(1/rayDir.y) } -- length of ray from one x or y side to the next
    step = {} -- what direction to step in (+1 or -1)

    -- determine step direction and sideDist for x and y
    for coord in all {"x", "y"} do
      if (rayDir[coord] < 0) then
        step[coord] = -1
        sideDist[coord] = (player.pos[coord] - mapPos[coord]) * deltaDist[coord]
      else
        step[coord] = 1
        sideDist[coord] = (mapPos[coord] + 1 - player.pos[coord]) * deltaDist[coord]
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
    wallDist = (mapPos[coord] - player.pos[coord] + (1 - step[coord]) / 2) / rayDir[coord]
    zBuf[x] = wallDist

    -- calculate line top and bottom
    lineHeight = 128 / wallDist
    drawTop = max(0, -lineHeight / 2 + 64)
    drawBot = min(127, lineHeight / 2 + 64)

    -- calculate the x coordinate of the wall where the ray hit
    if side then
      wallX = player.pos.x + wallDist * rayDir.x
    else
      wallX = player.pos.y + wallDist * rayDir.y
    end

    wallX -= flr(wallX)

    -- calculate the x coordinate of the texture
    texX = flr(wallX * 32)

    if (side and rayDir.y < 0) or (not side and rayDir.x > 0) then
      texX = 32 - texX - 1
    end

    -- use sspr to select a column of the texture and stretch it over the line to draw
    texNum = wall_texture(wall, side)
    sx = texOrigins[texNum].x + texX
    dy = -lineHeight / 2 + 64

    line(x, drawTop, x, drawBot, 0)
    sspr(sx, texOrigins[texNum].y, 1, 32, x, dy, 1, lineHeight)
  end

  -- calculate distance to player for each sprite
  for spriteInstance in all(spriteInstances) do
    spriteInstance.distanceToPlayer = distance(player.pos, spriteInstance)
  end

  -- sort sprites based on distance to player
  for i = 1, #spriteInstances do
    local j = i
    while j > 1 and spriteInstances[j-1].distanceToPlayer < spriteInstances[j].distanceToPlayer do
      spriteInstances[j], spriteInstances[j - 1] = spriteInstances[j - 1], spriteInstances[j]
      j = j - 1
    end
  end

  -- draw sprites
  for spriteInstance in all(spriteInstances) do
    spriteInstance.rX = spriteInstance.x - player.pos.x
    spriteInstance.rY = spriteInstance.y - player.pos.y

    -- transform sprite
    invDet = 1 / (plane.x * player.dir.y - player.dir.x * plane.y)

    transform = {
      x = invDet * (player.dir.y * spriteInstance.rX - player.dir.x * spriteInstance.rY),
      y = invDet * (-plane.y * spriteInstance.rX + plane.x * spriteInstance.rY)
    }

    -- params for scaling and moving sprite
    vMoveScreen = flr(spriteInstance.sprite.vMove / transform.y)

    spriteScreenX = flr(64 * (1 + transform.x / transform.y))
    spriteHeight = abs(flr(128 / transform.y)) * spriteInstance.sprite.vScale
    drawStartY = flr(-spriteHeight / 2 + 64) + vMoveScreen

    spriteWidth = abs(flr(128 / transform.y)) * spriteInstance.sprite.hScale
    drawStartX = flr(max(0, -spriteWidth / 2 + spriteScreenX))
    drawEndX = flr(min(127, spriteWidth / 2 + spriteScreenX))

    for stripe = drawStartX, drawEndX do
      if spriteInstance.sprite.animated and flr(time()) % 2 == 0 then
        texOffset = spriteInstance.sprite.x + spriteInstance.sprite.w
      else
        texOffset = spriteInstance.sprite.x
      end

      if transform.y > 0 and transform.y < zBuf[stripe] then
        texX = flr((stripe - (-spriteWidth / 2 + spriteScreenX)) * spriteInstance.sprite.w / spriteWidth)
        texX = min(max(0, texX), spriteInstance.sprite.w - 1)
        sspr(texX + texOffset, spriteInstance.sprite.y, 1, spriteInstance.sprite.h, stripe, drawStartY, 1, spriteHeight)
      end
    end
  end
end

function wall_texture(wall, side)
  if     wall == 1 and     side then return 1
  elseif wall == 1 and not side then return 2
  elseif wall == 2 and     side then return 3
  elseif wall == 2 and not side then return 4
  elseif wall == 3 and     side then return 5
  elseif wall == 3 and not side then return 6
  elseif wall == 4              then return 7
  else                               return 1
  end
end
