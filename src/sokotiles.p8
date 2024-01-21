pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- sokotiles
-- by schoblaska

function _init()
  config = {
    tilew = 11,
    boardxy = 14, -- top-left corner of board
    grids = 9
  }

  stars = {}
  sprites = {
    W = { 0, 0 },
    B = { 0, 11 },
    G = { 11, 0 },
    Y = { 11, 11 },
    P = { 22, 0 },
    E = { 22, 11 },
    w = { 33, 0 },
    b = { 33, 11 },
    g = { 44, 0 },
    y = { 44, 11 }
  }
  tile_map_sprites = {
    [10] = "W",
    [26] = "B",
    [11] = "G",
    [27] = "Y",
    [12] = "P",
    [28] = "E"
  }
  board_map_sprites = {
    [13] = "w",
    [29] = "b",
    [14] = "g",
    [30] = "y"
  }
  reset_cache()
  load_level()
  set_scene("title")
end

function _update60()
  if scene == "title" then
    if btnp(2) and title_menu_selection > 0 then
      title_menu_selection -= 1
    elseif btnp(3) and title_menu_selection < 1 then
      title_menu_selection += 1
    elseif btnp(4) and title_menu_selection == 0 then
      set_scene("game")
    end
  elseif scene == "game" then
    if animating() then
      update_animations()
    else
      local player = find_player()

      if btnp(0) then
        move_if_able(player.x, player.y, -1, 0, false, false)
      elseif btnp(1) then
        move_if_able(player.x, player.y, 1, 0, false, false)
      elseif btnp(2) then
        move_if_able(player.x, player.y, 0, -1, false, false)
      elseif btnp(3) then
        move_if_able(player.x, player.y, 0, 1, false, false)
      elseif btnp(5) and not is_won() then
        load_level()
      end
    end
  end
end

function _draw()
  cls()

  if scene == "title" then
    draw_title()
  elseif scene == "game" then
    draw_game()
  end
  -- print("cpu: " .. stat(1) .. "%", 1, 122, 12)
end

function reset_cache()
  cache = {}
  cache_keys = {}
end

function write_cache(key, value)
  cache[key] = value
  cache_keys[key] = true
end

function read_cache(key)
  return cache[key]
end

function in_cache(key)
  return cache_keys[key]
end

function load_level()
  board = {}
  tiles = {}

  for x = 1, config.grids do
    board[x] = {}
    for y = 1, config.grids do
      map_sprite = mget(x - 1, y - 1)
      if board_map_sprites[map_sprite] then
        board[x][y] = board_map_sprites[map_sprite]
      else
        board[x][y] = "."
        if tile_map_sprites[map_sprite] then
          add(
            tiles, {
              value = tile_map_sprites[map_sprite],
              x = x,
              y = y,
              x_offset = 0,
              y_offset = 0
            }
          )
        end
      end
    end
  end
end

-- TODO: not necessary?
function set_scene(new_scene)
  if new_scene == "title" then
    title_menu_selection = 0
  end

  scene = new_scene
end

function find_player()
  for tile in all(tiles) do
    if tile.value == "W" then
      return tile
    end
  end
end

function tile_at(x, y)
  cache_key = "tile_at_" .. x .. "_" .. y

  if in_cache(cache_key) then
    return read_cache(cache_key)
  end

  for tile in all(tiles) do
    if tile.x == x and tile.y == y then
      write_cache(cache_key, tile)
      return tile
    end
  end
end

function tile_value_at(x, y)
  local tile = tile_at(x, y)

  if tile == nil then
    return nil
  else
    return tile.value
  end
end

function move_if_able(x, y, dx, dy, pusher_push, block_push)
  local target_x = x + dx
  local target_y = y + dy

  if able_to_move(x, y, dx, dy, pusher_push, block_push) then
    move_tile(x, y, target_x, target_y)
    return true
  else
    return false
  end
end

function able_to_move(x, y, dx, dy, pusher_push, block_push)
  local target_x = x + dx
  local target_y = y + dy

  if target_x < 1 or target_x > config.grids or target_y < 1 or target_y > config.grids then
    return false
  end

  local tile = tile_at(x, y)
  local target_tile = tile_at(target_x, target_y)

  if tile == nil then
    return false
  end

  if tile.value == "E" then
    return false
  elseif tile.value == "Y" then
    return (dx == 0 or pusher_push) and (target_tile == nil or move_if_able(target_x, target_y, dx, dy, pusher_push, true))
  elseif tile.value == "B" then
    return (dy == 0 or pusher_push) and (target_tile == nil or move_if_able(target_x, target_y, dx, dy, pusher_push, true))
  elseif tile.value == "G" then
    return target_tile == nil or move_if_able(target_x, target_y, dx, dy, pusher_push, true)
  elseif tile.value == "P" then
    -- a push only becomes a "pusher push" if the pusher is pushed by a block
    return target_tile == nil or move_if_able(target_x, target_y, dx, dy, block_push, block_push)
  elseif target_tile == nil then
    return true
  elseif move_if_able(target_x, target_y, dx, dy, pusher_push) then
    return true
  else
    return false
  end
