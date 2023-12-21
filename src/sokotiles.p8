pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- sokotiles
-- by schoblaska

function _init()
  board_buffer = 3
  cleared_post_win = false
  sprites = {
    e = { 60, 12 },
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
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "w", "e" },
    { "e", "e", "e", "e", "e", "e", "e", "e", "e" }
  }

  pieces = {
    { ".", ".", "G", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", "E", "E", "E", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", "W", ".", "." },
    { "E", "E", "E", ".", ".", ".", "E", ".", "." },
    { ".", "E", ".", ".", ".", ".", ".", "Y", "." },
    { ".", ".", "B", ".", ".", ".", ".", "Y", "." },
    { ".", "E", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", "E", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." }
  }

  cls()
  rectfill(0, 0, 127, 127, 0)
  draw_star_field(1)
end

function _update()
  if btnp(0) then
    attempt_move(-1, 0)
  elseif btnp(1) then
    attempt_move(1, 0)
  elseif btnp(2) then
    attempt_move(0, -1)
  elseif btnp(3) then
    attempt_move(0, 1)
  elseif btnp(5) and not is_won() then
    _init()
  end
end

function _draw()
  if is_won() and not cleared_post_win then
    cleared_post_win = true
    cls()
    rectfill(0, 0, 127, 127, 0)
    draw_star_field(2)
  elseif not is_won() then
    if cleared_post_win then
      cls()
      draw_star_field(1)
    end
    cleared_post_win = false
  end

  draw_twinkles()
  if not is_won() then
    print("sokotiles", 14, 8, 7)
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

function attempt_move(x, y)
  local player_x, player_y = find_player()

  local target_x = player_x + x
  local target_y = player_y + y

  if target_x < 1 or target_x > 9 or target_y < 1 or target_y > 9 then
    return
  end

  local target_piece = pieces[target_y][target_x]

  if target_piece == "." then
    move_player(player_x, player_y, target_x, target_y)
  end
end

function move_player(from_x, from_y, to_x, to_y)
  pieces[from_y][from_x] = "."
  pieces[to_y][to_x] = "W"
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

      if is_won() and board_tile ~= "e" then
        draw_square(sprites[board_tile], x, y)
      elseif not is_won() then
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
0000000000000000d666666666dd666666666dd666666666d1111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd51111bbb11111111ccc1111111111111110000000000000000000000000000000000000000000000
0000000000000000677700077756bbb000bbb56ccc000ccc51111bbb11111111ccc1111111111111110000000000000000000000000000000000000000000000
000000000000000067dd000dd756dbd000dbd56dcd000dcd51111bbb11111111ccc1111111111111110000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56ddddbdddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd51111111111111111111111111111111110000000000000000000000000000000000000000000000
0000000000000000d5555555551d5555555551d55555555511111111111111111111111111111111110000000000000000000000000000000000000000000000
0000000000000000d666666666dd666666666d111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5111177711111111aaa111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5111177711111111aaa111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddd000ddd5111177711111111aaa111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd5111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
0000000000000000d5555555551d5555555551111111111111111111111111111111111000000000000000000000000000000000000000000000000000000000
