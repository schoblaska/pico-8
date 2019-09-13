function make_player()
  player = {
    x = 24,
    y = 60,
    dy = 0,
    rise = 1,
    fall = 2,
    dead = 3,
    speed = 2,
    score = 0
  }
end

function move_player()
  gravity = 0.1
  jumpity = 2

  player.dy += gravity

  if (btnp(2)) then
    player.dy -= jumpity
    sfx(0)
  end

  player.y += player.dy

  player.score += player.speed
end

function draw_player()
  if (game_over) then
    spr(player.dead, player.x, player.y)
  elseif (player.dy < 0) then
    spr(player.rise, player.x, player.y)
  else
    spr(player.fall, player.x, player.y)
  end
end