end

function move_tile(x, y, target_x, target_y)
  local tile = tile_at(x, y)

  tile.x = target_x
  tile.y = target_y
  tile.x_offset = (x - target_x) * config.tilew
  tile.y_offset = (y - target_y) * config.tilew

  reset_cache()
end

function is_won()
  if in_cache("is_won") then
    return read_cache("is_won")
  end

  if animating() then
    return false
  end

  local check_is_won = function()
    for x = 1, config.grids do
      for y = 1, config.grids do
        local board_square = board[x][y]
        local tile_value = tile_value_at(x, y)

        if board_square == "w" and tile_value ~= "W" then
          return false
        elseif board_square == "g" and tile_value ~= "G" then
          return false
        elseif board_square == "y" and tile_value ~= "Y" then
          return false
        elseif board_square == "b" and tile_value ~= "B" then
          return false
        end
      end
    end

    return true
  end

  local val = check_is_won()
  write_cache("is_won", val)
  return val
end

function animating()
  if in_cache("animating") then
    return read_cache("animating")
  end

  for tile in all(tiles) do
    if tile.x_offset ~= 0 or tile.y_offset ~= 0 then
      return true
    end
  end

  write_cache("animating", false)
  return false
end

function update_animations()
  for tile in all(tiles) do
    if tile.x_offset ~= 0 and sgn(tile.x_offset) == 1 then
      tile.x_offset = max(tile.x_offset - sgn(tile.x_offset) * 3, 0)
    elseif tile.x_offset ~= 0 and sgn(tile.x_offset) == -1 then
      tile.x_offset = min(tile.x_offset - sgn(tile.x_offset) * 3, 0)
    elseif tile.y_offset ~= 0 and sgn(tile.y_offset) == 1 then
      tile.y_offset = max(tile.y_offset - sgn(tile.y_offset) * 3, 0)
    elseif tile.y_offset ~= 0 and sgn(tile.y_offset) == -1 then
      tile.y_offset = min(tile.y_offset - sgn(tile.y_offset) * 3, 0)
    end
  end
end

function draw_board()
  for x = 1, config.grids do
    for y = 1, config.grids do
      local board_square = board[x][y]

      if board_square == "." then
        if not is_won() then
          pset(x * config.tilew + 8, y * config.tilew + 8, 5)
        end
      else
        draw_square(sprites[board_square], x, y)
      end
    end
  end
end

function draw_tiles()
  for tile in all(tiles) do
    draw_tile(tile)
  end
end

function adjacent_tile_val(tile, dx, dy)
  local adj_tile = tile_at(tile.x + dx, tile.y + dy)

  if not adj_tile then
    return nil
  elseif adj_tile.x_offset ~= tile.x_offset or adj_tile.y_offset ~= tile.y_offset then
    return nil
  else
    return adj_tile.value
  end
end

function draw_tile(tile)
  local value, x, y, xoff, yoff = tile.value, tile.x, tile.y, tile.x_offset, tile.y_offset
  local board_square = board[x][y]

  if value == "P" then
    if board_square == "." then
      palt(0, false)
    end
    draw_square(sprites[value], x, y, xoff, yoff)
    pal()

    -- fill in pixels that match any adjacent G, Y, or B pieces
    local center = { x = x * config.tilew + 8 + tile.x_offset, y = y * config.tilew + 8 + tile.y_offset }
    local lval = adjacent_tile_val(tile, -1, 0)
    local rval = adjacent_tile_val(tile, 1, 0)
    local uval = adjacent_tile_val(tile, 0, -1)
    local dval = adjacent_tile_val(tile, 0, 1)

    if x > 1 and (lval == "G" or lval == "B") then
      local color = color_for_value(lval)
      line(center.x + 3, center.y, center.x + 4, center.y, color)
      line(center.x + 4, center.y + 1, center.x + 4, center.y - 1, color)
    end

    if x < config.grids and (rval == "G" or rval == "B") then
      local color = color_for_value(rval)
      line(center.x - 3, center.y, center.x - 4, center.y, color)
      line(center.x - 4, center.y + 1, center.x - 4, center.y - 1, color)
    end

    if y > 1 and (uval == "G" or uval == "Y") then
      local color = color_for_value(uval)
      line(center.x, center.y + 3, center.x, center.y + 4, color)
      line(center.x + 1, center.y + 4, center.x - 1, center.y + 4, color)
    end

    if y < config.grids and (dval == "G" or dval == "Y") then
      local color = color_for_value(dval)
      line(center.x, center.y - 3, center.x, center.y - 4, color)
      line(center.x + 1, center.y - 4, center.x - 1, center.y - 4, color)
    end
  else
    if board_square == "." and is_won() then
      palt(0, false)
    end
    draw_square(sprites[value], x, y, xoff, yoff)
    pal()
  end
