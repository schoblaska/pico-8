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

  draw_a_road()
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

function draw_a_road()
  local h = 8
  local g = 1

  -- slope: -1 to +1
  local s = 0

  -- wobble: how many steps to draw before potentially changing direction
  local w = 4

  -- bleed: how close do we let the road get to the edge of the screen?
  local b = 4

  for x = 0, 127 do
    if h < b then
      h = b
    elseif h > 15 - b then
      h = 15 - b
    end

    if x % w == 0 then
      if h == b then
        s = 0 + sample({ 0, 0.5, 0.5 })
      elseif h == 15 - b then
        s = 0 - sample({ 0, 0.5, 0.5 })
      elseif s == 0 then
        s += sample({ -0.25, 0.25 })
      else
        s += sample({ 0, 0, -0.25, 0.25 })
      end
    end

    if s > 1 then
      s = 1
    elseif s < -1 then
      s = -1
    end

    -- draw an extra road tile whenever height changes
    -- without it, the road looks narrow on steeper slopes
    if flr(h + s) > flr(h) then
      mset(x, flr(h - g), sample(sprites.road))
    elseif flr(h + s) < flr(h) then
      mset(x, flr(h + g), sample(sprites.road))
    end

    h += s

    for yoff = -g, g do
      mset(x, flr(h + yoff), sample(sprites.road))
    end
  end
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
