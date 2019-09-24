function check_win_lose()
  if (is_tile(win, p.x, p.y)) then
    game_win = true
    game_over = true
  elseif (is_tile(lose, p.x, p.y)) then
    game_win = false
    game_over = true
  end
end

function draw_win_lose()
  camera()
  if (game_win) then
    print("★ you win! ★", 37, 64, 7)
  else
    print("game over! :(", 38, 64, 7)
  end
end
