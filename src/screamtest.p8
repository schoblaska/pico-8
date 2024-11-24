pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- some ideas for this engine
--
-- maybe a 32x32 grid would be better
-- but still calculate a 16x16 light grid for tile visibility
-- 32x32 does better for illuminating walls of adjacent tiles
-- though, maybe that effect is the wrong way to go about it, and a 32x32 grid
-- is a can of worms. having everything on one 16x16 grid simplifies a lot
--
-- better concave corner highlighting
-- pre-compute corners that should illuminate if certain combinations of
-- adjoining floor and wall tiles are illuminated. for example, if a tile is a
-- wall, has a wall below it, a wall to the right, and an open space to the
-- bottom right, it should be considered visible to the player if all three of
-- those squares are
--
-- it'd be cool to get actual dynamic lighting working
-- still grid-based, but do the peek / poke screen memory trick to actually
-- darken each square dynamically. this way enemies get the full range of
-- shadows as well
--
-- other light sources
-- if a lamp or something is on the wall, the player should be able to see any
-- tiles it illuminates as long as the player has line of sight to those tiles.
-- i.e., even if they are too far away for a player to normally see, an
-- illuminated tile that the player has LOS to will always be visible
--
-- better calculations
-- have a layer of global illumination, without considering any walls (illum)
-- have another layer of binary values: player has line of sight, true or false (los)
-- keep another map for the fog reveal value for each square (fog_reveal)
--   choose low value like 2 - squares in fog_reveal are in the range 0-2
--   map tiles are darkened to the brighter of (illum, fog_reveal)
-- generate current active illumination for each square (active_illum)
--   first combine illum and los - tiles the player can currently see
--   then update each square to take the max_active_illum into account, up to
--   3. that is, if the fog of war illumination is greater, use that instead of
--   the active illumination
-- enemies sprites are only rendered if they are in an active_illum square
--   that's => 2 (or whatever number was used as the max brightness level for
--   the fog of war)
--   or maybe render them as long as they're on an active_illum square, even if
--   it's below the fog_clear brightness
--   when rendering a moving sprite, take "to" and "from" squares into account.
--   draw the sprite if player has LOS to either of these squares. this
--   way, sprites won't instantly appear / disappear when they move in or out
--   of LOS. may be necessary then to re-draw non-LOS map tiles to cover up sprites
-- now use active_illum to darken all squares appropriately

function _init()
  floorfill = {
    176, 177, 178, 179, 163,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149
  }

  lightmap = {}
  maxlight = {}

  for x = 0, 15 do
    maxlight[x + 1] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end

  alt_pals = {}

  build_alt_pal(1, 4)
  build_alt_pal(2, 3)
  build_alt_pal(3, 2)

  player = {
    x = 6, y = 8,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 17, 18, 19 },
    frame = 0,
    anim_speed = 15,
    flip = false
  }

  wizard = {
    x = 9, y = 7,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 33, 34 },
    frame = 0,
    anim_speed = 25,
    flip = false,
    act = function(self, player_moved)
      if should_act(self, player_moved) then
        local dirs = {
          { -1, 0 }, { 1, 0 },
          { 0, 1 }, { 0, -1 }
        }

        local dir = dirs[flr(rnd(4) + 1)]
        local newx, newy = dir[1] + self.x, dir[2] + self.y

        if open_space(newx, newy) then
          move_entity(self, newx, newy)
        end
      end
    end
  }

  robot = {
    x = 12, y = 6,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 4, 5 },
    normal_sprites = { 4, 5 },
    red_sprites = { 6, 7 },
    red = false,
    frame = 0,
    anim_speed = 30,
    flip = false,
    act = function(self, player_moved)
      if should_act(self, player_moved) then
        if self.red then
          local dirs = {
            { -1, 0, dist(self.x - 1, self.y, player.x, player.y) },
            { 1, 0, dist(self.x + 1, self.y, player.x, player.y) },
            { 0, 1, dist(self.x, self.y + 1, player.x, player.y) },
            { 0, -1, dist(self.x, self.y - 1, player.x, player.y) }
          }

          -- sort based on distance to player
          for i = 1, #dirs do
            for j = i + 1, #dirs do
              if dirs[j][3] < dirs[i][3] then
                dirs[i], dirs[j] = dirs[j], dirs[i]
              end
            end
          end

          for dir in all(dirs) do
            local newx, newy = dir[1] + self.x, dir[2] + self.y

            if open_space(newx, newy) then
              move_entity(self, newx, newy)
              self.red = false
              self.sprites = self.normal_sprites
              return
            end
          end
        else
          self.red = true
          self.sprites = self.red_sprites
        end
      end
    end
  }

  enemies = { wizard, robot }
  update_func = wait_for_player_input

  for x = 0, 15 do
    for y = 0, 15 do
      if mget(x, y) == 178 then
        mset(x, y, sample(floorfill))
      end
    end
  end

  update_lightmap()
