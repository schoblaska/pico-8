function make_ground()
  gnd = {}
  local top = 86
  local btm = 120

  pad = {
    width = 15,
    y = rndb(top, btm),
    sprite = 2
  }

  pad.x = rndb(0, 126 - pad.width)

  -- flat ground at landing pad
  for i = pad.x, pad.x + pad.width do
    gnd[i] = pad.y
  end

  -- bumpy ground right of pad
  for i = pad.x + pad.width + 1, 127 do
    local h = rndb(gnd[i - 1] - 3, gnd[i - 1] + 3)
    gnd[i] = mid(top, h, btm)
  end

  -- bumpy ground left of pad
  for i = pad.x - 1, 0, -1 do
    local h = rndb(gnd[i + 1] - 6, gnd[i + 1] + 6)
    gnd[i] = mid(top, h, btm)
  end
end

function draw_ground()
  for i = 0, 127 do
    line(i, gnd[i], i, 127, 5)
  end

  spr(pad.sprite, pad.x, pad.y, 2, 1)

  if (game_over and win) then
    spr(4, pad.x - 3, pad.y - 8)
  end
end
