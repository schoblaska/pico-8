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

function move_player()
  newx = p.x
  newy = p.y

  if (btnp(0)) newx -= 1
  if (btnp(1)) newx += 1
  if (btnp(2)) newy -= 1
  if (btnp(3)) newy += 1

  interact(newx, newy)

  if (can_move(newx, newy)) then
    p.x = mid(0, newx, 127)
    p.y = mid(0, newy, 63)
  else
    sfx(0)
  end
end

function interact(x, y)
  if (is_tile(key, x, y)) then
    get_key(x, y)
  elseif (is_tile(door, x, y) and p.keys > 0) then
    open_door(x, y)
  end
end
