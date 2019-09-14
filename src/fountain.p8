pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- fountain
-- by thrillhouse

function _init()
  particles = {}
  gravity = 0.1
  max_vel = 2
  min_time = 2
  max_time = 5
  min_life = 90
  max_life = 120
  ticker = 0
  colors = {1, 1, 1, 13, 13, 12, 12, 7}
  burst = 50
  next_p = rndb(min_time, max_time)
end

function _update()
  ticker += 1

  if (ticker == next_p) then
    add_p(64, 64)
    next_p = rndb(min_time, max_time)
    ticker = 0
  end

  if (btnp(🅾️)) then
    for i = 1, burst do add_p(64, 64) end
  end

  foreach(particles, update_p)
end

function _draw()
  cls()
  foreach(particles, draw_p)
end

function add_p(x, y)
  local p = {
    x = x,
    y = y,
    dx = rnd(max_vel) - max_vel / 2,
    dy = rnd(max_vel) *- 1,
    life_start = rndb(min_life, max_life)
  }

  p.life = p.life_start

  add(particles, p)
end

function update_p(p)
  if (p.life <= 0) then
    del(particles, p)
  else
    p.dy += gravity
    if ((p.y + p.dy) > 127) p.dy *= -0.8
    p.x += p.dx
    p.y += p.dy
    p.life -= 1
  end
end

function draw_p(p)
  local pcol = flr(p.life / p.life_start * #colors + 1)
  pset(p.x, p.y, colors[pcol])
end

#include utils/rndb.p8
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
