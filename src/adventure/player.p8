function make_player()
  p = {
    x = 3,
    y = 2,
    sprite = 1,
    keys = 0
  }
end

function draw_player()
  spr(p.sprite, p.x * 8, p.y * 8)
end
