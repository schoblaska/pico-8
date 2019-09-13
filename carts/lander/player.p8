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
