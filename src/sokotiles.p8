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
    B = { 38, 1 },
    P = { 60, 12 },
    WV = { 71, 1 },
    BV = { 71, 12 },
    GV = { 82, 1 },
    YV = { 82, 12 }
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
    { ".", "E", ".", "P", ".", ".", ".", "B", "." },
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
    move_if_able(px, py, -1, 0, false, false)
  elseif btnp(1) then
    move_if_able(px, py, 1, 0, false, false)
  elseif btnp(2) then
    move_if_able(px, py, 0, -1, false, false)
  elseif btnp(3) then
    move_if_able(px, py, 0, 1, false, false)
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

function move_if_able(x, y, dx, dy, pusher_push, block_push)
  local target_x = x + dx
  local target_y = y + dy

  if able_to_move(x, y, dx, dy, pusher_push, block_push) then
    move_piece(x, y, target_x, target_y)
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

  local piece = pieces[y][x]
  local target_piece = pieces[target_y][target_x]

  if piece == "E" then
    return false
  elseif piece == "Y" then
    return (dx == 0 or pusher_push) and (target_piece == "." or move_if_able(target_x, target_y, dx, dy, pusher_push, true))
  elseif piece == "B" then
    return (dy == 0 or pusher_push) and (target_piece == "." or move_if_able(target_x, target_y, dx, dy, pusher_push, true))
  elseif piece == "G" then
    return target_piece == "." or move_if_able(target_x, target_y, dx, dy, pusher_push, true)
  elseif piece == "P" then
    -- a push only becomes a "pusher push" if the pusher is pushed by a block
    return target_piece == "." or move_if_able(target_x, target_y, dx, dy, block_push, block_push)
  elseif target_piece == "." then
    return true
  elseif move_if_able(target_x, target_y, dx, dy, pusher_push) then
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

      if piece_tile == "P" then
        draw_square(sprites[piece_tile], x, y)

        -- fill in pixels that match any adjacent G, Y, or B pieces
        local center = { x = x * 11 + board_buffer + 5, y = y * 11 + board_buffer + 5 }

        if x > 1 and (pieces[y][x - 1] == "G" or pieces[y][x - 1] == "B") then
          local color = color_for_piece(pieces[y][x - 1])
          line(center.x + 3, center.y, center.x + 4, center.y, color)
          line(center.x + 4, center.y + 1, center.x + 4, center.y - 1, color)
        end

        if x < 9 and (pieces[y][x + 1] == "G" or pieces[y][x + 1] == "B") then
          local color = color_for_piece(pieces[y][x + 1])
          line(center.x - 3, center.y, center.x - 4, center.y, color)
          line(center.x - 4, center.y + 1, center.x - 4, center.y - 1, color)
        end

        if y > 1 and (pieces[y - 1][x] == "G" or pieces[y - 1][x] == "Y") then
          local color = color_for_piece(pieces[y - 1][x])
          line(center.x, center.y + 3, center.x, center.y + 4, color)
          line(center.x + 1, center.y + 4, center.x - 1, center.y + 4, color)
        end

        if y < 9 and (pieces[y + 1][x] == "G" or pieces[y + 1][x] == "Y") then
          local color = color_for_piece(pieces[y + 1][x])
          line(center.x, center.y - 3, center.x, center.y - 4, color)
          line(center.x + 1, center.y - 4, center.x - 1, center.y - 4, color)
        end
      elseif piece_tile == "W" then
        if board_tile == "w" then
          draw_square(sprites["WV"], x, y)
        else
          draw_square(sprites["W"], x, y)
        end
      elseif piece_tile == "Y" then
        if board_tile == "y" then
          draw_square(sprites["YV"], x, y)
        else
          draw_square(sprites["Y"], x, y)
        end
      elseif piece_tile == "G" then
        if board_tile == "g" then
          draw_square(sprites["GV"], x, y)
        else
          draw_square(sprites["G"], x, y)
        end
      elseif piece_tile == "B" then
        if board_tile == "b" then
          draw_square(sprites["BV"], x, y)
        else
          draw_square(sprites["B"], x, y)
        end
      elseif piece_tile ~= "." then
        draw_square(sprites[piece_tile], x, y)
      end
    end
  end
end

function piece_is_slider(piece)
  return piece == "G" or piece == "Y" or piece == "B"
end

function color_for_piece(piece)
  if piece == "W" then
    return 7
  elseif piece == "G" then
    return 11
  elseif piece == "Y" then
    return 10
  elseif piece == "B" then
    return 12
  elseif piece == "P" then
    return 13
  end
end

function draw_square(sprite, x, y)
  sspr(sprite[1], sprite[2], 11, 11, x * 11 + board_buffer, y * 11 + board_buffer)
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d666666666dd666666666dd666666666d0000000000000000000000d666666666dd666666666d00000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd500000000000000000000006ddd777ddd56ddddbdddd500000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd500000000000000000000006dddd7dddd56dddbbbddd500000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd500000000000000000000006dd66766dd56dd33b33dd500000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd50000bbb00000000ccc000067d60006d756db30003bd500000000000000000000000000000000000
0000000000000000677700077756bbb000bbb56ccc000ccc50000bbb00000000ccc0000677700077756bbb000bbb500000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd50000bbb00000000ccc000067d60006d756db30003bd500000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd500000000000000000000006dd66766dd56dd33b33dd500000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd500000000000000000000006dddd7dddd56dddbbbddd500000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd500000000000000000000006ddd777ddd56ddddbdddd500000000000000000000000000000000000
0000000000000000d5555555551d5555555551d55555555500000000000000000000000d5555555551d555555555100000000000000000000000000000000000
0000000000000000d666666666dd666666666d0000000000000000000000d666666666dd666666666dd666666666d00000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006ddd555ddd56ddddddddd56ddddadddd500000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd500000000000000000000006dddd5dddd56dddd1dddd56dddaaaddd500000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006dddd5dddd56dd11111dd56dd99a99dd500000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa000065dd000dd556dc10001cd56dd90009dd500000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa0000655500055556ccc000ccc56d9900099d500000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5000077700000000aaa000065dd000dd556dc10001cd56dd90009dd500000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006dddd5dddd56dd11111dd56dd99a99dd500000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd500000000000000000000006dddd5dddd56dddd1dddd56dddaaaddd500000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006ddd555ddd56ddddddddd56ddddadddd500000000000000000000000000000000000
0000000000000000d5555555551d55555555500000000000000000000000d5555555550d5555555550d555555555000000000000000000000000000000000000
