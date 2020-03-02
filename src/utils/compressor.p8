pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--image embed helpers
-- by jasper
-- based on compressed image cart by dw817 
-- rewritten for speed and simplicity

function init_mem()
 chars="!#$%&'()*+,-/0123456789:;<=>?@abcdefghijklmnopqrstuvwxyz[]^_`{|}~"
 if #chars < 64 then
  print("this won't work")
 end
 s2c={}
 c2s={}
 for i=1,#chars do
  s=sub(chars,i,i)
  c2s[i]=s
  s2c[s]=i
 end
end

function getchar(x)
	return c2s[x+1]
end

function getval(s)
	return s2c[s]-1
end

-- shift every 3 bytes into 4
-- characters (6-bit each)
-- char table needs 2^6 values
function mem2str(m,l)
	local r = ""
	local rem = l+m
	while rem > 0 do
	 local a = peek(m)
	 local b = 0
	 if(rem > 1) b = peek(m+1)
	 local c = 0 
	 if(rem > 2) c = peek(m+2)
	 -- w = a>>2
	 local w = lshr(band(a, 0xfc), 2)
		-- x = (a & 0x3)<<4)|(b>>4)
		local x = bor(shl(band(a, 0x3),4), lshr(band(b, 0xf0),4))
	 -- y = (b & 0xf)<<2)|(c>>6)
	 local y = bor(shl(band(b, 0xf),2), lshr(band(c, 0xc0),6))
		-- z = c & 0x3f
	 local z = band(c, 0x3f)

		r = r..getchar(w)
	 r = r..getchar(x)
	 if(rem > 1) r = r..getchar(y)
	 if(rem > 2) r = r..getchar(z)
	 m += 3
	 rem -= 3
	end
	
	return r
end


-- shift every 4 characters into
-- 3 bytes of data
function str2mem(s,m)
 local i = 1
 local rem = #s
 
 while rem > 0 do
  local w = getval(sub(s,i,i))
  local x = 0
  if(rem > 1) x = getval(sub(s,i+1,i+1))
  local y = 0
  if(rem > 2) y = getval(sub(s,i+2,i+2))
  local z = 0
  if(rem > 3) z = getval(sub(s,i+3,i+3))
  -- a = (w << 2) | (x & 0x30) >> 4)
  local a = bor(shl(band(w, 0x3f),2), lshr(band(x, 0x30),4))
  -- b = ((x & 0xf) << 4) | ((y & 0x3c) >> 2)
  local b = bor(shl(band(x, 0xf), 4), lshr(band(y, 0x3c),2))
  -- c = ((y & 0x3) << 6) | z
  local c = bor(shl(band(y, 0x3), 6), z)
  poke(m, a)
  if(rem > 0) poke(m+1, b)
  if(rem > 1) poke(m+2, c)
  m += 3
  i += 4
  rem -= 4
 end
end
-->8
-- run length encoding
-- takes a string and replaces
-- repeating characters with
-- ".(count)(char)" ie.
-- abccccccccdef
-- will be something like 
-- ab.8cdef

function rle(t)
local r = ""
local char = ""
local last_char = ""
local rep_count = 1
 for i=1,#t do
 	--get next letter
 	local char = sub(t,i,i)
 	if i == #t then
 	 for j=1,rep_count do
 	  r = r..last_char
 	 end
			r = r..char
 	elseif char == last_char and
 	   rep_count < #chars-1 and
 	   i < #t then
 	 rep_count += 1
 	else
 	 -- the rle looks like .3e
 	 -- so we need to have 4 or more repeating
 	 -- characters or its not worth it
 	 if rep_count > 3 then
 	 	-- use the char table for the count
 	 	--  instead of just a digit
 	 	r = r.."."..getchar(rep_count)..last_char
 	 else
 	  for j=1,rep_count do
 	   r = r..last_char
 	  end
 	 end
 	 rep_count = 1
 	end
 	
 	
 	last_char = char
 end
 return r
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
-->8
-- test script
size_to_save = 8192

--setup
cls()
init_mem()

-- draw the original spritesheet
sspr(0,0,128,128,0,0)

-- grab all of memory
mem_str = mem2str(0, size_to_save)

mem_str = rle(mem_str)
-- run length encode it to the clipboard
printh(mem_str,"@clip", true)


print("compressed to clipboard")
print("press ❎ to uncompress and view")

-- wait for user
while not btnp(❎) do
 flip()
end

