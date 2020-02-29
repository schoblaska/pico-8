pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- raycaster
-- by thrillhouse

-- [x] untextured raycasting
-- [x] wall textures
-- [x] sprites
-- [x] give treats to dogs
-- [x] method to step through demo (raycasting screen, flat and buggy, flat, textured, sprites)
-- [ ] sort sprites by distance to player
-- [ ] more sprites
-- [ ] map editor
-- [ ] recreate wolf3d 1-1 map
-- [ ] raycasting explanation screen

-- [ ] pick up treats before giving
-- [ ] bottom-of-screen ui
-- [ ] title screen
-- [ ] music
-- [ ] when "wielding" treats, show on bottom of screen and bob when walking
-- [ ] doors (use sprites that don't rotate?)

#include raycaster/rays.p8
#include raycaster/player.p8

function _init()
  world = {
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,2,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,3,0,0,0,3,0,0,0,1},
    {1,0,0,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,2,2,0,2,2,0,0,0,0,3,0,3,0,3,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,3,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,0,0,0,1,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,3,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
    {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
  }

  doggos = {
    {x = 11.5, y = 15.5, spriteY = 0}
  }

  pos = {x = 22, y = 12}
  dir = {x = -1, y = 0}
  plane = {x = 0, y = 0.66}

  rotSpeed = 0.01
  moveSpeed = 0.25
  showInstructions = 150
  useTextures = true
  useSprites = true
  showCPU = true
  givingTreat = false
  treatY = 128
  mode = 0
end

function _update()
  if mode == 0 then
    -- title slide
    if btnp() > 0 then mode += 1 end
  elseif mode == 1 then
    -- buggy flat textures
    if btnp(5) then mode += 1 end

    useTextures = false
    useSprites = false

    update_instructions()
    move()
  elseif mode == 2 then
    -- fixed flat textures
    if btnp(5) then mode += 1 end

    useTextures = false
    useSprites = false

    update_instructions()
    move()
  elseif mode == 3 then
    -- add textures
    if btnp(5) then mode += 1 end

    useTextures = true
    useSprites = false

    update_instructions()
    move()
  elseif mode == 4 then
    -- add sprites
    if btnp(5) then mode += 1 end

    useTextures = true
    useSprites = true

    update_instructions()
    move()
  elseif mode == 5 then
    -- add treats
    useTextures = true
    useSprites = true

    update_instructions()
    move()
    give_treat()
  end
end

function _draw()
  cls()

  if mode == 0 then
    print "raycaster explanation slide" -- placeholder
  elseif mode == 1 then
    draw_rays()
    draw_instructions()
  elseif mode == 2 then
    draw_rays()
    draw_instructions()
  elseif mode == 3 then
    draw_rays()
    draw_instructions()
  elseif mode == 4 then
    draw_rays()
    draw_instructions()
  elseif mode == 5 then
    draw_rays()
    draw_treat()
    draw_instructions()
  end
end

function update_instructions()
  if showInstructions > 0 then showInstructions -= 1 end
end

function draw_instructions()
  if showInstructions > 0 then
    print("hold z to strafe", 1, 1, 6)
  else
    if showCPU then print("cpu: " .. stat(1), 1, 1, 6) end
  end
end

__gfx__
11111555555555155555511111111111111111111111111111111111111111110000000000015000000000000000000000000000000000000000000000000000
55555d76666665566666d15dddd555551111156dddddd11ddddd5115555111110000000000015500000000000000000000000000000000000000000000000000
666d1d666666d156dddd51d666666666ddd515dddddd511d55551156dddddddd0000000000015151000000000000000000000000000000000000000000000000
6ddd1d6dddddd11ddddd51d6ddddddddd55515d5555551155555115d555555550000000000015554500000000000000000000000000000000000000000000000
ddd5156dddddd51555551156dddddddd555111d5555551111111111d555555550000000000111555410000000000000000000000000000000000000000000000
5551156dddddd51515555556ddd55555111111d5555551111111111d555511110000000001511511540000000000000000000000000000000000000000000000
1111156dddddd5156666d15555511111111111d555555111dddd5111111111110000000001111511541000000000000000000000000000000000000000000000
111115d6ddddd51d6ddd5111111111111111115d55555115d5551111111111110000000000551522554000000000000000000000000000000000000000000000
6ddd51d6ddddd51d6ddd515655d66666d555115d55555115d555111d115ddddd0000000000011524514500000000000000000000000000000000000000000000
6d6d515ddddd55156d5551d65d666666d5d5111555551115d511115d15dddddd0000000000005555115550000000000000000000000000000000000000000000
dddd515551111115511111665d6ddddd5555111111111111111111dd15d555550000000000005511155441000000000000000000000510000055000000000000
dddd515d55515ddd666d156d5d6ddddd5555111511111555ddd511d515d5555500000000000555555d5544000000000000000000000141000551000000000000
dddd516666d56666666d1d6d15dddddd555511dddd51ddddddd515d5115555550000000000545455d55544100000000000000000000055555550000000000000
5551116ddd5566ddddd51d6d11111155111111d55511dd55555115d5111111110000000000151555d51544100000000000000000000151555150000000000000
1555556ddd5166ddddd51d6d15551111111111d55511dd55555515d5111111110000000000111155551544100000000000000000000151555550000000000000
d666656ddd5166ddddd51d6d1d66dd555dddd1d55511dd55555115d515dd55110000000000015555551244500000000000000000000545515540000000000000
d6ddd56ddd51d6ddddd51d6d1ddd66555d5551d555115d55555115d51555dd110000000000005555551555500000000000000000000551151550000000000000
d6ddd56ddd5156ddddd51d6d1d6ddd555d5551d555111d55555115d515d555110000000000001455511151000000000000000000000551151140000000000000
d6ddd56ddd5156dd55511555155555515d5551d555111d5551111111111111110000000000001455111145000000000000000000000555111555000000000000
d6ddd5d6dd51155111111555551111115d55515d5511111111111111111111110000000000005451111155000000000000000000001445555544000000000000
d6ddd5d6dd5115555555ddd6666666555d55515d551111111111555ddddddd5100000000000044511111551000000000000000000044455dd544100000000000
d6ddd1d6dd511d6666666776666666515d55515d551115d66d6d6666dddddd1100000000000044511111551000000000000000000044455dd554100000000000
d6dd51d6dd511d66666666dddddddd515d55115d551115dddddddd55555555110000000000004451111155000000000000000000004445555554100000000000
5d55515ddd51156ddddddddddddddd51151111155511156555555555555555110000000000004451111155000000000000000000004445555154100000000000
511111555551156ddddddddddddddd5111111111111111d555555555555555110000000000005451111550000000000000000000005445555144100000000000
5ddd555111111555555ddddddddddd51155511111111111111155555555555110000000000001451101550000000000000000000001445111544100000000000
5666666dddddd55551111111111111151dddddd55555511111111111111111110000000000000245101510000000000000000000000544511444100000000000
56dddd666666666655555111111111551d5555dddddddddd11111111111111110000000000000145105100000000000000000000000544515445000000000000
56dddddddddddddd11d66655dddddd551d55555555555555115ddd11555555110000000000000151005500000000000000000000000544514455000000000000
551111155155111111dddd5d66666655111111111111111111555515ddd5dd110000000000000151001510000000000000000000000551005255000000000000
51111111111111111155111555555515111111111111111111111111111111110000000000000541001550000000000000000000000510000015000000000000
55555511111111111115111111111115111111111111111111111111111111110000000000000451001445000000000000000000004500000005100000000000
511111111115111ccc1cccccc1511111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
1ccccc1c11111c1111c1111cc11cccc1511111111115111111111111111111150000000000000000000000000000000000000000000000000000000000000000
1c1c11111111111111111111111ccc15511111111115111111111555551111150000000000000000000000000000000000000000000000000000000000000000
1ccc11c11111ccccccccc111111cc115511111111115111111111111111111150000000000000000000000000000000000000000000000000000000000000000
1ccc111111111ccccc11c11c111ccc15511111111115111111111511111111150000000000000000000000000000000000000000000000000000000000000000
1c11111111151ccccc11111c111c1115511111111115111111111511111111150000000000000000000000000000000000000000000000000000000000000000
1c11111111111cccc111111c11111115511111111115111111111511111111150000000000000000000000000000000000000000000000000000000000000000
5111111111151c1c1111151c11111115511115555555111111111511115555550000000000000000000000000000000000000000000000000000000000000000
1111111111111cccc111151c11111111111111111111111111111511115111110000000000000000000000000000000000000000000000000000000000000000
cccc1c111cc11ccc11111511111c11cc111111111111111111111511111111110000000000000000880880000000000000880880000000000000000000000000
ccc111111c11111111111511111111cc111111111111111155555511555151110000000000000000888880000000000000888880000000000000000000000000
c1c111111111111111111111111111cc111111111111111111111115111111110000000000000000088800000000000000088800000000000000000000000000
c1c1111111111ccccccccc111ccc11cc111111111115111111111115111151110000000000000000008000000000000000008000000000000000000000000000
c1cc111111151cccccc111111cc111cc111111111555111111111115111151110000000014104500000000000000000000000000141045000000000000000000
cccc111111111cccccc111111cc111cc111111151111111111111115111151110000000045145100000000000000000000000000451451000000000000000000
c11111111cc11cccc1c111151cc111c1111111151111111111111115111151110000000055155000000000000000000000000000551550000088088000000000
cc1111111c111c1c111111151cc11111111111151115111111111115111151110000000111545500000000000000000000000001115455000088888000000000
111111111c111cc1111111151c1111cc111111151115111111111115111151110000011151544450000000000000000000000111515444500008880000000000
111111111c111111111155551c1111c1111111151111111555555555111151110000115544444440000000000000000000001155444444400000800000000000
111111151c111111111111111c115111111115151115111111111111111151110000115555544440000000000000000000001155555444400000000000000000
111111111c111cccccccccc11cc151155551111111151111111111151111511500001555d5554440000000000000000000001555d55544400000000000000000
1cccccc11c111cccc11111111c115115111111111111111111111115111151150000015155544441000000000000000000000151555444410000000000000000
1cccccc111151ccccc11111111115115111111115155111111111115111151150000001555444445111111555500000000000015554444451111115555000000
1cccccc111111ccccc11111111111115111111111111111111111115551111150000000555544445515514444450000000000005555444455155144444500000
1cccc1c11cc11ccccc1111111cccccc1111111111111111111111115111111150000000555544554455554444445000000000005555445544555544444450000
1cccc1111cc11cccccc111111ccccc15111111111111111111111115111111150000000555555544445554444455550000000005555555444455544444555500
1cccc1111cc11cc1111111151ccc1115111111111111111111111115111111150000000555554444555544445410010000000005555544445555444454100100
1cc1c1111cc11ccc1111c1151ccc1115111111111111111111111115111111150000000555544444444544445410000000000005555444444445444454100000
1cc11c111c111cc1c11111151ccc1115111111111111111111111115111111150005454555444444444544444400000000054545554444444445444444000000
1c1111111c111ccc111111151cc11115111111111115111111111115111111150054554444444444455444444500000000545544444444444554444445000000
1c11111111111cc1111111111c1111111111111111111111111111111111111500455444444450005d4444445100000000455444444450005d44444451000000
11111111111111111111111111111115511111155115511111111115511111110000444500000000010000000000000000004445000000000100000000000000
11111111111115511111515111111111111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
24444425444444444425444444444425122222112222222222112222222222210000000000000000000000000000000000000000000000000000000000000000
24222215422222222215422222422221122222112222222222112222222222510000000000000000000059940000000000000000000000000000000000000000
24222215422222222215222222222221122255112252555555112555525225110000000000000000000599994000000000000000000000000000000000000000
52222215222222222215222222222221125511112551111111115111151555110000000000000000005944999400000000000000000000000000000000000000
51111115511111111115515511111111111111111111111111111111111111110000000000000000005944999400000000000000000000000000000000000000
44222222524444444242444444554444222222221222222222222222221122220000000000000000005999999400000000000000000000000000000000000000
22222222122222222222222222154222225555211522255555525522251122220000000000000000059999444949400000000000000000000000000000000000
22222222122222222222222222154222221111211122511121151115211122250000000000000000599449944999940000000000000000000000000000000000
22122221122222222222222222152222551111551155111111111111111155510000000000000005994549999999994000000000000000000000000000000000
11111111555111151111111111551111111111111111111111111111111111110000000000000049945494499944999000000000000000000000000000000000
28444424444242544444442222422225122222222222211222222222222222210000000000000499945444454999994000000000000000000000000000000000
24222222222222144222222222222221122552225525211222552555522522510000000000004999944999454999945000000000000000000000000000000000
22222222222222142222222222222221125115521151511225115111155255110000000000049999994494549944410000000000000000000000000000000000
52222222222221122222222222222221121111151111111551111111111111110000000000499945499455499415100000000000000000000000000000000000
55511115555111555155115551151551151111111111111111111111111111110000000004444454549999994000000000000000000000000000000000000000
44444254444242242242544444422222222221122222222222211222222222220000000049999454945499440000000000000000000000000000000000000000
22222152222222222222542222222222222221125255255555211225522552550000000499999944945494400000000000000000000000000000000000000000
22222152222222222222542222222222252211121111211111211222222222110000494994554994544994000000000000000000000000000000000000000000
12121152222222122221122222222222115511151111511111511555555555110004999945445494499940000000000000000000000000000000000000000000
55555155115551151155555555515551111111111111111111111111111111110049999942499449994400000000000000000000000000000000000000000000
24444222224224225442222222222221122222222222222112222222222222210099944994499449944000000000000000000000000000000000000000000000
22222222222222211222222222222221125555555555555112255555555555510044999999444444940000000000000000000000000000000000000000000000
24222222222222221422222222222221125152251111525112211111112221110054994449944944400000000000000000000000000000000000000000000000
52222222111111211222222221211211151115511111151115511111115551110001444499999944000000000000000000000000000000000000000000000000
55555555515215555555555555511555111111111111111111111111111111110000151444449440000000000000000000000000000000000000000000000000
42422422212842242242222154222222222222221122222222222211122222210000000444944940000000000000000000000000000000000000000000000000
22222222212222222222222152222222255555551152555555555511125555510000000499999450000000000000000000000000000000000000000000000000
22222222212222222222222152222222511111521155111111111111121111120000000044994500000000000000000000000000000000000000000000000000
22222222212222222222222152222222111111151111111111111111151111150000000004445000000000000000000000000000000000000000000000000000
11111111115111111111111151111111111111111111111111111111111111110000000000550000000000000000000000000000000000000000000000000000
55555555555555555555555555555555111111111111111111111111111111110000000000000000000000000000000000000000000000000000000000000000
