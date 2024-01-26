pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
  -- x coordinate of the leftmost column on the screen
  camera = 0

  sprites = {
    grass = { 1, 17 },
    road = { 2, 18 }
  }

  for x = 0, 127 do
    for y = 0, 15 do
      mset(x, y, sample(sprites.grass))
    end
  end

  draw_a_road(0, 0, 4, 128, 1)
end

function _update()
  if btnp(1) and camera < 110 then
    camera += 1
  elseif btnp(0) and camera > 0 then
    camera -= 1
  end
end

function _draw()
  for x = 0, 15 do
    for y = 0, 15 do
      spr(mget(x + camera, y), x * 8, y * 8)
    end
  end
end

function draw_a_road(sx, sy, sh, w, dx)
  local height = sh
  local thickness = 1

  -- slope: -1 to +1
  local slope = 0

  -- wobble: how many steps to draw before potentially changing direction
  local wobble = 4

  -- how close do we let the road get to the edge of the screen?
  local bleed = 4

  for x = sx, sx + dx * w - 1, dx do
    if height < bleed then
      height = bleed
    elseif height > 15 - bleed then
      height = 15 - bleed
    end

    if x % wobble == 0 then
      if height == bleed then
        slope = 0 + sample({ 0, 0.25, 0.5, 0.5 })
      elseif height == 15 - bleed then
        slope = 0 + sample({ 0, -0.25, -0.5, -0.5 })
      elseif slope == 0 then
        slope += sample({ 0, -0.25, -0.25, 0.25, 0.25 })
      elseif slope > 0.5 then
        slope += sample({ 0, -0.5, -0.25, 0.25 })
      elseif slope < 0.5 then
        slope += sample({ 0, 0.5, 0.25, -0.25 })
      else
        slope += sample({ 0, 0, -0.25, 0.25 })
      end
    end

    if slope > 1 then
      slope = 1
    elseif slope < -1 then
      slope = -1
    end

    -- draw an extra road tile whenever height changes
    -- without it, the road looks narrow on steeper slopes
    if flr(height + slope) > flr(height) then
      mset(x, sy + flr(height - thickness), sample(sprites.road))
    elseif flr(height + slope) < flr(height) then
      mset(x, sy + flr(height + thickness), sample(sprites.road))
    end

    height += slope

    for yoff = -thickness, thickness do
      mset(x, sy + flr(height + yoff), sample(sprites.road))
    end
  end

  return height
end

function sample(array)
  return array[flr(rnd(#array)) + 1]
end

__gfx__
00000000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333333331111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbbbbb5555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
