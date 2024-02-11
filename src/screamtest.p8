pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- scream test
-- schoblaska

function _init()
  player = {
    x = 6, y = 8,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 17, 18, 19 },
    frame = 0,
    anim_speed = 30,
    flip = false
  }

  enemy = {
    x = 9, y = 7,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 33, 34 },
    frame = 0,
    anim_speed = 45,
    flip = false,
    act = function(self, player_moved)
      local standing_still = self.offset.x == 0 and self.offset.y == 0
      local player_idled = player.idle > 0 and player.idle % 120 == 0

      if standing_still and (player_idled or player_moved) then
        local dirs = {
          { -1, 0 }, { 1, 0 },
          { 0, 1 }, { 0, -1 }
        }

        local dir = dirs[flr(rnd(4) + 1)]
        local newx, newy = dir[1] + self.x, dir[2] + self.y

        if can_move(self, newx, newy) then
          move_entity(self, newx, newy)
        end
      end
    end
  }

  enemies = { enemy }
  update_func = wait_for_player_input
end

function _update60()
  update_func()
  update_player()

  for enemy in all(enemies) do
    update_enemy(enemy)
  end
end

function _draw()
  for x = 0, 15 do
    for y = 0, 15 do
      local sprite = mget(x, y)
      spr(sprite, x * 8, y * 8)
    end
  end

  draw_entity(player)

  for enemy in all(enemies) do
    draw_entity(enemy)
  end
end

function wait_for_player_input()
  if btnp(0) then
    if can_move(player, player.x - 1, player.y) then
      move_player(player.x - 1, player.y)
    end

    player.flip = false
  elseif btnp(1) then
    if can_move(player, player.x + 1, player.y) then
      move_player(player.x + 1, player.y)
    end

    player.flip = true
  elseif btnp(2) and can_move(player, player.x, player.y - 1) then
    move_player(player.x, player.y - 1)
  elseif btnp(3) and can_move(player, player.x, player.y + 1) then
    move_player(player.x, player.y + 1)
  end
end

function wait_for_player_movement()
  if player.offset.x == 0 and player.offset.y == 0 then
    update_func = wait_for_player_input
    player.idle = 0
  end
end

function can_move(entity, x, y)
  local msprite = mget(x, y)

  if fget(msprite, 0) then
    return false
  end

  if player.x == x and player.y == y then
    return false
  end

  for enemy in all(enemies) do
    if enemy.x == x and enemy.y == y then
      return false
    end
  end

  return true
end

function move_player(x, y)
  move_entity(player, x, y)

  for enemy in all(enemies) do
    enemy:act(true)
  end

  update_func = wait_for_player_movement
end

function move_entity(entity, x, y)
  local dx = entity.x - x
  local dy = entity.y - y

  entity.x = x
  entity.y = y
  entity.offset.x = dx * 8
  entity.offset.y = dy * 8
  entity.idle = 0

  if dx ~= 0 then
    entity.flip = dx < 0
  end
end

function draw_entity(entity)
  local sprite = entity.sprites[flr(entity.frame / entity.anim_speed) + 1]

  spr(
    sprite,
    entity.x * 8 + entity.offset.x,
    entity.y * 8 + entity.offset.y,
    1, 1,
    entity.flip
  )
end

function update_player()
  update_animations(player)
  player.idle += 1
end

function update_enemy(enemy)
  update_animations(enemy)
  enemy.idle += 1
  enemy:act(false)
end

function update_animations(entity)
  if entity.frame >= entity.anim_speed * #entity.sprites - 1 then
    entity.frame = 0
  else
    entity.frame += 1
  end

  if entity.offset.x ~= 0 then
    entity.offset.x += 2 * -sgn(entity.offset.x)
  end

  if entity.offset.y ~= 0 then
    entity.offset.y += 2 * -sgn(entity.offset.y)
  end
end

__gfx__
0000000055555555666666d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000055555555666666d600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070055555555dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005555555566d6666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770005555555566d6666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070055555555dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555556666d66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555556666d66600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000a0a00000a0a00000a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000bbbbba00bbbbba00bbbbba0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b1b1bbb0b1b1bbb0b1b1bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b1b1bbbab1b1bbbab1b1bbea000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000bbbbb1b0bbbbb1b0bbbbbeb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000001111beb01111ebb01111bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000b777bbbbe777bbbbe77ebbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000ee7eebb0e7eebbb0be77ebb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000777000007770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777770777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000722277707222777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000082827700828277000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002222700e222270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e700e70707007e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000777777c077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc77cc700c7cc70700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202010102020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101020202010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202010101010101010202010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010202010201010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020201010102010202010101020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020201010102010202020101020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020101010101010101010101020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101010101010101010101020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020201010101020202020201010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201020202020101010202020101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101020201010101010102010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0201010101020101020201020202010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020201010102020201010101010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202010101010101020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
