pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _init()
  game_over = false
  make_player()
  make_cave()
end

function _update()
  if (not game_over) then
    update_cave()
    move_player()
    check_hit()
  else
    if (btnp(5)) _init()
  end
end

function _draw()
  cls()
  draw_cave()
  draw_player()

  if (game_over) then
    print("game over!", 44, 44, 7)
    print("your score: " .. player.score, 34, 54, 7)
    print("press ❎ to play again!", 18, 62, 6)
  else
    print("score: " .. player.score, 2, 2, 7)
  end
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
    sfx(0)
  end

  player.y += player.dy

  player.score += player.speed
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

function check_hit()
  for i = player.x, player.x + 7 do
    if (cave[i + 1].top > player.y
      or cave[i + 1].btm < player.y + 7) then
      game_over = true
      sfx(1)
    end
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
  cave_colors = {5, 13}

  if (#cave > player.speed) then
    for i = 1, player.speed do
      del(cave, cave[1])
    end
  end

  while (#cave < 128) do
    local up = flr(rnd(7) - 3)
    local dwn = flr(rnd(7) - 3)

    local col = {
      top = mid(3, cave[#cave].top + up, top),
      btm = mid(btm, cave[#cave].btm + dwn, 124),
      clr = cave_colors[flr(rnd(#cave_colors)) + 1]
    }

    add(cave, col)
  end
end

function draw_cave()
  for i = 1, #cave do
    line(i - 1, 0,   i - 1, cave[i].top, cave[i].clr)
    line(i - 1, 127, i - 1, cave[i].btm, cave[i].clr)
  end
end
__gfx__
0000000000cccc0000cccc0000cccc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ccaacc00ccaacc00cc55cc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000cccccc00cccccc00cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ccffffccccffffcccc6776cc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000f0ff0f00f0ff0f006577560000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000ffffff00ff00ff007766770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000ff00ff00ff00ff007655670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000ffff0000ffff0000766700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000555006550075500c550175501b5500c5000e50012500155001b500275000370003700037000370003700037000470004700007001b7001b7001b7001b7001b7001a7001a70019700197001870034700
001a0000177500f7500f7500f7500f75010750107501075006700067001f7001f7001b70018700057000370000700017001960019600196001960019600196001960019600196001960019600196001960019600
