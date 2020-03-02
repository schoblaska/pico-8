-- to use: load src/util/compressor.p8
-- import 128x128 image into compressor and run
-- compressor will convert image to str and put into clipboard
-- in game code: include decompressor and store image string in variable
-- call init_compressor_mem() in _init()
-- to load string into graphics memory: str2mem(rld(image_str), 0)
-- to draw graphics memory onto screen: sspr(0,0,128,128,0,0)
-- to reset graphics memory: reload(0,0,8192)

function init_decompressor()
 chars="!#$%&'()*+,-/0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[]^_`{|}~"
 if #chars < 64 then error("this won't work") end
 s2c={}
 c2s={}

 for i=1,#chars do
  s = sub(chars, i, i)
  c2s[i] = s
  s2c[s] = i
 end
end

function rld(t)
  local r = ""
  local i = 1
  while i <= #t do
    -- get the next char
    local char = sub(t,i,i)

    if char == "." then
      local count = getval(sub(t,i+1,i+1))
      local val = sub(t,i+2,i+2)
      for i=1,count do
        r = r..val
      end
      i += 3
    else
      r = r..char
      i += 1
    end
  end

  return r
end

function str2mem(s,m)
  local i = 1
  local rem = #s

  while rem > 0 do
    local w = getval(sub(s,i,i))
    local x = 0
    if rem > 1 then x = getval(sub(s,i+1,i+1)) end
    local y = 0
    if rem > 2 then y = getval(sub(s,i+2,i+2)) end
    local z = 0
    if rem > 3 then z = getval(sub(s,i+3,i+3)) end
    -- a = (w << 2) | (x & 0x30) >> 4)
    local a = bor(shl(band(w, 0x3f),2), lshr(band(x, 0x30),4))
    -- b = ((x & 0xf) << 4) | ((y & 0x3c) >> 2)
    local b = bor(shl(band(x, 0xf), 4), lshr(band(y, 0x3c),2))
    -- c = ((y & 0x3) << 6) | z
    local c = bor(shl(band(y, 0x3), 6), z)
    poke(m, a)
    if rem > 0 then poke(m+1, b) end
    if rem > 1 then poke(m+2, c) end
    m += 3
    i += 4
    rem -= 4
  end
end

function getval(s)
	return s2c[s]-1
end