end

function _update()
  update_func()
  update_player()

  for enemy in all(enemies) do
    update_enemy(enemy)
  end
end

function _draw()
  local lastpal = 0

  for x = 0, 15 do
    for y = 0, 15 do
      local sprite = mget(x, y)
      local bri = max(maxlight[x + 1][y + 1], lightmap[x + 1][y + 1])

      if bri > 0 and bri < 4 then
        if bri ~= lastpal then
          lastpal = bri
          swap_pal(bri)
        end
      else
        pal()
      end

      palt(0, false)
      spr(sprite, x * 8, y * 8)
    end
  end

  pal()

  draw_entity(player)

  for enemy in all(enemies) do
    draw_entity(enemy)
  end

  darken_squares()
  print_cpu()
end

function print_cpu()
  local color = 1
  local cpu = flr(stat(1) * 100)

  if cpu > 100 then
    color = 4
  elseif cpu > 50 then
    color = 2
  end

  print("cpu: " .. cpu .. "%", 74, 2, color)
end

function wait_for_player_input()
  if btnp(0) then
    if open_space(player.x - 1, player.y) then
      move_player(player.x - 1, player.y)
    end

    player.flip = false
  elseif btnp(1) then
    if open_space(player.x + 1, player.y) then
      move_player(player.x + 1, player.y)
    end

    player.flip = true
  elseif btnp(2) and open_space(player.x, player.y - 1) then
    move_player(player.x, player.y - 1)
  elseif btnp(3) and open_space(player.x, player.y + 1) then
    move_player(player.x, player.y + 1)
  end
end

function wait_for_player_movement()
  if player.offset.x == 0 and player.offset.y == 0 then
    update_func = wait_for_player_input
    player.idle = 0
  end
end

function open_space(x, y)
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

  update_lightmap()
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
  local bri = lightmap[entity.x + 1][entity.y + 1]

  if bri > 0 then
    if bri < 4 then
      swap_pal(bri)
    end

    spr(
      sprite,
      entity.x * 8 + entity.offset.x,
      entity.y * 8 + entity.offset.y,
      1, 1,
      entity.flip
    )
  end

  pal()
end

function update_player()
  update_animations(player)
  player.idle += 1
end

function darken_squares()
  local lastpal = 0

  palt(0, false)

  for x = 0, 15 do
    for y = 0, 15 do
      if lightmap[x + 1][y + 1] == 0 then
        local tmaxlight = maxlight[x + 1][y + 1]

        if tmaxlight > 0 then
          if tmaxlight ~= lastpal then
            swap_pal(tmaxlight)
            lastpal = tmaxlight
          end

          spr(mget(x, y), x * 8, y * 8)
        else
          spr(3, x * 8, y * 8)
        end
      end
    end
  end

  pal()
end

function swap_pal(n)
  pal()
  palt(0, false)

  for swap_pair in all(alt_pals[n]) do
    pal(swap_pair[1], swap_pair[2])
  end
end

function build_alt_pal(n, offset)
  alt_pals[n] = {}

  for y = 0, 16 do
    local orig, alt = sget(64, y), sget(64 + offset, y)

    if orig ~= alt then
      add(alt_pals[n], { orig, alt })
    end
  end
end

function update_lightmap()
  local losx1, losx2 = max(0, player.x - 7), min(15, player.x + 7)
  local losy1, losy2 = max(0, player.y - 7), min(15, player.y + 7)

  for x = 0, 15 do
    lightmap[x + 1] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
  end

  for x = losx1, losx2 do
    for y = losy1, losy2 do
      local has_los = line_of_sight(player.x, player.y, x, y, 1, 1)

      if has_los then
        local pdist = dist(player.x, player.y, x + 0.5, y + 0.5)
        local bri = max(0, ceil(6 - pdist))

        lightmap[x + 1][y + 1] = bri
        maxlight[x + 1][y + 1] = min(2, max(bri, maxlight[x + 1][y + 1]))
      else
        lightmap[x + 1][y + 1] = 0
      end
    end
  end
