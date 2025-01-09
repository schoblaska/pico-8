pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- deepdark
-- by schoblaska

function _init()
  reset_pal()

  -- stop color palette from resetting
  poke(0x5f2e, 1)

  -- sprite key
  sk = {
    player = {
      idle = 144,
      walk = { 144, 145, 146, 147 }
    },
    floor = 19,
    floor_alts = { 23, 48, 49, 50, 51, 52, 53, 54 },
    lightgrad = { 123, 40 },
    torch = { 228, 229, 230 }
  }

  cfg = {
    max_brightness = 3
  }

  player = {
    facing = "r",
    x = 0,
    y = 0,
    frame = 0,
    anim_speed = 8, -- lower = faster animation
    moving = false,
    luminosity = 5
  }

  torches = {}

  camera = { x = 0, y = 0 }
  los_cache = {}
  lightmap = {}
  alt_pals = {}

  -- build an alt palette for each brightness level
  for i = 0, cfg.max_brightness do
    local bri = cfg.max_brightness - i
    alt_pals[bri] = {}

    for color = 0, 3 do
      local orig = sget(sk.lightgrad[1], sk.lightgrad[2] + color)
      local alt = sget(sk.lightgrad[1] + i, sk.lightgrad[2] + color)

      if orig ~= alt then
        add(alt_pals[bri], { orig, alt })
      end
    end
  end

  fogmap = {}

  for x = 1, 128 do
    fogmap[x] = {}
    for y = 1, 32 do
      fogmap[x][y] = false
    end
  end

  -- initialize tiles (put a floor tile under the player; sprinkle in alternate
  -- floor tiles)
  for x = 0, 255 do
    for y = 0, 255 do
      sprite = mget(x, y)

      if sprite == sk.player.idle then
        player.x = x * 8
        player.y = y * 8
        camera.x = player.x - 64
        camera.y = player.y - 64
        mset(x, y, sk.floor)
      elseif sprite == sk.torch[1] then
        add(
          torches,
          {
            x = x * 8,
            y = y * 8,
            frame = 0,
            anim_speed = 10,
            luminosity = 3
          }
        )

        mset(x, y, sk.floor)
      elseif sprite == sk.floor and rnd(4) < 1 then
        mset(x, y, rnd(sk.floor_alts))
      end
    end
  end

  refresh_lightmap()
end

