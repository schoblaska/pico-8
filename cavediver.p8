pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  game_over = false
  make_player()
  make_cave()
end

function _update()
  update_cave()
  move_player()
end

function _draw()
  cls()
  draw_cave()
  draw_player()
end

function make_player()
  player = {
    x = 24,
    y = 60,
    dy = 0,
    rise = 1,
    fall = 2,
    dead = 3,
    speed = 2,
    score = 0
  }
end

function move_player()
  gravity = 0.1
  jumpity = 2

  player.dy += gravity

  if (btnp(2)) then
    player.dy -= jumpity
  end

  player.y += player.dy
end

function draw_player()
  if (game_over) then
    spr(player.dead, player.x, player.y)
  elseif (player.dy < 0) then
    spr(player.rise, player.x, player.y)
  else
    spr(player.fall, player.x, player.y)
  end
end

function make_cave()
  cave = {{
    ["top"] = 5,
    ["btm"] = 119
  }}

  top = 45
  btm = 85
end

function update_cave()
  if (#cave > player.speed) then
    for i = 1, player.speed do
      del(cave, cave[1])
    end
  end

  while (#cave < 128) do
    local col = {}
    local up = flr(rnd(7) - 3)
    local dwn = flr(rnd(7) - 3)

    col.top = mid(3, cave[#cave].top + up, top)
    col.btm = mid(btm, cave[#cave].btm + dwn, 124)
    add(cave, col)
  end
end

function draw_cave()
  top_color = 5
  btm_color = 5

  for i = 1, #cave do
    line(i - 1, 0,   i - 1, cave[i].top, top_color)
    line(i - 1, 127, i - 1, cave[i].btm, btm_color)
  end
end
__gfx__
0000000000baab0000baab0000b88b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbaabb00bbaabb00bb88bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000bbbbbb00bbbbbb00bbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000bb9999bbbb9999bbbb6776bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000090990900909909006577560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700099999900990099007766770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000099ee9900990099007655670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000009999000099990000766700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
