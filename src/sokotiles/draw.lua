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

function draw_star_field(intensity)
  for i = 1, 300 * intensity do
    pset(rnd(128), rnd(128), rnd(16))
  end
end