-- unpack the data,write it to 
-- memory and draw it
cls()
local output = rld(mem_str)
str2mem(output, 0)
sspr(0,0,128,128,0,0)

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000004440000000000000000000000000000000050000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000054ff4f9400000000000000000100000000000051000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000005ff944444420000000000000005000000000000d1000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000fff44400004000000000000001500000000000065000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004ff444000000200000000000005d0000000000006d000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000047e420000000000000000000005d0000000000016d000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ff440000000000000000000000dd00000000000d6d000000000000000000000000
000000000000000000000000000000000000000000000000000000000000009f4000000000000000000000006600000000015676000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ee4000000000000000000000006d0000000005d776000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000e9400000000000000000000000650000005d51d576000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000049400000000000000000000000d0000000d5111566000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000442000000000000000000000000000110005d515d100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000029200000000000000000000000000055015105000500000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000001000010500d00000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000550500000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd1001d7d0100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010016dd5d67750500000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d666777651100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015555551510000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014dd551500000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046ff777d51500000000000000000000000
000000000000000000000000000000000000000000000000000000000000100000000000000000000000000002404e6777777d11500000000000000000000000
000000000000000000000000000000000000000000000000000000000000100000000000000000000000000009424455d9777d51500000000000000000000000
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000944efff64f774d1d00000000000000000000000
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000999421499f774d1500000000000000000000000
000000000000000000000000000000000000000000000000000000000011100000000000000000000000000004a444777777ed60500000000000000000000000
00000000000000000000000000000000000000000000000000000000011310000000000000000000000000000299444ffff456d0500000000000000000000000
0000000000000000000000000000000000000000000000000000000001c10000000000000000000000000000000500005500d651000000000000000000000000
0000000000000000000000000000000000000000000000000000000003cc10000000000000000000000000000000000000015055000000000000000000000000
000000000000000000000000000000000000000000000000000000000cc100000000000000000000000000001000001001115155100000000000000000000000
000000000000000000000000000000000000000000000000000000000c1100000000000000000000000000000000000d6ddd1d55100000000000000000000000
000000000000000000000000000000000000000000000000000000001cc1000100000000000000000000000000051000d7651655100000000000000000000000
000000000000000000000000000000000000000000000000000000003cc10011000000000000000000000000000150000d501655500000000000000000000000
000000000000000000000000000000000000000000000000000000000cc100110000000000000000000000010000dd0000001d55d00000000000000000000000
000000000000000000000000000000000000000000000000000000001110001100000000000000000000001100005d1000005d55510000000000000000000000
000000000000000000000000000000000000000000000000000000001100001100000000000000000000051000015510000055d5151000000000000000000000
00000000000000000000000000000000000000000000000000000000110000100000000000001155510000000005550000001555111100000000000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000005100000000000000510000000015d666dd5511000000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000000015d55500000001000000000005d511100000500000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000000055d6d550000000000000000005515666dd501dd500000000000
000000000000000000000000000000000000000000000000000000001100001000000000000000001566d10100544999994400000d1000111156665000000000
0000000000000000000000000000000000000000000000000000000111000010000000000000000000005100044299404942450051000000055d666100000000
00000000000000000000000000000000000000000000000000000011110000100000000000000000000000105500492049400d00100000005665d6dd00000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000015040000000000000500000110066765d5500000000
000000000000000000000000000000000000000000000000000000111100001000000000000000000000000045920000000490d0101dd0055d76d11500000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000000044949500044994500d56500dd567615051000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000000004f99450599944001d66501661d6610015000000
0000000000000000000000000000000000000000000000000000001011000010000100000000000000000000004ef994999450005d765d6d650dd50001000000
000000000000000000000000000000000000000000000000000000101100001000110000000000000000000000005555550000056576d6d55d01d51001000000
0000000000000000000000000000000000000000000000000000001011000010001100000013110000000000000005000000000d65766d5005d0150000100000
000000000000000000000000000000000000000001000100000000101100001000110000000cc000000000000000000000000005d166550000d1011000100000
0000000000000000000000000000000000000000010101010000001011000010001100000011c000000000000000000000000000056655100005001000000000
000000000000000000000000000000000000000001110111000000101100001000100000001cc00000000000000000000000000005d510000001500000100000
00000000000000000000000000000000000000000011010000000010111000000010000000c11000000000000000000000000000055d11000000500000000000
0000000000000000000000000000000000000000011111010100001003c000100010000003cc1000000000000000000000000000051d50000000000000000000
001000000000000000000000000000100000000001101000010100100cc10010001000011c331010000000100010000000000000010510000000010000000000
0110000000000000000000000000011000000000011010000111001016d300000010001100000010000001100110000000000000000101000000001000000000
00110000010000000000111000000110000000000000101001100010000000000010001113c10000000001000010000001000000000001000000000001000000
d1110010011000000000101000000110001000001110000001100010000000000010001111100000001011001110001001100000010011010000001001100000
111010100c100000000010100000011010100010110000000110001001000000001000111110000010101100010010100c100000010110000000101001100000
0110d010010100100000101000000101100001101000010001010010010000000010001010100011100001000100100001010010011110000000100001000000
11010011011001100000100000001101001113c110000010110110100100010013c1000010d00011101010101101001001100110010010100000001001000110
110dd111111001500010100001001001d111111010000000110d0110010033101110001010000111010000001001111011100150110100000000111011000110
10011110311001101010000001011001111011100000011010010510010011101110001010000311000000001001010031100110100000000000010011000110
10000100050001011100010001110000010010100000010010000100010011111010000011000150000001000000010005000101100001000000010001000101
00001010101111011101010011101000000010d00000101000001011110101000110001110101010000000000000001010111101000000101110001010101101
001001100110110d1001110100001000000010000000010000000110110d33101111d1110110011011100000001000000110110d111000001010000001001001
10100510101010011001100000110000000010000000000000001010100111101110111005100510110000001010011010101001110001101010011000001001
d0000100010010000000100000000000000001000000000000000100100011101010010001000100100000001000000001001000100000001010000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc888888
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc88888
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ccc8888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088ccc888
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888ccc88
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888ccc8
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888cc
__label__
06600660666066606660666006600660666066000000666006600000066060006660666066600660666066606600000000000000000000000000000000000000
60006060666060606060600060006000600060600000060060600000600060000600606060606060606060606060000000000000000000000000000000000000
60006060606066606600660066606660660060600000060060600000600060000600666066006060666066006060000000000000000000000000000000000000
60006060606060006060600000600060600060600000060060600000600060000600600060606060606060606060000000000000000000000000000000000000
06606600606060006060666066006600666066600000060066000000066066606660600066606600606060606660000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660666006600660000006666600000066600660000060606600066006606660666066606660066006600000666066006600000060606660666060600000
60606060600060006000000066060660000006006060000060606060600060606660606060606000600060000000606060606060000060600600600060600000
66606600660066606660000066606660000006006060000060606060600060606060666066006600666066600000666060606060000060600600660060600000
60006060600000600060000066060660000006006060000060606060600060606060600060606000006000600000606060606060000066600600600066600000
60006060666066006600000006666600000006006600000006606060066066006060600060606660660066000000606060606660000006006660666066600000
00000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000ffff0000000000000000
000000000000ffff000000000000000000000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000ffff000000000000000000000000000000000000000000000000000000000000ffff0000000000000000
000000000000ffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000004440000000000000000000000000000000050000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000054ff4f9400000000000000000100000000000051000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000005ff944444420000000000000005000000000000d1000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000fff44400004000000000000001500000000000065000000000000000000000000
000000000000000000000000000000000000000000000000000000000000004ff444000000200000000000005d0000000000006d000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000047e420000000000000000000005d0000000000016d000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ff440000000000000000000000dd00000000000d6d000000000000000000000000
000000000000000000000000000000000000000000000000000000000000009f4000000000000000000000006600000000015676000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000ee4000000000000000000000006d0000000005d776000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000e9400000000000000000000000650000005d51d576000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000049400000000000000000000000d0000000d5111566000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000442000000000000000000000000000110005d515d100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000029200000000000000000000000000055015105000500000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000001000010500d00000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000d000000550500000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001dd1001d7d0100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010016dd5d67750500000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001d666777651100000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000015555551510000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000014dd551500000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000046ff777d51500000000000000000000000
000000000000000000000000000000000000000000000000000000000000100000000000000000000000000002404e6777777d11500000000000000000000000
000000000000000000000000000000000000000000000000000000000000100000000000000000000000000009424455d9777d51500000000000000000000000
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000944efff64f774d1d00000000000000000000000
00000000000000000000000000000000000000000000000000000000000010000000000000000000000000000999421499f774d1500000000000000000000000
000000000000000000000000000000000000000000000000000000000011100000000000000000000000000004a444777777ed60500000000000000000000000
00000000000000000000000000000000000000000000000000000000011310000000000000000000000000000299444ffff456d0500000000000000000000000
0000000000000000000000000000000000000000000000000000000001c10000000000000000000000000000000500005500d651000000000000000000000000
0000000000000000000000000000000000000000000000000000000003cc10000000000000000000000000000000000000015055000000000000000000000000
000000000000000000000000000000000000000000000000000000000cc100000000000000000000000000001000001001115155100000000000000000000000
000000000000000000000000000000000000000000000000000000000c1100000000000000000000000000000000000d6ddd1d55100000000000000000000000
000000000000000000000000000000000000000000000000000000001cc1000100000000000000000000000000051000d7651655100000000000000000000000
000000000000000000000000000000000000000000000000000000003cc10011000000000000000000000000000150000d501655500000000000000000000000
000000000000000000000000000000000000000000000000000000000cc100110000000000000000000000010000dd0000001d55d00000000000000000000000
000000000000000000000000000000000000000000000000000000001110001100000000000000000000001100005d1000005d55510000000000000000000000
000000000000000000000000000000000000000000000000000000001100001100000000000000000000051000015510000055d5151000000000000000000000
00000000000000000000000000000000000000000000000000000000110000100000000000001155510000000005550000001555111100000000000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000005100000000000000510000000015d666dd5511000000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000000015d55500000001000000000005d511100000500000000000000
0000000000000000000000000000000000000000000000000000000011000010000000000000055d6d550000000000000000005515666dd501dd500000000000
000000000000000000000000000000000000000000000000000000001100001000000000000000001566d10100544999994400000d1000111156665000000000
0000000000000000000000000000000000000000000000000000000111000010000000000000000000005100044299404942450051000000055d666100000000
00000000000000000000000000000000000000000000000000000011110000100000000000000000000000105500492049400d00100000005665d6dd00000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000015040000000000000500000110066765d5500000000
000000000000000000000000000000000000000000000000000000111100001000000000000000000000000045920000000490d0101dd0055d76d11500000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000000044949500044994500d56500dd567615051000000
000000000000000000000000000000000000000000000000000000101100001000000000000000000000000004f99450599944001d66501661d6610015000000
0000000000000000000000000000000000000000000000000000001011000010000100000000000000000000004ef994999450005d765d6d650dd50001000000
000000000000000000000000000000000000000000000000000000101100001000110000000000000000000000005555550000056576d6d55d01d51001000000
0000000000000000000000000000000000000000000000000000001011000010001100000013110000000000000005000000000d65766d5005d0150000100000
000000000000000000000000000000000000000001000100000000101100001000110000000cc000000000000000000000000005d166550000d1011000100000
0000000000000000000000000000000000000000010101010000001011000010001100000011c000000000000000000000000000056655100005001000000000
000000000000000000000000000000000000000001110111000000101100001000100000001cc00000000000000000000000000005d510000001500000100000
00000000000000000000000000000000000000000011010000000010111000000010000000c11000000000000000000000000000055d11000000500000000000
0000000000000000000000000000000000000000011111010100001003c000100010000003cc1000000000000000000000000000051d50000000000000000000
001000000000000000000000000000100000000001101000010100100cc10010001000011c331010000000100010000000000000010510000000010000000000
0110000000000000000000000000011000000000011010000111001016d300000010001100000010000001100110000000000000000101000000001000000000
00110000010000000000111000000110000000000000101001100010000000000010001113c10000000001000010000001000000000001000000000001000000
d1110010011000000000101000000110001000001110000001100010000000000010001111100000001011001110001001100000010011010000001001100000
111010100c100000000010100000011010100010110000000110001001000000001000111110000010101100010010100c100000010110000000101001100000
0110d010010100100000101000000101100001101000010001010010010000000010001010100011100001000100100001010010011110000000100001000000
11010011011001100000100000001101001113c110000010110110100100010013c1000010d00011101010101101001001100110010010100000001001000110
110dd111111001500010100001001001d111111010000000110d0110010033101110001010000111010000001001111011100150110100000000111011000110
10011110311001101010000001011001111011100000011010010510010011101110001010000311000000001001010031100110100000000000010011000110
10000100050001011100010001110000010010100000010010000100010011111010000011000150000001000000010005000101100001000000010001000101
00001010101111011101010011101000000010d00000101000001011110101000110001110101010000000000000001010111101000000101110001010101101
001001100110110d1001110100001000000010000000010000000110110d33101111d1110110011011100000001000000110110d111000001010000001001001
10100510101010011001100000110000000010000000000000001010100111101110111005100510110000001010011010101001110001101010011000001001
d000010001001000000010000000000000000100000000000000010010001110101001000100010f1000000010000f0001001000100000001010000000000000
dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
00000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000f00f0000000000000000000f000000000000000000000000000000000000000000000000000000000f000000000000
000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000f0000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeefffffffff000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff000000000000000000000000000000000000000000000000000000000000000f
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff00000000000000000000f00000000000000000000000000000000ff000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
8888888899999999aaaaaaaabbbbbbbbccccccccddddddddeeeeeeeeffffffff0000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000cc888888
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ccc88888
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008ccc8888
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088ccc888
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888ccc88
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000008888ccc8
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888ccc
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000888888cc

