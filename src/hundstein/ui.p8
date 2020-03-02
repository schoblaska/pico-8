function draw_ui()
  rectfill(0, 110, 127, 127, 12)

  -- player face
  if flr(t()) % 2 == 1 then
    sspr(32, 96, 16, 16, 56, 111)
  else
    decimal = flr((t() - flr(t())) * 10)
    if decimal < 5 then
      sspr(48, 96, 16, 16, 56, 111)
    else
      sspr(32, 112, 16, 16, 56, 111)
    end
  end

  if player.score > 99 then
    scoreX = 8
  elseif player.score > 9 then
    scoreX = 10
  else
    scoreX = 12
  end

  rectfill(1, 111, 26, 126, 1)
  print("score", 4, 113, 6)
  print(player.score, scoreX, 120, 6)

  rectfill(28, 111, 54, 126, 1)
  print("level", 32, 113, 6)
  print("1-1", 36, 120, 6)

  rectfill(73, 111, 101, 126, 1)
  print("health", 76, 113, 6)
  print("100%", 80, 120, 6)

  if player.ammo > 9 then
    ammoX = 111
  else
    ammoX = 113
  end

  rectfill(103, 111, 126, 126, 1)
  print("ammo", 107, 113, 6)
  print(min(player.ammo, 99), ammoX, 120, 6)
end
