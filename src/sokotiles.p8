pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- sokotiles
-- by schoblaska

function _init()
  board_buffer = 3
  cleared_post_win = false
  sprites = {
    w = { 38, 12 },
    y = { 49, 12 },
    g = { 49, 1 },
    b = { 60, 1 },
    E = { 16, 12 },
    W = { 16, 1 },
    G = { 27, 1 },
    Y = { 27, 12 },
    B = { 38, 1 }
  }

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
    { ".", "E", ".", ".", ".", ".", ".", "B", "." },
    { ".", ".", "B", ".", ".", "Y", ".", "Y", "." },
    { ".", "E", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", "E", ".", ".", ".", ".", "E" },
    { ".", ".", ".", ".", ".", ".", ".", ".", "E" }
  }

  cls()
  rectfill(0, 0, 127, 127, 0)
  draw_star_field(1)
end

function _update()
  px, py = find_player()

  if btnp(0) then
    move_if_able(px, py, -1, 0)
  elseif btnp(1) then
    move_if_able(px, py, 1, 0)
  elseif btnp(2) then
    move_if_able(px, py, 0, -1)
  elseif btnp(3) then
    move_if_able(px, py, 0, 1)
  elseif btnp(5) and not is_won() then
    _init()
  end
end

function _draw()
  if is_won() and not cleared_post_win then
    cls()
    cleared_post_win = true
    rectfill(0, 0, 127, 127, 0)
    draw_star_field(2)
  elseif not is_won() and cleared_post_win then
    cls()
    draw_star_field(1)
    cleared_post_win = false
  end

  draw_twinkles()
  print("sokotiles", 14, 8, 7)

  if not is_won() then
    rectfill(board_buffer + 11, board_buffer + 11, board_buffer + 110, board_buffer + 110, 0)
    print("arrows: move", 14, 114, 13)
    print("x: reset", 82, 114, 13)
  end
  draw_board()
end

function draw_star_field(intensity)
  for i = 1, 300 * intensity do
    pset(rnd(128), rnd(128), rnd(16))
  end
end

function find_player()
  for y = 1, 9 do
    for x = 1, 9 do
      if pieces[y][x] == "W" then
        return x, y
      end
    end
  end
end

function move_if_able(x, y, dx, dy)
  local target_x = x + dx
  local target_y = y + dy

  if able_to_move(x, y, dx, dy) then
    move_piece(x, y, target_x, target_y)
    return true
  else
    return false
  end
end

function able_to_move(x, y, dx, dy)
  local target_x = x + dx
  local target_y = y + dy

  if target_x < 1 or target_x > 9 or target_y < 1 or target_y > 9 then
    return false
  end

  local piece = pieces[y][x]
  local target_piece = pieces[target_y][target_x]

  if piece == "E" then
    return false
  elseif piece == "Y" then
    return dx == 0 and (target_piece == "." or move_if_able(target_x, target_y, dx, dy))
  elseif piece == "B" then
    return dy == 0 and (target_piece == "." or move_if_able(target_x, target_y, dx, dy))
  elseif target_piece == "." then
    return true
  elseif move_if_able(target_x, target_y, dx, dy) then
    return true
  else
    return false
  end
end

function move_piece(x, y, target_x, target_y)
  local piece = pieces[y][x]

  pieces[y][x] = "."
  pieces[target_y][target_x] = piece
end

function is_won()
  for y = 1, 9 do
    for x = 1, 9 do
      local board_tile = board[y][x]
      local piece_tile = pieces[y][x]

      if board_tile == "w" and piece_tile ~= "W" then
        return false
      elseif board_tile == "g" and piece_tile ~= "G" then
        return false
      elseif board_tile == "y" and piece_tile ~= "Y" then
        return false
      elseif board_tile == "b" and piece_tile ~= "B" then
        return false
      end
    end
  end

  return true
end

function draw_twinkles()
  local times = is_won() and 10 or 1

  for i = 1, times do
    local is_black = rnd(20) < 19
    local color = is_black and 0 or rnd(15) + 1

    pset(rnd(128), rnd(128), color)
  end
end

function draw_board()
  for x = 1, 9 do
    for y = 1, 9 do
      local board_tile = board[y][x]
      local piece_tile = pieces[y][x]

      if board_tile ~= "." then
        draw_square(sprites[board_tile], x, y)
      end

      if piece_tile ~= "." then
        draw_square(sprites[piece_tile], x, y)
      end
    end
  end
end

function draw_square(sprite, x, y)
  sspr(sprite[1], sprite[2], 11, 11, x * 11 + board_buffer, y * 11 + board_buffer)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d666666666dd666666666dd666666666d0000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd50000bbb00000000ccc0000000000000000000000000000000000000000000000000000000000000
0000000000000000677700077756bbb000bbb56ccc000ccc50000bbb00000000ccc0000000000000000000000000000000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd50000bbb00000000ccc0000000000000000000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd50000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d5555555551d5555555551d55555555500000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d666666666dd666666666d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d5555555551d5555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
