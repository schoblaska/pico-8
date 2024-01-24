pico-8 cartridge // http://www.pico-8.com
version 41
__lua__

-- kaido - by schoblaska
-- music by gruber <3

-- flags
-- 0: tumbles (like a leaf)
-- 1: sways (like grass)
-- 2: overhangs (like a branch)
-- 3: blocks (like a wall)
-- 4: grows (in grass)
-- 5: decorates path
-- 6: gusts (like wind)

function _init()
  sprites = {
    gust = 41,
    path = 32,
    grass = 16,
    leaves = {
      { x = 8, y = 8 },
      { x = 16, y = 8 },
      { x = 24, y = 8 },
      { x = 32, y = 8 }
    },
    player = 57
  }

  -- higher = slower wind
  windspeed = 50
  -- higher = fewer leaves
  leafspawn = 150
  -- higher = slower
  leafrot = 50
  -- higher = slower
  leafspeed = 50

  player = {
    x = 8,
    y = 8,
    flip = false
  }

  gusts = {
    {
      offset = 0,
      speed = 2,
      mapx = 1
    },
    {
      offset = 0,
      speed = 10,
      mapx = 2
    }
  }

  leaves = {}

  for x = 0, 15 do
    for y = 0, 15 do
      if not fget(mget(x, y), 3) and rnd(leafspawn / 6) < 1 then
        add(
          leaves, {
            x = x,
            y = y,
            sprite = sprites.leaves[flr(rnd(#sprites.leaves)) + 1],
            rotation = 0
          }
        )
      end
    end
  end
end

function _update60()
  for gust in all(gusts) do
    if rnd(windspeed) < gust.speed then
      gust.offset += 1
    end
  end

  if btnp(0) and player_can_move_to(player.x - 1, player.y) then
    player.x -= 1
    player.flip = true
  elseif btnp(1) and player_can_move_to(player.x + 1, player.y) then
    player.x += 1
    player.flip = false
  elseif btnp(2) and player_can_move_to(player.x, player.y - 1) then
    player.y -= 1
  elseif btnp(3) and player_can_move_to(player.x, player.y + 1) then
    player.y += 1
  end

  spawn_leaves()
  update_leaves()
end

function _draw()
  for y = 0, 15 do
    for x = 0, 15 do
      local sprite = mget(x, y)

      if fget(sprite, 5) then
        spr(sprites.path, x * 8, y * 8)
      end

      if fget(sprite, 4) then
        spr(sprites.grass, x * 8, y * 8)
      end

      if fget(sprite, 1) and is_gusting(x, y) then
        spr(sprite + 1, x * 8, y * 8)
      else
        spr(sprite, x * 8, y * 8)
      end
    end
  end

  for leaf in all(leaves) do
    sspr(
      leaf.sprite.x,
      leaf.sprite.y,
      8,
      8,
      leaf.x * 8,
      leaf.y * 8,
      8,
      8,
      leaf.rotation == 90 or leaf.rotation == 270,
      leaf.rotation == 180 or leaf.rotation == 270
    )
  end

  for y = 0, 15 do
    for x = 0, 15 do
      local sprite = mget(x, y)

      if player.x == x and player.y == y then
        palt(0, false)
        palt(11, true)

        if is_gusting(x, y) then
          spr(sprites.player + 1, x * 8, y * 8, 1, 1, player.flip)
        else
          spr(sprites.player, x * 8, y * 8, 1, 1, player.flip)
        end

        palt()
      end

      if fget(sprite, 2) then
        if fget(sprite, 1) and is_gusting(x, y) then
          spr(sprite + 1, x * 8, y * 8)
        else
          spr(sprite, x * 8, y * 8)
        end
      end
    end
  end
end

function spawn_leaves()
  if rnd(leafspawn) < 1 then
    local x = 15
    local y = flr(rnd(16))

    if not leaf_at(x, y) then
      add(
        leaves, {
          x = x,
          y = y,
          sprite = sprites.leaves[flr(rnd(#sprites.leaves)) + 1],
          rotation = 0
        }
      )
    end
  end
end

function update_leaves()
  for leaf in all(leaves) do
    if leaf.x < 0 then
      del(leaves, leaf)
    elseif is_gusting(leaf.x, leaf.y) then
      if rnd(leafrot) < 1 then
        leaf.rotation = (leaf.rotation - 90) % 360
      end

      if rnd(leafspeed) < 1 then
        if leaf_can_move_to(leaf.x - 1, leaf.y) then
          leaf.x -= 1
        elseif leaf_can_move_to(leaf.x - 1, leaf.y - 1) then
          leaf.x -= 1
          leaf.y -= 1
        elseif leaf_can_move_to(leaf.x - 1, leaf.y + 1) then
          leaf.x -= 1
          leaf.y += 1
        end
      end
    end
  end
end

function leaf_can_move_to(x, y)
  if x < 0 then
    return true
  elseif fget(mget(x, y), 3) then
    return false
  elseif leaf_at(x, y) then
    return false
  elseif player.x == x and player.y == y then
    return false
  else
    return true
  end
end

function player_can_move_to(x, y)
  if x < 0 or x > 15 or y < 0 or y > 15 then
    return false
  elseif fget(mget(x, y), 3) then
    return false
  else
    return true
  end
end

function is_gusting(x, y)
  for gust in all(gusts) do
    local mapx = gust.mapx * 16 + (gust.offset + x) % 16

    if mget(mapx, y) == sprites.gust then
      return true
    end
  end

  return false
end

function leaf_at(x, y)
  for leaf in all(leaves) do
    if leaf.x == x and leaf.y == y then
      return true
    end
  end

  return false
end

__gfx__
00000000333333333333333333333333333333333333333333333333333312553333125511333333113333330000000000000000000000000000000000000000
00000000333333b333333b3333343333334333333333333333333333333112dd333112ddd5551533d55515330000000000000000b0000000b000000000000000
00700700333333b3333333b333333333333333333333333333333333331112dd331112dd1d1111331d1111330000000b0000000bb0000000b000000000000000
00077000333333b3333333b333333a9333333a933333b333333b333333111ddd33111ddd111d1233111d1233000000bb000000bb1b0000000000000000000000
000770003bb33333bb33333339933a933933a9333333b3333333b3333311121d3311121d11dd223311dd223300000bbb00000bbbbbb00000bbb0000000000000
0070070033b3333333b3333333aa3a3339a33a3333333333333333333313111d3318111d18d112331cd112330000bb1b0000b1bbbbbb0000bbbb000000000000
00000000333333333333333333933333399333333333333333333333331111dd331111dd3dd112333dd11233000bb15b000b115bbd1bb000d1bbb00000000000
0000000033333333333333333333333333333333333333333333333331111ddd31111ddd1dd112331dd1123300000bdb00000bdb4bdb00004bdb000000000000
3333333300000000000000000000000000000000333333333333333331111ddd31111ddd1111113311111133000bb1bb000bb1bbbbb10000bbb1000000000000
333333330000000000002000000000000000000033333333333333333351d5d13351d5d1113d1133113d113300bbb0bb00bb00bbbbbbb000bbbbb00000000000
33333333000000000002290000000000004000003333c333333c33333311151d3311151d1d1111531d1111530000bbbb0000bbbbb4b00000b400000000000000
33333333004800000022900000090900000488003333c3333333c3333b11d15dbb11d15d11db115311b11153000bbb1b000bbb1bb05bb000005bb00000000000
33333333004900000029000000888800000480003333b3333333b3333511bd5d351bdd5dd11bd11bd11bd1bb0000b1db000011dbbbbb0b00bbb00b0000000000
33333333009400000000000000909000000400003333333333333333bd1db55dbd1db55ddd11d513dd11d513000bbbb400bbbbb450bbb00050bbb00000000000
33333333000000000000000000000000000000003333333333333333d1b555b5db5555b55b1d5db15b1d5bb100b0bbbd0bb0bbbdbb0bbb00bb0bbb0000000000
3333333300000000000000000000000000000000333333333333333333b3113333b31133133b1333133b133300000bb100000bb1bb110000bb10000000000000
1111111133333333333333333333333333333333333c333333c3333311111111111111110070000000000000333bbbb4333bbbb440b1b33340b1b33300000000
111111110303333030333303300300330030033000330030033003001111111111111111070000000000000033bbb1bb3bbb11bbbb0bbb33bb0bbb3300000000
111111110000030000003000000000000000000000000000000000001115111111111511070000000000000033b33bb033b33bb0ddd33b33ddd3b33300000000
11111111000000000000000000000000000000000000000000000000111111111111111100777700000000003333bb343333bb444bb333334bb3333300000000
11111111000000000000000000000000000000000000000000000000151111111121111100000000000000003333b334333bb33443bbb33343bb333300000000
11111111000000000000000000000000000000000000000000000000111111111111111100777700000000003333333433333334433333334333333300000000
11111111000000000000000000000000000000000000000000000000111111511111111107000000000000003333334d3333334d433333334333333300000000
11111111000000000000000000000000000000000000000000000000111111111111111100770000000000003333342233333422d4333333d433333300000000
000000000000000000000000000000000000000000000000000000001111111111115111bbb9cbbbbb99cbbb0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001111121111111111bbddddbbbdddddbb0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001111111111111111bccccccbbccccccb0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001111111111111111bbfff5bbbbff55bb0000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000001111111111111111bbffffbbbfffffbb0000000000000000000000000000000000000000
000000000000000000000000000000000000000000003000000300001115111111111111bccccccbbccccccb0000000000000000000000000000000000000000
000000000003300300330033303000030300003330303000030300001111111115111111bbddddbbbbddddbb0000000000000000000000000000000000000000
000000003333333333333333333333333333333333333333333333331111111111111111b00bb00bb00b000b0000000000000000000000000000000000000000
33333333333333333332333333323333333363333336333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333322233333222333333633333333633300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333222223332222233333363333336333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333332211222322112233333663333336633300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333332333333322212112221122223335553333355533300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333322333333222211122222111222235153332351533300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333222333332222222222222222222225153332111533300000000000000000000000000000000000000000000000000000000000000000000000000000000
33332224333322244444449944444499922553339223333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33322299332222994444444444444444422253334222533300000000000000000000000000000000000000000000000000000000000000000000000000000000
33322499333229999994334999943999999223339292333300000000000000000000000000000000000000000000000000000000000000000000000000000000
33224434322243344444444444444444444422334424223300000000000000000000000000000000000000000000000000000000000000000000000000000000
32249444322494444444422244444222434992233399222300000000000000000000000000000000000000000000000000000000000000000000000000000000
22449499224999999444222294442222443444224334452200000000000000000000000000000000000000000000000000000000000000000000000000000000
2244446a2244466a46a4222266a22222444444534444455300000000000000000000000000000000000000000000000000000000000000000000000000000000
255444aa2554446a5aa5225256a52252555555335555553300000000000000000000000000000000000000000000000000000000000000000000000000000000
355555aa355555aa5aa522225aa52222551511535511115300000000000000000000000000000000000000000000000000000000000000000000000000000000
35555111355551111535222213322222551b555351bb555300000000000000000000000000000000000000000000000000000000000000000000000000000000
3551555535515555555522225555222255555b535555bb5300000000000000000000000000000000000000000000000000000000000000000000000000000000
355153353551333bb5555555b5555555553555535335555300000000000000000000000000000000000000000000000000000000000000000000000000000000
35511115355111155533111153331111555511515551115100000000000000000000000000000000000000000000000000000000000000000000000000000000
35555555355555555555555555555555555555135555551300000000000000000000000000000000000000000000000000000000000000000000000000000000
31555555315555555535111153311111551555135515551300000000000000000000000000000000000000000000000000000000000000000000000000000000
31111111311111111111311111113111311111333111113300000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333333333333333333333333333333333333300000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
001200120012000a000a001600160000000101010112000a000a00161616160000220022002200202040001a001a0000002200220022002020020000000000000a0008000a000000000000000000000008000a000800000000000000000000000a0008000800000000000000000000000a0a0a0a000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010100510101010051000000000000029290029000000000000000000000000000000000029000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1015011015151003100b0d030110101000000000000029002929000000000000000000000000000000002929000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1005051010101010101b1d101005151000000000002929002900000000000000000000000000002929290000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010104042441010012b2d021010101000000000002900002900000000000000000000000000002900000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1510035052541010031010102123252100000000002900002900000000000000000000000000292900000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010106062641005101025232020382000000000292900002900000000000000000000000029290000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2125051010100510212320282720202000000000290000292900000000000000000000000029000000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020252110151021202020202020313300000000290000290000000000000000000000002929000000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2028203721212127203833353135101000000000290000290000000000000000000000002900000000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3138202020372020203110151010101500000000002900290000000000000000000000002929290000000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1035202720202831350510101001101000000000002900002900000000000000000000000000292900000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010313535333110101010070910010100000000002900002900000000000000000000000000002929000000000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1003101510101003101510171910050300000000002929002929000000000000000000000000000029292900000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1005011010151005101010101010101000000000000029290029000000000000000000000000000000002929000000001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010100105101010051001100110050500000000000000290029290000000000000000000000000000000029292900001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0510101010101510101010101010101000000000000000290000290000000000000000000000000000000000002929001010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