end

function line_of_sight(x1, y1, x2, y2, quadrantX, quadrantY)
  local dx = x2 - x1 + quadrantX * 0.5
  local dy = y2 - y1 + quadrantY * 0.5
  local steps = max(abs(dx), abs(dy))
  local sx = dx / steps
  local sy = dy / steps
  local x, y = x1, y1

  for i = 1, steps do
    x += sx
    y += sy

    local tile = mget(flr(x), flr(y))

    if fget(tile, 0) then
      if flr(x) == x2 and flr(y) == y2 then
        return true
      else
        return false
      end
    end
  end

  return true
end

function update_enemy(enemy)
  update_animations(enemy)
  enemy.idle += 1
  enemy:act(false)
end

function should_act(entity, player_moved)
  local standing_still = entity.offset.x == 0 and entity.offset.y == 0
  local player_idled = player.idle > 0 and player.idle % 40 == 0

  return standing_still and (player_idled or player_moved)
end

function update_animations(entity)
  if entity.frame >= entity.anim_speed * #entity.sprites - 1 then
    entity.frame = 0
  else
    entity.frame += 1
  end

  if entity.offset.x > 0 then
    entity.offset.x = max(0, entity.offset.x - 3)
  elseif entity.offset.x < 0 then
    entity.offset.x = min(0, entity.offset.x + 3)
  end

  if entity.offset.y > 0 then
    entity.offset.y = max(0, entity.offset.y - 3)
  elseif entity.offset.y < 0 then
    entity.offset.y = min(0, entity.offset.y + 3)
  end
end