function _draw()
  cls()

  draw_map()

  -- get current sprite based on animation frame
  local player_sprite = sk.player.idle
  if player.moving then
    local frame_idx = flr(player.frame / player.anim_speed) % #sk.player.walk + 1
    player_sprite = sk.player.walk[frame_idx]
  end
  spr(player_sprite, player.x - camera.x, player.y - camera.y, 1, 1, player.facing == "l" and true or false)

  for torch in all(torches) do
    local torch_sprite = sk.torch[flr(torch.frame / torch.anim_speed) % #sk.torch + 1]
    spr(torch_sprite, torch.x - camera.x, torch.y - camera.y, 1, 1, torch.facing == "l" and true or false)
  end

  -- debugging
  -- draw_lightmap()
end

function _update60()
  move = { x = 0, y = 0 }

  if btn(0) then move.x = -1 end
  if btn(1) then move.x = 1 end
  if btn(2) then move.y = -1 end
  if btn(3) then move.y = 1 end

  if move.x == 0 and move.y == 0 then
    player.moving = false
    player.frame = 0
  end

  player_move(move.x, move.y)
  for torch in all(torches) do
    torch.frame = (torch.frame + 1) % (torch.anim_speed * #sk.torch)
  end
end

function reset_pal()
  pal()
  pal(2, 129, 1)
  pal(14, 128, 1)
end

function swap_pal(bri)
  reset_pal()

  for swap_pair in all(alt_pals[bri]) do
    pal(swap_pair[1], swap_pair[2])
  end
end

function draw_map()
  -- convert camera position to map tile coordinates
  local start_x = flr(camera.x / 8)
  local start_y = flr(camera.y / 8)

  -- draw 17x17 tiles to cover 128x128 screen plus 1 tile overflow
  for x = start_x, start_x + 16 do
    for y = start_y, start_y + 16 do
      -- get sprite at map position
      local sprite = mget(x, y)
      -- calculate screen position by subtracting camera offset
      local screen_x = x * 8 - camera.x
      local screen_y = y * 8 - camera.y

      local brightness = lightmap[x + 1] and lightmap[x + 1][y + 1] or 0 -- temp hack

      if brightness > 0 then
        swap_pal(brightness)
        spr(sprite, screen_x, screen_y)
        fogmap[x + 1][y + 1] = true
      elseif fogmap[x + 1] and fogmap[x + 1][y + 1] then
        swap_pal(brightness)
        spr(sprite, screen_x, screen_y)
      end
    end
  end
end

function player_move(x, y)
  -- update player facing direction
  if x < 0 then
    player.facing = "l"
  elseif x > 0 then
    player.facing = "r"
  end

  -- calculate target position
  local new_x = player.x + x
  local new_y = player.y + y

  -- try horizontal and vertical movement separately
  local can_move_x = true
  local can_move_y = true

  if x ~= 0 then
    -- coordinates describing the column of pixels the player is trying to move
    -- horizontally into
    local movecolx = x > 0 and flr((new_x + 7) / 8) or flr(new_x / 8)
    local movecoly1 = flr(player.y / 8)
    local movecoly2 = flr((player.y + 7) / 8)

    local top_blocked = is_wall(movecolx, movecoly1)
    local bottom_blocked = is_wall(movecolx, movecoly2)

    if top_blocked or bottom_blocked then
      can_move_x = false
    end

    -- nudge player towards opening if they're misaligned
    if y == 0 and not can_move_x then
      if not top_blocked and (player.y % 8) < 5 then
        return player_move(x, -1)
      elseif not bottom_blocked and (player.y % 8) > 3 then
        return player_move(x, 1)
      end
    end
  end

  if y ~= 0 then
    local moverowy = y > 0 and flr((new_y + 7) / 8) or flr(new_y / 8)
    local moverowx1 = flr(player.x / 8)
    local moverowx2 = flr((player.x + 7) / 8)

    local left_blocked = is_wall(moverowx1, moverowy)
    local right_blocked = is_wall(moverowx2, moverowy)

    if left_blocked or right_blocked then
      can_move_y = false
    end

    -- nudge player towards opening if they're misaligned
    if x == 0 and not can_move_y then
      if not left_blocked and (player.x % 8) < 5 then
        return player_move(-1, y)
      elseif not right_blocked and (player.x % 8) > 3 then
        return player_move(1, y)
      end
    end
  end

  -- apply allowed movements and update animation
  if can_move_x or can_move_y then
    if can_move_x then player.x = new_x end
    if can_move_y then player.y = new_y end
    player.moving = true
    player.frame += 1

    -- keep player away from screen edges by adjusting camera
    local min_edge_dist = 50
    local max_x = 127 - min_edge_dist
    local max_y = 127 - min_edge_dist

    -- calculate camera position needed to keep player in bounds
    local cam_x = 0
    local cam_y = 0

    if player.x - camera.x < min_edge_dist then
      camera.x = player.x - min_edge_dist
    elseif player.x - camera.x > max_x then
      camera.x = player.x - max_x
    end

    if player.y - camera.y < min_edge_dist then
      camera.y = player.y - min_edge_dist
    elseif player.y - camera.y > max_y then
      camera.y = player.y - max_y
    end
  else
    player.moving = false
    player.frame = 0
  end

  refresh_lightmap()
end

function is_wall(x, y)
  return fget(mget(x, y), 0)
end

function dist(ax, ay, bx, by)
  local dx, dy = ax - bx, ay - by
  return sqrt(dx * dx + dy * dy)
end

function iclamp(val, lower, upper)
  return flr(max(min(val, upper), lower))
end

-- lighting code below
function line_of_sight(x1, y1, x2, y2)
  local cache_key = x1 .. "," .. y1 .. "," .. x2 .. "," .. y2

  if los_cache[cache_key] then
    return los_cache[cache_key] == 1 and true or false
  end

  local x3 = x2 + 0.5 * sgn(x1 - x2)
  local y3 = y2 + 0.5 * sgn(y1 - y2)
  local dx, dy = x3 - x1, y3 - y1
  local steps = max(abs(dx), abs(dy))
  local sx, sy = dx / steps, dy / steps
  local x, y = x1, y1

  for i = 1, steps do
    x += sx
    y += sy

    if is_wall(x, y) then
      if flr(x) == x3 and flr(y) == y3 then
        los_cache[cache_key] = 1
        return true
      else
        los_cache[cache_key] = 0
        return false
      end
    end
  end

  los_cache[cache_key] = 1
  return true
end

function add_light_source(luminosity, lumx, lumy)
  -- coordinates describing the section of the map that might be illuminated by
  -- this light source
  local losx1, losx2 = max(0, lumx - luminosity - 1), min(127, lumx + luminosity + 1)
  local losy1, losy2 = max(0, lumy - luminosity - 1), min(31, lumy + luminosity + 1)

  for x = losx1, losx2 do
    for y = losy1, losy2 do
      local has_los = line_of_sight(lumx, lumy, x, y)

      if has_los then
        local lumdist = dist(lumx, lumy, x, y)
        local bri = max(0, min(ceil(luminosity - lumdist), cfg.max_brightness))

        lightmap[x + 1][y + 1] = max(bri, lightmap[x + 1][y + 1])
      else
        lightmap[x + 1][y + 1] = max(0, lightmap[x + 1][y + 1])
      end
    end
  end
end

function refresh_lightmap()
  lightmap = {}

  for x = 1, 128 do
    lightmap[x] = {}
    for y = 1, 32 do
      lightmap[x][y] = 0
    end
  end

  -- determine which map tile the player is "most" on
  local player_map_x = flr((player.x + 4) / 8)
  local player_map_y = flr((player.y + 4) / 8)

  add_light_source(player.luminosity, player_map_x, player_map_y)
end

function draw_lightmap()
  refresh_lightmap()

  -- convert camera position to map tile coordinates
  local start_x = iclamp(flr(camera.x / 8), 0, 127)
  local end_x = iclamp(start_x + 16, 0, 127)
  local start_y = iclamp(flr(camera.y / 8), 0, 31)
  local end_y = iclamp(start_y + 16, 0, 31)

  -- draw 17x17 tiles to cover 128x128 screen plus 1 tile overflow
  for x = start_x, end_x do
    for y = start_y, end_y do
      -- calculate screen position by subtracting camera offset
      local screen_x = x * 8 - camera.x
      local screen_y = y * 8 - camera.y

      -- get brightness value from lightmap
      local brightness = lightmap[x + 1][y + 1]

      -- draw brightness number centered in tile
      if brightness > 0 then
        print(brightness, screen_x + 3, screen_y + 3, 7)
      end
    end
  end
end

__gfx__
000000000000000001dddddddddddddddddddd100000000001dddddd010dd0101ddd1d10000000000011dddddddddddddddd11001dddddd11dddddd101ddddd1
00000000011101101dddddddddddddddddddddd1011110011ddddddd1d1dd1d1ddddddd10110111101dddddddddddddddddddd10dddddddddddddddd0ddddddd
0000000001010100dddddddddddddddddddddddd01111100dddd11dd1d1dd1d1ddddddd1011011111dddddddddddddddddddddd1dddddddddddddddd0ddddddd
0000000001110100dddddddddd1ddd1ddddddddd01111100ddd111dd1d1dd1d1dddddddd011011001ddddddddd1ddd1dddddddd11dddddd11dddddd101ddddd1
0000000000000000dddddddd11011101dddddddd011110001dddddd111011101dddddddd00000000ddddddddd1011101dddddddd110111011111111101101101
0000000001110000dddddddd11011101dddddddd0111000001d11d11110111011ddddddd01110000dddddddd11011101dddddddd010111000111111000101100
0000000001010000dddddddd00000000dddddddd011100001dd11dd10000000011ddddd101110000ddddddd1100000001ddddddd100000011000000101000001
0000000001110000dddddddd01110111dddddddd00110000dddddddd011101111ddddddd01110000ddddddd1011101111ddddddd011101100111111000111010
0000000000000000dddddddd00000000dddddddd01110000dddddddd000000001dddddd100000000ddddddd1dddddddd1ddddddd100000001d1dd1d101ddddd1
0110000001110000dddddddd01111111dddddddd01110000dddddddd01111111ddd11ddd01110000dddddddddddddddddddddddd11110100dddd1ddd0ddddddd
0110000001110000dddddddd011111111dddddd101110000ddd11ddd01011101ddd11ddd010100001dddddddddddddddddddddd101110000dd1101dd0ddddddd
0110000001110000dddddddd01111111dddddd1101110000dddddddd01111111ddd11ddd01110000d11ddddddd1ddddddddddd1d10000000d100001d01ddddd1
0000000001110000dddddddd01111111dddddd1d01110000ddd11ddd01111111ddd11ddd0000000011dddd1d1101111d1ddddddd110000001000000101111111
0111000001110000dddddddd01111111dddddddd01110000dddddddd01111111ddd11ddd011100001ddddddd1101110111dddddd010000000000000000111110
0111000001110000dddddddd01111111dddddddd01110000dd1dd1dd01011101ddd11ddd01010000ddddddd100000000d1dddddd100000000000000001000001
0111000001110000dddddddd01111111dddddddd01110000dd1dd1dd011111111dd11dd101110000dddddddd01110111dddddddd000000000000000000111110
0000000000000000dddddddddddddddddddddddd000000001dd11dd1010dd01001dddddd00000000ddddddddddddddddddddddddddddddd11dddddd11ddddddd
0111000001110000dddddddddddddddddddddddd000100001ddddddd1d1dd1d11ddddddd01110000dddddddddddddddddddddddddddddd1dddddddddd1dddddd
0100000001000000ddddddddddd11ddddddddddd00110000dddddddd1d1dd1d1dddd11dd01110000ddddddddd111111dddddddddddddddd1dd1111dd1ddddddd
0111000001010000dd1ddd1ddd1001dddd1ddd1d01110000dd1ddd1d1d1dd1d1ddd000dd01100000dd1dddd1110000111dddd1dddd1ddd1dd100001dd11ddd1d
01000000010100001101100111010011110111000111000011011001111111111101000101110000110111011010100110111011110111001000000101011101
01110000010100001101010111011011110111000111000011010101110000111101110101110000010001001010100100100010110111010000000010011101
01000000010000000000000000011000000000000011000000000000100000010000000000110000000000000010100000000000000000000000000000000000
01110000011100000111010101011011011100000111000001110111100000010111011101010000010100000011110100001010011101010000000010110111
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000dddddddddddddddddddddddddddddddddddddddd
0111100101011111111111110110111100010101010101010101010000000000000111110111111101111000dddddddddddddddddddddddddddddddddddddddd
0111110100111111111111100110111100101111011111110111101000110100000011110111111101100000d111111dd111111dd111111ddddddddddddddddd
0111111101111111111111010110111101011111011111110111110100111000000001010101010101000000110000111100001111000011dd1ddd1ddd1ddd1d
01111111011111111111111100000000001111110111111101111110001111000000000000000000000000001010100110a0a001100000011101110111011100
01111111011111111111111101111111011111110111111101111111001111000000000000000000000000001010100100a0a000000000001101110111011100
01111111011111111111111101111111001111100111111101111110000000000000000000000000000000000010100000a0a000000000000000000000000000
00111111011111111111111101111111011111010111111101111111000000000000000000000000000000000011110100aaaa01000000001011011101110000
01111111011111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000001011011101100000
011111110111111111111111011011110111111100010100011111110000000000000000000000000000000000000000000000a00a0000000000000000000000
011111110111111111111111011011110011111100101010011111100000011000000000000000000000000000000000000aa0a00a0aa0001101110110000000
011111110111111111111111011010110111111101011101011111110000011000000000000000000000000000000000aa0aa0a00a0aa0aa1101110100000000
011111110111111111111111000000000011111100111110011111100000000000000101010101010100000000000000aa0aa010010aa0aa0000000000000000
011111110111111111111111011110110111111101011101011111110010000000001111011111110110000000000000aa011010010110aa1011010000000000
01111111011111011111111100111111001111110010101001111110000000000001111101111111011110000000000011011010010110111011000000000000
01111110011100111111111101011111011111110001010001111111000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000001111111011111110111111101111111000000000000000011100000000d1120
011111110001110111111101011011110111111101111111011111110001000000000000000000000000000000000000101101100110110100000000000122e0
0100000100111111111111100110011100111111011111110111111000000000010111011101110101010101110111000000000000000000100000000002ee00
011111110111111111111111000000000111111101111111011111110000011001011101110111011100110111011000000001100110000000000000000ee000
01000001011111111111111101111111001111110111111101111110011101100000000000000000000000000000000000110110011011000000000000000000
01111111011111111111111101000001010111110111111101111101011100000001000100010001000100010001000010110110011011010000000000000000
01000001001111111111111101111111001011110111111101111010011100000000000000000000000000000000000010110110011011010000000000000000
01111111011111111111111101000001000101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000aa0000000000000000000000000000000000000000000000000000000000000000
00000000000000000aaaaaa00a00000a000aaa0000aaaa0000000aa000000aaa0000000000000aa00000000000a00a00000000000000000000aaaaa000000000
0aaaaa000aaaaaa00aaaaaa00a0aaa0a00a000a00a0000a00000aaa00000aaa000aaaa0000000aa000aaaa000aaaaaa00aaaaa00aa00a00000aaaaa000000000
0aaaaa000aaaaaa00aaaaaa00a0aaa0a000aaa0000aaaa000a0aaa000a0aaa0000a00a000000a00000aa0a000aaaaaa000aaa000aa00a00000aaaaa000a00000
0aa0aa000aa00aa0000aa0000a0aaa0a00a000a00a0000a000aaa0000aa0a00000a00a00000a000000aa0a00000aa0000aa0aa00aaa00a0000aaaaa00a0aaaa0
00000000000000000a0000a00000000000aaaaa00aaaaaa0000a000000aa000000a00a0000a0000000aa0a0000aaaa000aa0aa00aaaaa0aa00a0000000a00a00
0aaaaa000aaaaaa00aaaaaa00aaa0aaa000aaa0000aaaa000a00a0000a0aa000000aa0000a0000000000000000aaaa000aa0aa00aaaaa0aa00aa0aa000000000
0000000000000000000000000aaaaaaa000000000000000000000000a000000000000000000000000000000000000000000000000000000000000a0000000000
0000000000000000000000000000000000aaaa00000000000000000a000000aa00000000000000000000000000a00a0000000000000000000000000000000000
011111000111111001111110011111110aaaaaa0000aa000000000aa00000aaa00aaaaa000000aaa000000000aa00aa00aaaaaa0aa00a00000aa0aa000000000
0100010001000010010000100100000100aaaa0000a00a0000000aaa0000aaaa00a000a000000a0a00aaa000aaaaaaaa00000000aa00a00000aaaaa00aaa0000
010001000100001001000010010000010a0000a0000aa00000a0aaa00a0aaaaa00aaa0a000000aaa0a0aaa00aaa00aaa0aa0aa00a00000aaaaa00a0aaaa00000
000000000000000000000000000000000aaaaaa000a00a00000aaa0000a0aaa000aaa0a00000a000000a0aaa000000000aaaaaa0aaa00a00000aaa000aaa0aa0
000000000000000000000000000000000aaaaaa000aaaa0000a0a000000a0a0000aaaaa0000a00000000aa0000aaaa000aa00aa0aaaaa0aa0000a00000000000
0111110001111110011111100111111100aaaa0000aaaa000aa00a0000a0a000000aaa0000a00000000a000000aaaa000aa00aa0a0aaa0aa0000000000000000
0000000000000000000000000000000000000000000aa0000a0000000a000a00000000000a000000000000000000000000000000000000000000000000000000
000000000aaaa0000000000000000000000044000044440000444400000044000000000000000000000000000000000000000044400000000000000000000000
0aaaa0000aa0a0000aaaa00000000000444404444400444400004444044404440000000000000000000000444000000000044444440000000000000000000000
0aa0a0000000a00a0000a00a0aaaa000044440440444044440000444444440440000004440000000000444444400000004444400044000000000004440000000
0000a00aaaa0a0a0aaa0a0a00000a00a440004000444400004440000444444000004444444000000044444000440000004444044404400000004444444000000
aaa0a0a0aaa00a00aaa0aa00aaa0a0a0400004044400040404444004440004040444440004400000044440444044000000444040004440000444440004400000
aaa00a00aaa00000aaa00000aaa00a00400004044000040444000404400004040444404440440000004440400044400000044400044444000444404440440000
aaa000000a0000000a000000aaa00000044040404000044040000440044040400044404000444000000444000444440004004444444400400044404000444000
0a00a0000000a0000000a0000a00a000444040400440404004404040444040400004440004444400040044444444004000400444440000400004440004444400
00000000000000000000000000aa0000000000000404400000000000000000000400444444440040004004444400004000040044000404000400444444440040
0aaa00000000000000aa00000aaaa000040440000444400004044000000000000040044444000040000400440004040000004000004400000040044444000040
00aaa0000aaa00000aaaa000aaaaaaa0044440000404000404444004040440000004004400040400000040000044000000000400404400000004004400040400
aaaaaaa000aaa000aaaaaaa000000000040400040040404000040040044440000000400000440000000004004044000000000044004000000000400000444000
00000000aaaaaaa000000000000a0a00004040404400040044004400000400040000040040440000000000440040000000000000000000000000000400400444
000a0a0000000000000a0a000a00000a440004004400000044000000440040400000004400400000000000000000000000000000000000000000004400000000
0a00000a0a0a0a0a0a00000a0aaa00a0440400000004000000040000440004000000000000000000000000000000000000000000000000000000000000000000
aaaaa0a0aaa000a0aaaaa0a0aaaaa0a0000040000000400000004000000040000000000000000000000000000000000000000000000000000000000000000000
01111110110000110111111100000111444000444000004400000044044440440004044000000000000000000000000000000000000000000000000000000000
11000011100000011100000101111101044440040440000404400004404444040040444400000000000404400000000000000000000000000004044000000000
10000001100a0a111000001111000001004444440444404444444004040000440040404000000000004044440000000000040440000000000040444400000000
100a0a1110000010000a0a1000000011440000004044440000444444400404000040444400000000004040400000000000404444000000000040404000000000
100000101000011101000011000a0a10000404040400000404000000000000040000440004000000004044440000000000404040000000000040444400000000
1100011111a00aaa11a00aaa11000011040000040004040440040404044440044400444440000000440044000400000000404444000000000000440004000000
11a00aaa1a0001111a00011101a00aaa044440400400004004000040044440404404440000000000044004444400000000000440004000000440044444000000
1a01011101010100010101001a010111444440404444404044444040444440400044444440000000000444000000000044004444400000004404440000000000
00000000000000000000000000000000000000000444400000000000000000000444444444000000004444444400000044044400000000000044444400000000
00000000000000000000000000000000044440000444400004444000000000000444044444400000044444444400000004444444000000000444444440000000
000101111111111111101000000a0000044440000400000404444004044440000440444440400000044404444040440004444444440000000444044444000000
001100000000000000001100000aa000040000040444404404000044044440004440444444404400044044444440444004440444444044000440444444404400
000000000000000000000000000aaa00044440440000004000444040040000044440044444004440444044444404440004404444404044404440444440404440
001000000000000000000100000a0000000000404400000044000000004440440000000000044400444004444000400044404444444044004440044444404400
00100000000000000000010000000000440040004400400044004000440000400044000444004000000000000000000044400444440040000000004444004000
00100000000000000000010000000000440004000000040000000400440004000444400444400000044440044440000000000000000000004444000000000000
00100000000000000000010000000000000000000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000
0010000000000000000001000000a000044440000440400004444000000000000040040040000000004000000000000000000000000000000000040040000000
00100000000000000000010000000a00044040000400000404404004044440000400004004000000040004004000000000400400400000000040004004000000
001000000000000000000100000000a0040000040040404000000040044040004400004404400000440000400400000004000040040000000400004404400000
0010000000000000000001000000a000004040404400040044004400000000044440000444040000444000440440000044000044044000004400000444040000
00100000000000000000010000000000440400000004000000040000440004004440400444444400444040440040040044040044004004004404000444444400
00100000000000000000010000000000000040000000400000004000000040000444040044444400044404044444440044404004444444004440400044444400
00100000000000000000010000000000000000000000000000000000000000004444000000000000444400004444440004440400444444000444040000000000
00100000000000000000010000000000000000000000000000000000000440004440004004400000444400400000000044440040000000004444004004400000
00100000000000000000010000000000000440000000000000044000004414004400404400004000444000440440400044400044044040004440404400004000
00000000000000000000010000000000004114000044440000411400004114004404404404404000440040440000400044004044000040004404404404404000
00110000000000000000110000000000041411400414114004141140004004004004404400004000440440440440400044044044044040004404404400004000
00010111111111111111100000000000040000400400004004000040000440004044404404044000404440440004400040444044000440004044404404044000
00000000000000000000000000000000004444000044440000444400000000000440004400044000044440440404400004444044040440000440004400044000
00000000000000000000000000000000000000000000000000000000000000000444044040404400044404404040440004440440404044000444044040404400
00111111111111111111110001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111011111110000000000050000000005000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111011111110000805000000800000880000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111011111110008880000008880000088000000000000000000000000000000000000000000000000000000000000000000000000000
01111111111111111111111011111110008a88000088a000000a8000000000000000000000000000000000000000000000000000000000000000000000000000
00111111111111111111110001111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000006666000066660000666600000000000000000000000000000000000000000000000000000000000000000000000000
000000000040004000000000000000000006d0000006d0000006d000000000000000000000000000000000000000000000000000000000000000000000000000
000000a0000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000a000000400000000a0000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00a0a0000004040000a0a00000040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a000000400040000a000000404000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000010101000101010001010101010100000100010001000100010101000001000001010100010001000101010100010000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0603030800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
149013180000060b1b0b1b072b2c2c0800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1a13131800000613131313131313131a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
14131326230b281313131313e413132224242424080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22081313131313131f130f130d13131313131313040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
002a2222081313131313131313131306121208131c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000014131313131313131313131412121a131a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000001613132824262c26241323243b2428131c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000121313131313131313131313131313131c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000a281326080a0303030322222222222222240000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000062813131324040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000181313131313140000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000220413131306280000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000002204130224000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000026232800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
