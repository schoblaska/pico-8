board_buffer = 3
stars = {}

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
    rectfill(board_buffer + 11, board_buffer + 11, board_buffer + 110, board_buffer + 110, 0)
    draw_text("arrows: move", 14, 114, 13, 0)
    draw_text("x: reset", 82, 114, 13, 0)
  end

  draw_text("sokotiles", 14, 8, 7, 0)
  draw_board()
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