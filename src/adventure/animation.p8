function toggle_tiles()
  for x = mapx, mapx + 15 do
    for y = mapy, mapy + 15 do
      if is_tile(anim1, x, y) then
        swap_tile(x, y)
        sfx(3)
      elseif is_tile(anim2, x, y) then
        unswap_tile(x, y)
      end
    end
  end
end