function sample(array)
  return array[flr(rnd(#array)) + 1]
end

function dist(ax, ay, bx, by)
  local dx, dy = ax - bx, ay - by
  return sqrt(dx * dx + dy * dy)
end

__gfx__
0000000011111111dddddddd0000000006666660066666600eeeeee00eeeeee00000000000000000000000000000000000000000000000000000000000000000
0000000011111111dddddddd000000006766666661616666eeeeeeeee8e8eeee1111100000000000000000000000000000000000000000000000000000000000
0070070011111111dddddddd00000000616166c661616c66e8e8eefee8e8efee2211100000000000000000000000000000000000000000000000000000000000
0007700011111111dddddddd0000000061616c606666c1c0e8e8efe0eeeef1f03331100000000000000000000000000000000000000000000000000000000000
0007700011111111dddddddd00000000666661c000005050eeeee120000020204221100000000000000000000000000000000000000000000000000000000000
0070070011111111dddddddd000000000000055ee55000000000022ee22000005511100000000000000000000000000000000000000000000000000000000000
0000000011111111dddddddd0000000005550ee00ee0555002220ee00ee0222066d5100000000000000000000000000000000000000000000000000000000000
0000000011111111dddddddd00000000eeee00000000eeeeeeee00000000eeee776d100000000000000000000000000000000000000000000000000000000000
0000000000a0a00000a0a00000a0a0000eeeeee00000000008888880000000008822100000000000000000000000000000000000000000000000000000000000
000000000bbbbba00bbbbba00bbbbba0ee1e1eeb000000008828288e000000009422100000000000000000000000000000000000000000000000000000000000
00000000b1b1bbb0b1b1bbb0b1b1bbb0be1e1ebe0eeeeee0e82828e200000000a942100000000000000000000000000000000000000000000000000000000000
00000000b1b1bbbab1b1bbbab1b1bbea0eeeeee0ee1e1eee0888888008888880bb33100000000000000000000000000000000000000000000000000000000000
00000000bbbbb1b0bbbbb1b0bbbbbeb070000000ee1e1ebe7000000088282888ccd5100000000000000000000000000000000000000000000000000000000000
0000000001111beb01111ebb01111bbb07777770beeeeeeb07777770882828e8d551100000000000000000000000000000000000000000000000000000000000
00000000b777bbbbe777bbbbe77ebbbb70000000b000000070000000e888888eee82100000000000000000000000000000000000000000000000000000000000
00000000ee7eebb0e7eebbb0be77ebb0077777700777777007777770e7777770f942100000000000000000000000000000000000000000000000000000000000
00000000000777000007770700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777770777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000722277707222777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000082827700828277000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000002222700e222270000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e700e70707007e7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000777777c077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cc77cc700c7cc70700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000009a9944000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000494444000a9aa00009949994999499999949940000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000a9444200a2222900a2222222222222222222224000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000009aaa9400a2112900a2100000000000000000024000000000000000000000000000000000000000000000000
000000000101011000000000000000000000000004aa942009200240092101010110110111011024000000000000000000000000000000000000000000000000
0000001111111111110000000000000000000000014942100a2102900a2222222222222222222224000000000000000000000000000000000000000000000000
0000011224442444211000000000000000000000000000000a20029000aa9aaa9aaa9aaaaaa9aa40000000000000000000000000000000000000000000000000
0000012400000000421000000000000000000000000000000a210290000000000000000000000000000000000000000000000000000000000000000000000000
00001240000000000921000001110110000010111011000009200240042442100000000000000000000000000000000000000000000000000000000000000000
00011290000000000a2110000000000001000000000001100a210290044144400000000000000000000000000000000000000000000000000000000000000000
00001290000000000a2100000000000000001000000100000a2102900499a9400000000000000000000000000000000000000000000000000000000000000000
00011290000000000a2110000000000000000111111000000a200290029444200000000000000000000000000000000000000000000000000000000000000000
00001240000000000921000000000000000000000000000009210240099441400000000000000000000000000000000000000000000000000000000000000000
00011290000000000a2110000000000000000000000000000a21029009aaa9400000000000000000000000000000000000000000000000000000000000000000
00011290000000000a2110000000000000000000000000000a20029004aa94200000000000000000000000000000000000000000000000000000000000000000
00001290000000000a2100000000000000000000000000000a210290014942100000000000000000000000000000000000000000000000000000000000000000
0000012900000000a2100000d5105d1000000000000000000a210290000000000000000000000000000000000000000000000000000000000000000000000000
00000112aaa9aaa9211000005110111000aa9aaaaaa9aa000a210290000000000000000000000000000000000000000000000000000000000000000000000000
000000112222222211000000100010000a222222222222900a200290000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111110000000005100d100a2111111111129009210240000000000000000000000000000000000000000000000000000000000000000000000000
000000000110101000000000d110511009210010010012400a210290000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000111011100a211000000112900a200290000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a2100000000129004222240000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000a2110000001129000444400000000000000000000000000000000000000000000000000000000000000000000000000
0100001105000100d5105d10000000000a2110000001129004244210000000000000000000000000000000000000000000000000000000000000000000000000
10000501510d501051101110110011000a2100000000129004414440000000000000000000000000000000000000000000000000000000000000000000000000
0000d1105051110011101110111011100a211000000112900494a940000000000000000000000000000000000000000000000000000000000000000000000000
0000d110005110000000000000000000092100000000124002949420000000000000000000000000000000000000000000000000000000000000000000000000
1015110500010101d1101d101d10d1100a2100000000129004414140000000000000000000000000000000000000000000000000000000000000000000000000
100110d10d01105151105110511051100a21111111111290049a9440000000000000000000000000000000000000000000000000000000000000000000000000
10000d110d1005111110111011101110004424444442440002994420000000000000000000000000000000000000000000000000000000000000000000000000
10000511011101100000000000000000010000000000001009444140000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
00000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000a2a2a2a2a2a2a2a2a2a2000000000000a2a2a2a2a2a2a2a2a2a2000000000000a2a2a2a2a2a2a2a2a2a2000000000000a2a2a2a2a2a2a2a2a2a2000000000000
0101010000010101010100000000000001010100000001010000000000000000010101000101010000000000000000000000000001010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
8081818181818182919191919191919100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b2b2b2b2b2b4829180818181818291000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2a4a1a5b2b2b2b481b5b2b2b2b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b481b5b2b2b2b2b2b2b2a4a5b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b2b2b2b2b686b286b2b2b4b5b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2a4a5b2b28596b296b6b2b2b2b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b6b5b2b2b2a6b2a685b2b2b2a4a200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b285b2b2b2b2b2b2b2b2b2b2b2929100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b2b2b2b2b2b2b2b2b2b2b6b2b48200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2a4a5b2b2b2b2b2a4a1a585b2b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b4b59786b2b2b2b481b5b2b2b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b2b2b29697b2b2b2b2b2b297b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90b2b2b2b2a6b2b2a4a5b2878889b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
a0a1a1a5b2b2b297b4b5b2b2b2b2b29200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
919191a0a5b2b2b2b2b2b2a4a1a1a1a200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
91919191a0a1a1a1a1a1a1a29191919100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000