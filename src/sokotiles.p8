pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- sokotiles
-- by schoblaska

#include sokotiles/sprites.lua
#include sokotiles/draw.lua
#include sokotiles/gamelogic.lua

function _init()
  board = {
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", "y", "." },
    { ".", ".", ".", ".", ".", ".", ".", "y", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", "g", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", "b", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", ".", "w", "." },
    { ".", ".", ".", ".", ".", ".", ".", ".", "." }
  }

  pieces = {
    { ".", ".", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", "G", "E", "E", "E", ".", ".", "." },
    { ".", ".", ".", ".", ".", ".", "W", ".", "." },
    { "E", "E", "E", ".", ".", ".", "E", "Y", "." },
    { ".", "E", ".", "P", ".", ".", ".", "B", "." },
    { ".", ".", "B", ".", ".", "Y", ".", "Y", "." },
    { ".", "E", ".", ".", ".", ".", ".", ".", "." },
    { ".", ".", ".", "E", ".", ".", ".", ".", "E" },
    { ".", ".", ".", ".", ".", ".", ".", ".", "E" }
  }

  set_scene("title")
end

function _update()
  if scene == "title" then
    if btnp(2) and title_menu_selection > 0 then
      title_menu_selection -= 1
    elseif btnp(3) and title_menu_selection < 1 then
      title_menu_selection += 1
    elseif btnp(4) and title_menu_selection == 0 then
      set_scene("game")
    end
  elseif scene == "game" then
    px, py = find_player()

    if btnp(0) then
      move_if_able(px, py, -1, 0, false, false)
    elseif btnp(1) then
      move_if_able(px, py, 1, 0, false, false)
    elseif btnp(2) then
      move_if_able(px, py, 0, -1, false, false)
    elseif btnp(3) then
      move_if_able(px, py, 0, 1, false, false)
    elseif btnp(5) and not is_won() then
      _init()
    end
  end
end

function _draw()
  cls()

  if scene == "title" then
    draw_title()
  elseif scene == "game" then
    draw_game()
  end
end

-- TODO: not necessary?
function set_scene(new_scene)
  if new_scene == "title" then
    title_menu_selection = 0
  end

  scene = new_scene
end

-- TODO: store this in a variable when loading level
function find_player()
  for y = 1, 9 do
    for x = 1, 9 do
      if pieces[y][x] == "W" then
        return x, y
      end
    end
  end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000d666666666dd666666666dd666666666d0000000000000000000000d666666666dd666666666d00000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd500000000000000000000006ddd777ddd56ddddbdddd500000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56dddd5dddd500000000000000000000006dddd7dddd56dddbbbddd500000000000000000000000000000000000
00000000000000006dd55755dd56dd55b55dd56dd55555dd500000000000000000000006dd66766dd56dd33b33dd500000000000000000000000000000000000
000000000000000067d50005d756db50005bd56dc50005cd50000bbb00000000ccc000067d60006d756db30003bd500000000000000000000000000000000000
0000000000000000677700077756bbb000bbb56ccc000ccc50000bbb00000000ccc0000677700077756bbb000bbb500000000000000000000000000000000000
000000000000000067d50005d756db50005bd56dc50005cd50000bbb00000000ccc000067d60006d756db30003bd500000000000000000000000000000000000
00000000000000006dd55755dd56dd55b55dd56dd55555dd500000000000000000000006dd66766dd56dd33b33dd500000000000000000000000000000000000
00000000000000006dddd7dddd56dddbbbddd56dddd5dddd500000000000000000000006dddd7dddd56dddbbbddd500000000000000000000000000000000000
00000000000000006ddd777ddd56ddddbdddd56ddddddddd500000000000000000000006ddd777ddd56ddddbdddd500000000000000000000000000000000000
0000000000000000d5555555551d5555555551d55555555500000000000000000000000d5555555551d555555555100000000000000000000000000000000000
0000000000000000d666666666dd666666666d0000000000000000000000d666666666dd666666666dd666666666d00000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006ddd555ddd56ddddddddd56ddddadddd500000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd500000000000000000000006dddd5dddd56dddd1dddd56dddaaaddd500000000000000000000000000000000000
00000000000000006ddddddddd56dd55a55dd500000000000000000000006dddd5dddd56dd11111dd56dd99a99dd500000000000000000000000000000000000
00000000000000006ddddddddd56dd50005dd5000077700000000aaa000065dd000dd556dc10001cd56dd90009dd500000000000000000000000000000000000
00000000000000006ddddddddd56d5500055d5000077700000000aaa0000655500055556ccc000ccc56d9900099d500000000000000000000000000000000000
00000000000000006ddddddddd56dd50005dd5000077700000000aaa000065dd000dd556dc10001cd56dd90009dd500000000000000000000000000000000000
00000000000000006ddddddddd56dd55a55dd500000000000000000000006dddd5dddd56dd11111dd56dd99a99dd500000000000000000000000000000000000
00000000000000006ddddddddd56dddaaaddd500000000000000000000006dddd5dddd56dddd1dddd56dddaaaddd500000000000000000000000000000000000
00000000000000006ddddddddd56ddddadddd500000000000000000000006ddd555ddd56ddddddddd56ddddadddd500000000000000000000000000000000000
0000000000000000d5555555551d55555555500000000000000000000000d5555555550d5555555550d555555555000000000000000000000000000000000000
