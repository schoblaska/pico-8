function show_inventory()
  invx = mapx * 8 + 40
  invy = mapy * 8 + 8

  rectfill(invx, invy, invx + 48, invy + 24, 0)
  print("inventory", invx + 7, invy + 4, 7)
  print("keys: " .. p.keys, invx + 12, invy + 14, 9)
end
