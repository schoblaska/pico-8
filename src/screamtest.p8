pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

function _init()
  dt_init_blending_tables(6)

  floorfill = {
    176, 177, 178, 179, 163,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149,
    147, 148, 149
  }

  fl_blends = {
    dt_fl_blend(1),
    dt_fl_blend(2),
    dt_fl_blend(3),
    dt_fl_blend(4),
    dt_fl_blend(5),
    dt_fl_blend(6)
  }

  lightmap = {}

  for i = 1, 16 do
    lightmap[i] = {}
    for j = 1, 16 do
      lightmap[i][j] = 0
    end
  end

  show_lightmap = false

  player = {
    x = 6, y = 8,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 17, 18, 19 },
    frame = 0,
    anim_speed = 30,
    flip = false
  }

  wizard = {
    x = 9, y = 7,
    offset = { x = 0, y = 0 },
    idle = 0,
    sprites = { 33, 34 },
    frame = 0,
    anim_speed = 45,
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
    anim_speed = 60,
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

function _update60()
  update_func()
  update_player()

  -- for debugging; always listen for this input
  if btnp(5) then
    show_lightmap = not show_lightmap
  end

  for enemy in all(enemies) do
    update_enemy(enemy)
  end
end

function _draw()
  palt(0, false)

  for x = 0, 15 do
    for y = 0, 15 do
      local sprite = mget(x, y)
      spr(sprite, x * 8, y * 8)
    end
  end

  palt()

  draw_entity(player)

  for enemy in all(enemies) do
    draw_entity(enemy)
  end

  if show_lightmap then
    for x = 0, 15 do
      for y = 0, 15 do
        local l = lightmap[x + 1][y + 1]
        print(l, x * 8 + 2, y * 8 + 2, 12)
      end
    end
  end

  -- apply_lighting()
  darken_squares()
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

function darken_squares()
  palt(0, false)

  for x = 0, 31 do
    for y = 0, 31 do
      if lightmap[x + 1][y + 1] < 2 then
        spr(3, x * 4, y * 4, 0.5, 0.5)
      end
    end
  end

  palt()
end

function update_lightmap()
  for x = 0, 31 do
    lightmap[x + 1] = {}

    for y = 0, 31 do
      local gx = flr(x / 2)
      local gy = flr(y / 2)
      if line_of_sight(player.x, player.y, gx, gy, x % 2, y % 2) then
        lightmap[x + 1][y + 1] = max(0, flr(6 - dist(player.x, player.y, gx + 0.5, gy + 0.5)))
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
  local player_idled = player.idle > 0 and player.idle % 120 == 0

  return standing_still and (player_idled or player_moved)
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

function sample(array)
  return array[flr(rnd(#array)) + 1]
end

function dist(ax, ay, bx, by)
  local dx, dy = ax - bx, ay - by
  return sqrt(dx * dx + dy * dy)
end

function apply_lighting()
  -- loop through each address in screen memory
  -- look up the light level of the corresponding grid tile (in lightmap)
  -- then use the appropriate blending tile to replace the colors
  -- eg:
  --
  -- for screenaddr=start,end do
  --   poke(screenaddr,
  --     peek(bor(lutaddr,peek(screenaddr)))
  --   )
  -- end
  --
  -- from the PICO-8 manual entry on screen memory:
  --
  -- Screen data
  -- This 8,192-byte (8 KiB) region contains the graphics buffer. This is what is
  -- modified by the built-in drawing functions, and is what is copied to the
  -- actual display at the end of the game loop or by a call to flip().
  --
  -- 0x6000..0x7fff / 24576..32767
  --
  -- All 128 rows of the screen, top to bottom. Each row contains 128 pixels in
  -- 64 bytes. Each byte contains two adjacent pixels, with the low 4 bits being
  -- the left/even pixel and the high 4 bits being the right/odd pixel.
  --
  -- This is essentially the same format as the sprite sheet at 0x0000..0x1fff
  -- (see above). As a result, you can use memcpy() as an alternative way to
  -- display the entire sprite sheet onto the screen without using spr().

  -- use fl_blends

  for x = 0, 15 do
    for y = 0, 15 do
      local screenaddr = 0x6000 + shl(y, 6) + shl(x, 1)
      local light = lightmap[x + 1][y + 1]
      local blend = fl_blends[light]

      for addr = screenaddr, screenaddr + 63 do
        poke(
          addr,
          peek(bor(blend, peek(addr)))
        )
      end
    end
  end
end

-- dt_ functions are from Dank Tomb tech demo
-- https://www.lexaloffle.com/bbs/?tid=28785

function dt_init_blending_tables(nlevels)
  local blend_table_start_x = 64

  for lv = 1, nlevels do
    local addr = 0x4300 + lv * 0x100
    local sx = lv - 1 + blend_table_start_x
    for c1 = 0, 15 do
      local nc = sget(sx, c1)
      local topl = shl(nc, 4)
      for c2 = 0, 15 do
        poke(
          addr,
          topl + sget(sx, c2)
        )
        addr += 1
      end
    end
  end
end

function dt_fl_blend(l)
  local lutaddr = 0x4300 + l << 8

  printh(l .. ": " .. lutaddr)

  return function(x1, x2, y)
    local laddr = lutaddr
    local yaddr = 0x6000 + shl(y, 6)
    local saddr, eaddr = yaddr + band(shr(x1 + 1, 1), 0xffff), yaddr + band(shr(x2 - 1, 1), 0xffff)

    for addr = saddr, eaddr do
      poke(
        addr,
        peek(bor(laddr, peek(addr)))
      )
    end
  end
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
0000000000a0a00000a0a00000a0a0000eeeeee00000000008888880000000008888800000000000000000000000000000000000000000000000000000000000
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
