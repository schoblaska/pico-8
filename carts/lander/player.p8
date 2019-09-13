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
  spr(p.sprite, p.x, p.y)
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