end

function color_for_value(value)
  if value == "W" then
    return 7
  elseif value == "G" then
    return 11
  elseif value == "Y" then
    return 10
  elseif value == "B" then
    return 12
  elseif value == "P" then
    return 13
  end
end

function draw_square(sprite, x, y, xoff, yoff)
  xoff = xoff or 0
  yoff = yoff or 0
  sspr(
    sprite[1], sprite[2], config.tilew, config.tilew,
    (x - 1) * config.tilew + config.boardxy + xoff,
    (y - 1) * config.tilew + config.boardxy + yoff
  )
end

function draw_stars(count, twinkle)
  while #stars < count do
    add(
      stars, {
        x = flr(rnd(128)),
        y = flr(rnd(128)),
        color = flr(rnd(15)) + 1
      }
    )
  end

  while #stars > count do
    del(stars, stars[1])
  end

  if rnd(30) < twinkle then
    i = flr(rnd(#stars)) + 1
    del(stars, stars[i])
  end

  for star in all(stars) do
    pset(star.x, star.y, star.color)
  end
end

function draw_game()
  if is_won() then
    draw_stars(300, 5)
  else
    draw_stars(100, 1)
    rectfill(
      config.boardxy - 2,
      config.boardxy - 2,
      config.boardxy + config.tilew * config.grids + 1,
      config.boardxy + config.tilew * config.grids + 1,
      0
    )
    draw_text(
      "arrows: move  ❎: reset",
      config.boardxy + config.grids * config.tilew - 91,
      config.boardxy + config.grids * config.tilew + 2,
      13,
      0
    )
  end

  draw_text("sokotiles", config.boardxy, config.boardxy - 7, 7, 0)
  draw_board()
  draw_tiles()
end

function draw_title()
  local menu_xy = { x = 14, y = 64 }

  draw_stars(100, 1)
  sspr(0, 109, 128, 18, 0, 32)
  draw_text("new game", menu_xy.x, menu_xy.y, 7, 0)
  draw_text("continue", menu_xy.x, menu_xy.y + 8, 5, 0)
  draw_text(">", menu_xy.x - 5, menu_xy.y + title_menu_selection * 8, 7, 0)
end

function draw_text(text, x, y, fg, bg)
  if bg then
    local width = -1

    for i = 1, #text do
      local char = sub(text, i, i)
      local char_ord = ord(char)

      if char_ord < 128 then
        width += 4
      else
        width += 8 -- for double-width characters like "❎"
      end
    end

    rectfill(x - 1, y - 1, x + width, y + 5, bg)
  end

  print(text, x, y, fg)
end

function draw_dotted_line(x1, y1, x2, y2, color)
  local dx = x2 - x1
  local dy = y2 - y1
  local steps = max(abs(dx), abs(dy))
  local x_step = dx / steps
  local y_step = dy / steps

  for i = 0, steps do
    if i % 6 == 0 then
      pset(x1 + i * x_step, y1 + i * y_step, color)
    end
  end
end

__gfx__
d666666666dd666666666dd666666666d00000000000000000000000000000000000000000000000666666666666666666666666000000000000000000000000
6ddd777ddd56ddddbdddd56ddd555ddd5000000000000000000000000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
6dddd7dddd56dddbbbddd56dddd5dddd5000000000000000000000000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
6dddd7dddd56ddddbdddd56ddddddddd500055555000000555550000000000000000000000000000677007756bb00bb56550055500077000000bb00000000000
67dd000dd756dbd000dbd565dd000dd55000577750000005bbb50000000000000000000000000000677007756bb00bb56550055500077000000bb00000000000
677700077756bbb000bbb5655d000d555000577750000005bbb500000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
67dd000dd756dbd000dbd565dd000dd55000577750000005bbb500000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
6dddd7dddd56ddddbdddd56ddddddddd500055555000000555550000000000000000000000000000655555556555555565555555000000000000000000000000
6dddd7dddd56dddbbbddd56dddd5dddd500000000000000000000000000000000000000000000000666666666666666666666666000000000000000000000000
6ddd777ddd56ddddbdddd56ddd555ddd5000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
d5555555551d5555555551d5555555551000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
d666666666dd666666666dd666666666d000000000000000000000000000000000000000000000006cc00cc56dd00dd56dddddd5000cc000000aa00000000000
6ddddddddd56ddddadddd56ddddddddd5000000000000000000000000000000000000000000000006cc00cc56dd00dd56dddddd5000cc000000aa00000000000
6ddddddddd56dddaaaddd56ddddddddd5000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
6ddddddddd56ddddadddd56ddddddddd5000555550000005555500000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
6dcd000dcd56ddd000ddd56ddddddddd50005ccc50000005aaa50000000000000000000000000000655555556555555565555555000000000000000000000000
6ccc000ccc56ddd000ddd56ddddddddd50005ccc50000005aaa50000000000000000000000000000000000000000000000000000000000000000000000000000
6dcd000dcd56ddd000ddd56ddddddddd50005ccc50000005aaa50000000000000000000000000000000000000000000000000000000000000000000000000000
6ddddddddd56ddddadddd56ddddddddd500055555000000555550000000000000000000000000000000000000000000000000000000000000000000000000000
6ddddddddd56dddaaaddd56ddddddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6ddddddddd56ddddadddd56ddddddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d5555555551d5555555551d555555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000011111111
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000005ddddddddd500015ddddddd50001ddd10001dddd0015ddddddd5000ddddddddddd501ddd101ddd10000000ddddddddddd0005ddddddddd500000000
0000000067777777777d0057777777777600d777d000677760577777777776007777777777760d777d0d777d0000000777777777770067777777777d00000000
0000000577777777777d0077777777777750d777d00d777700777777777777507777777777760d777d0d777d0000000777777777770577777777777d00000000
0000000d77777777777d00777777777777d0d777d007777500777777777777d07777777777760d777d0d777d0000000777777777770d77777777777d00000000
0000000d77777777777d00777777777777d0d777d067776000777777777777d07777777777760d777d0d777d0000000777766666660d77777777777d00000000
0000000d777d000000000077771000d777d0d777d57777100077771000d777d00000777600000d777d0d777d0000000777700000000d777d0000000000000000
0000000d77750000000000777700005777d0d777d6777d0000777700005777d00000777600000d777d0d777d0000000777700000000d77750000000000000000
0000000d7777ddddd50000777700005777d0d7777777600000777700005777d00000777600000d777d0d777d0000000777766666600d7777ddddd50000000000
0000000d77777777777100777700005777d0d7777777600000777700005777d00000777600000d777d0d777d0000000777777777700d77777777777100000000
0000000577777777777d00777700005777d0d7777777710000777700005777d00000777600000d777d0d777d0000000777777777700577777777777d00000000
00000000d7777777777700777700005777d0d777d777760000777700005777d00000777600000d777d0d777d00000007777777777000d7777777777700000000
0000000000000005777700777700005777d0d777d577775000777700005777d00000777600000d777d0d777d0000000777700000000000000005777700000000
0000000000000000777700777700005777d0d777d067777000777700005777d00000777600000d777d0d777d0000000777700000000000000000777700000000
00000001555555567777007777d5557777d0d777d057777d007777d5557777d00000777600000d777d0d77765555550777755555550155555556777700000000
0000000d77777777777700777777777777d0d777d006777710777777777777d00000777600000d777d0d77777777760777777777770d77777777777700000000
0000000d7777777777760077777777777750d777d001777760777777777777500000777600000d777d0d77777777760777777777770d77777777777600000000
0000000d77777777777d00d7777777777700d777d000677775d77777777777000000777600000d777d0d77777777760777777777770d77777777777d00000000
0000000d7777777777d0000d677777776500d777d0001777760d6777777765000000777600000d777d0d77777777760777777777770d7777777777d000000000
__map__
1c00000000000000003f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000b1c1c1c001e003f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000a1e003f000000000a000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c1c1c0000001c1b003f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c000c0e00001a003f000000000d000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00001a00001b1d1b003f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001c000000000000003f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000001c0000000d1c3f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1c000000001c00001c3f0000000000000000003f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f3f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
