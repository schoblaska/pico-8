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

function piece_is_slider(piece)
  return piece == "G" or piece == "Y" or piece == "B"
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