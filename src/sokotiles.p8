pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- sokotiles
-- by schoblaska

function _init()
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
  load_level()
  set_scene("title")
end

function load_level()
  board = {
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", "y", "." },
    { ".", ".", ".", ".", ".", ".", ".", "y", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", "g", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", "b", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", "w", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." }
  }

  pieces = {
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", "G", "E", "E", "E", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", "W", ".", "." },
    { "E", "E", "E", ".", ".", ".", "E", "Y", "." },
    { ".", "E", ".", "P", ".", ".", ".", "B", "." },
    { ".", ".", "B", ".", ".", "Y", ".", "Y", "." },
    { ".", "E", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", "E", ".", ".", ".", ".", "E" },
    { ".", ".", ".", ".", ".", ".", ".", ".", "E" }
  }

  tiles = {}

  for y = 1, 9 do
    for x = 1, 9 do
      if pieces[y][x] ~= "." then
        add(
          tiles, {
            value = pieces[y][x],
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
  for tile in all(tiles) do
    if tile.x == x and tile.y == y then
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

  if target_x < 1 or target_x > 9 or target_y < 1 or target_y > 9 then
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
  tile.x_offset = (x - target_x) * 11
  tile.y_offset = (y - target_y) * 11
end

function is_won()
  if animating() then
    return false
  end

  for y = 1, 9 do
    for x = 1, 9 do
      local board_square = board[y][x]
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

function animating()
  for tile in all(tiles) do
    if tile.x_offset ~= 0 or tile.y_offset ~= 0 then
      return true
    end
  end

  return false
end

function update_animations()
  for tile in all(tiles) do
    if tile.x_offset ~= 0 and sgn(tile.x_offset) == 1 then
      tile.x_offset = max(tile.x_offset - sgn(tile.x_offset) * 2, 0)
    elseif tile.x_offset ~= 0 and sgn(tile.x_offset) == -1 then
      tile.x_offset = min(tile.x_offset - sgn(tile.x_offset) * 2, 0)
    elseif tile.y_offset ~= 0 and sgn(tile.y_offset) == 1 then
      tile.y_offset = max(tile.y_offset - sgn(tile.y_offset) * 2, 0)
    elseif tile.y_offset ~= 0 and sgn(tile.y_offset) == -1 then
      tile.y_offset = min(tile.y_offset - sgn(tile.y_offset) * 2, 0)
    end
  end
end

function draw_board()
  for x = 1, 9 do
    for y = 1, 9 do
      local board_square = board[y][x]

      if board_square ~= "." then
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

function draw_tile(tile)
  local value, x, y, xoff, yoff = tile.value, tile.x, tile.y, tile.x_offset, tile.y_offset
  local board_square = board[y][x]

  if value == "P" then
    if board_square == "." then
      palt(0, false)
    end
    draw_square(sprites[value], x, y, xoff, yoff)
    pal()

    -- fill in pixels that match any adjacent G, Y, or B pieces
    local center = { x = x * 11 + 8, y = y * 11 + 8 }
    local lval = tile_value_at(x - 1, y)
    local rval = tile_value_at(x + 1, y)
    local uval = tile_value_at(x, y - 1)
    local dval = tile_value_at(x, y + 1)

    if x > 1 and (lval == "G" or lval == "B") then
      local color = color_for_value(lval)
      line(center.x + 3, center.y, center.x + 4, center.y, color)
      line(center.x + 4, center.y + 1, center.x + 4, center.y - 1, color)
    end

    if x < 9 and (rval == "G" or rval == "B") then
      local color = color_for_value(rval)
      line(center.x - 3, center.y, center.x - 4, center.y, color)
      line(center.x - 4, center.y + 1, center.x - 4, center.y - 1, color)
    end

    if y > 1 and (uval == "G" or uval == "Y") then
      local color = color_for_value(uval)
      line(center.x, center.y + 3, center.x, center.y + 4, color)
      line(center.x + 1, center.y + 4, center.x - 1, center.y + 4, color)
    end

    if y < 9 and (dval == "G" or dval == "Y") then
      local color = color_for_value(dval)
      line(center.x, center.y - 3, center.x, center.y - 4, color)
      line(center.x + 1, center.y - 4, center.x - 1, center.y - 4, color)
    end
  else
    if board_square == "." then
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
  sspr(sprite[1], sprite[2], 11, 11, x * 11 + 3 + xoff, y * 11 + 3 + yoff)
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
    rectfill(11, 11, 115, 115, 0)
    draw_dotted_line(12, 18, 12, 114, 13)
    draw_dotted_line(114, 12, 114, 114, 13)
    draw_dotted_line(18, 12, 114, 12, 13)
    draw_dotted_line(12, 114, 114, 114, 13)
    draw_text("arrows: move", 14, 114, 13, 0)
    draw_text("x: reset", 82, 114, 13, 0)
  end

  draw_text("sokotiles", 14, 8, 7, 0)
  draw_board()
  draw_tiles()
end

function draw_title()
  local menu_xy = { x = 14, y = 64 }

  draw_stars(100, 1)
  sspr(0, 109, 128, 18, 0, 32)
  draw_text("play", menu_xy.x, menu_xy.y, 7, 0)
  draw_text("tutorial", menu_xy.x, menu_xy.y + 8, 5, 0)
  draw_text(">", menu_xy.x - 5, menu_xy.y + title_menu_selection * 8, 7, 0)
end

function draw_text(text, x, y, fg, bg)
  if bg then
    rectfill(x, y, x + #text * 4 - 2, y + 4, bg)
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
6dddd7dddd56ddddbdddd56dddd5dddd500000000000000000000000000000000000000000000000677007756bb00bb56550055500077000000bb00000000000
67dd000dd756dbd000dbd565dd000dd55000077700000000bbb00000000000000000000000000000677007756bb00bb56550055500077000000bb00000000000
677700077756bbb000bbb565550005555000077700000000bbb000000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
67dd000dd756dbd000dbd565dd000dd55000077700000000bbb000000000000000000000000000006dd77dd56ddbbdd56dd55dd5000000000000000000000000
6dddd7dddd56ddddbdddd56dddd5dddd500000000000000000000000000000000000000000000000655555556555555565555555000000000000000000000000
6dddd7dddd56dddbbbddd56dddd5dddd500000000000000000000000000000000000000000000000666666666666666666666666000000000000000000000000
6ddd777ddd56ddddbdddd56ddd555ddd5000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
d5555555551d5555555551d5555555551000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
d666666666dd666666666dd666666666d000000000000000000000000000000000000000000000006cc00cc56dd00dd56dddddd5000cc000000aa00000000000
6ddddddddd56ddddadddd56ddddddddd5000000000000000000000000000000000000000000000006cc00cc56dd00dd56dddddd5000cc000000aa00000000000
6ddddddddd56dddaaaddd56ddddddddd5000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
6ddddddddd56ddddadddd56ddddddddd5000000000000000000000000000000000000000000000006dddddd56ddaadd56dddddd5000000000000000000000000
6dcd000dcd56ddd000ddd56ddddddddd50000ccc00000000aaa00000000000000000000000000000655555556555555565555555000000000000000000000000
6ccc000ccc56ddd000ddd56ddddddddd50000ccc00000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000
6dcd000dcd56ddd000ddd56ddddddddd50000ccc00000000aaa00000000000000000000000000000000000000000000000000000000000000000000000000000
6ddddddddd56ddddadddd56ddddddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0000000000000000007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000415050500053007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000004053007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5050500000005000007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050005443000051007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000420000000042007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0050000000000000007f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000005000000000507f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000507f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7f7f7f7f7f7f7f7f7f7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
