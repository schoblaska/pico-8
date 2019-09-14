function make_player()
  p = {
    x = 60,
    y = 8,
    dx = 0,
    dy = 0,
    sprite = 1,
    alive = true,
    thrust = 0.075
  }
end

function move_player()
  p.dy += g

  thrust()

  p.x += p.dx
  p.y += p.dy

  stay_on_screen()
end

function draw_player()
  if (game_over and not win) then
    spr(5, p.x, p.y)
  else
    spr(p.sprite, p.x, p.y)
  end
end

function thrust()
  if (btn(0)) p.dx -= p.thrust
  if (btn(1)) p.dx += p.thrust
  if (btn(2)) p.dy -= p.thrust

  if (btn(0) or btn(1) or btn(2)) sfx(0)
end

function stay_on_screen()
  if (p.x < 0) then
    p.x = 0
    p.dx = 0
  end

  if (p.x > 119) then
    p.x = 119
    p.dx = 0
  end

  if (p.y < 0) then
    p.y = 0
    p.dy = 0
  end
end

function check_land()
  l_x = flr(p.x)
  r_x = l_x + 7
  b_y = flr(p.y + 7)

  over_pad = l_x >= pad.x and r_x <= pad.x + pad.width
  on_pad = b_y >= pad.y - 1
  slow = p.dy < 1

  if (over_pad and on_pad and slow) then
    end_game(true)
  elseif (over_pad and on_pad) then
    end_game(false)
  else
    for i = l_x, r_x do
      if (gnd[i] <= b_y) end_game(false)
    end
  end
end
