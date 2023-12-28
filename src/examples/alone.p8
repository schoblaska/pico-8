pico-8 cartridge // http://www.pico-8.com
version 41
__lua__
--alone in pico
--by nusan

time = 0.0

tele_cam = true
cur_cam = 1
numup = 0

sroom = 0

cpy = 0
csy = 128

room_ram = 0

selectscreen = true
selectpers = false
mainmusic=true
curmusic=0
isintroanim=true
introanim=0
introanimdur=3

function togglemusic()
	mainmusic = not mainmusic
	if curmusic==0 then
		music(mainmusic and 0 or -1,0,1)
	end
end
function setmusic(s)
	curmusic=s
	if mainmusic or curmusic!=0 then
		music(s,0,1)
	else
		music(-1,0,1)
	end
end

menuitem(1, "toggle music", togglemusic)

function clone(t)
  local t2 = {}
  for k,v in pairs(t) do
    t2[k] = v
  end
  return t2
end

function nvt (in_x,in_y,in_z)
	local set = {}
	set.x = in_x
	set.y = in_y
	set.z = in_z
  return set
end

function newtri (tris,in_v1,in_v2,in_v3,in_c)
	local set = {}
	set.v1 = flr(in_v1)
	set.v2 = flr(in_v2)
	set.v3 = flr(in_v3)
	set.c = flr(in_c)
	set.avg = 0.0
	tris[#tris+1] = set
end

function newent (loc)
	local set = {}
	set.ver={}
	set.tri={}
	set.loc=loc
	set.sort = true
	set.avg = 0.0
	set.rot = 0
  return set
end

function addvert(verts,x,y,z,s)
	verts[#verts+1] = nvt((x/256.0 - 0.5) * s,(y/256.0 - 0.5) * s,(z/256.0 - 0.5) * s)
end

function smesh (set,x,y,z,size,verbuf,tribuf)
	if not set then
		set = {}
		set.ver={}
		set.tri={}
		set.loc=nvt(x,y,z)
		set.sort = true
		set.avg = 0.0
		set.rot = 0

		while(#tribuf > 0) do

			local lenstrip = flr("0x"..sub(tribuf,1,2))-2
			local color = flr("0x"..sub(tribuf,3,4))

			local v1 = flr("0x"..sub(tribuf,5,6))
			local v2 = flr("0x"..sub(tribuf,7,8))

			tribuf = sub(tribuf,9,#tribuf)

			for i=1,lenstrip do

				local v3 = flr("0x"..sub(tribuf,1,2))

				if (i%2)==1 then
					newtri(set.tri,v1,v2,v3,color)
				else
					newtri(set.tri,v1,v3,v2,color)
				end

				v1 = v2
				v2 = v3

				tribuf = sub(tribuf,3,#tribuf)
			end
		end


		local maxsize = 5.0*size

		while(#verbuf > 0) do
			local cur = sub(verbuf,1,6)
			verbuf = sub(verbuf,7,#verbuf)
			addvert(set.ver,"0x"..sub(cur,1,2),"0x"..sub(cur,3,4),"0x"..sub(cur,5,6),maxsize)		
		end
	end
	return set
end

function pmesh (set,x,y,z,size,addr,sizev,sizei)
	if not set then
		set = {}
		set.ver={}
		set.tri={}
		set.loc=nvt(x,y,z)
		set.sort = true
		set.avg = 0.0
		set.rot = 0
		
		local vaddr = addr
		local iaddr = addr + sizev

		local runaddr = iaddr
		while((runaddr-iaddr) < sizei) do

			local lenstrip = peek(runaddr)-2
			local color = peek(runaddr+1)

			local v1 = peek(runaddr+2)
			local v2 = peek(runaddr+3)

			runaddr += 4

			for i=1,lenstrip do

				local v3 = peek(runaddr)

				if (i%2)==1 then
					newtri(set.tri,v1,v2,v3,color)
				else
					newtri(set.tri,v1,v3,v2,color)
				end

				v1 = v2
				v2 = v3

				runaddr += 1
			end
		end
		
		local maxsize = 5.0*size

		for i=1,sizev,3 do
			addvert(set.ver,peek(vaddr),peek(vaddr+1),peek(vaddr+2),maxsize)
			vaddr += 3
		end
	end
  return set
end

function cloneent(ent, x,y,z)
	local newent = clone(ent)
	newent.loc = nvt(x,y,z)
	return newent
end

campos = nvt(0,0,-1)
camdir = nvt(0,0,1)
camtar = nvt(0,0,0) 
camup = nvt(0,1,0)
camrottar = nvt(0,0,0) 
camright = nvt(1,0,0)

actions={}

function newact(xx,yy,ss,room,text,s,app,l,atext,isfx)
	local a = {loc=nvt(xx,0,yy),s=ss,r=room,t=text,start=s,apply=app,loop=l,at=atext,sfx=isfx}
	add(actions,a)
	return a
end

function ar1(xx,yy,text)
	newact(xx,yy,4,1,text)
end

function ar2(xx,yy,text)
	return newact(xx,yy,4,2,text)
end

function agrd(e)
	add(bground,e)
end

function abck(e)
	add(sortedback,e)
end

function areal(e)
	add(sortedreal,e)
end

function give(ac,text,need,needtxt)
	ac.search = true
	ac.give = text
	ac.need = need
	ac.needtxt = needtxt
	return ac
end

function auto(ac)
	ac.auto = true
	ac.at = ""
	return ac
end

function sound(xx,yy,s,r,sfx)
	local ac = newact(xx,yy,s,r,"")
	ac.sound = sfx
	return ac
end

ar1(23,-17,"a simple chair")
ar1(8,-6,"an ominous bench")
ar1(27,8,"an empty library")
ar1(27,33,"it's just some lugage")
ar1(-14,35,"the trap doesn't move")
night="a pitch-black night"
ar1(-33,-4,night)
ar1(-27,-10,"the barrel contains oil")
ar1(-27,-14,"it contains water")
ar1(-27,-18,"it contains ... blood?")
nothing="you find nothing here"
ar1(23,-25,nothing)
ar1(23,-8,nothing)
ar1(3,-40,"some old cloth")

sound(15,-24,6,1,10)
sound(16,-15,6,1,10)

ar2(-52,-21,"some old papers")
ar2(-42,-10,"alcohol bottles")
ar2(-42,-20,"vinegar bottles")
ar2(-48,-26,night)
ar2(-57,1,night)

ar2(-30,-16,"a cosy sofa")
ar2(-13,-13,"the lamp is dirty")
ar2(-22,-17,"a bloody carpet")

ar2(-20,24,"the drawer is broken")
ar2(-32,19,"a collection of shoes")
ar2(-33,26,"a nap, maybe?")
ar2(-33,31,"maybe not")
ar2(-26,33,"the garden is dark")

ar2(-0,33,"some old silverware")
ar2(2,25,"the bed is huge")
ar2(14,13,"an empty dark corner")

ar2(10,-14,"drugs and bandages")
ar2(9,-21,"a bath would be great")
ar2(9,-25,"no getting naked here")
ar2(4,-28,"my reflection seems odd")
local statue = "a statue blocks the way"
local statue2 = "i can't pass the statue"
acsta={}
add(acsta,ar2(37,-23,statue))
add(acsta,ar2(31,-28,statue2))
add(acsta,ar2(34,21,statue))
add(acsta,ar2(31,28,statue2))

ac_box1=newact(2.22,34.7,7,1,"you move the chest", function() setcol(0,8,14,4,5) setcol(1,8,9,4,5) del(actions,ac_zomb1) end, function() box1.loc.x -= 0.4 end,nil,"push",12)
ac_box2=newact(-32,20,9,1,"you move the cabinet", function() setcol(0,18,1,10,4) setcol(1,26,1,12,4) del(actions,ac_zomb2) end, function() box2.loc.z -= 0.5 end,nil,"push",12)
ac_horse=newact(-11,-34,5,1,"you shake the horse",nil, function(a) horse.loc.z += cos(a.anim*2)*0.3 end, function() horse.loc.z = -34.58 end,"shake",12)

ac_pianokey=give(newact(-52,-10,4,2,"nothing left"),"you find the piano key")
ac_piano=give(newact(-25,37,5,1,"it's out of tune"),"you find a small key",ac_pianokey,"the piano is locked")
ac_sivlerkey=give(newact(-7,-28,4,2,"the drawer is empty"),"you find a silver key")
ac_goldkey=give(newact(11,33,4,2,"there is nothing left"),"you find a gold key")

ac_door3=newact(-35,2,7,2,"you use the small key", function() setcol(0,112,16,3,2) end, function() r2_door3.rot -= 0.0166 end,nil,"open",14)
ac_door3.need=ac_piano
ac_door2=newact(-25,11,7,2,"you use the silver key", function() setcol(0,106,20,3,1) end, function() r2_door2.rot -= 0.0166 end,nil,"open",14)
ac_door2.need=ac_sivlerkey
ac_door1=newact(5,10,7,2,"you use the gold key", function() setcol(0,88,20,3,2) tele_cam=true need_paste=false end,nil,nil,"open",14)
ac_door1.need=ac_goldkey

ac_mirrorkey=give(newact(-4,21,3,2,"hello teddy bear"),"you find two mirrors")

ac_mir1=give(newact(24,-24,5,2,"nothing happens", function() del(sortedreal,r2_dl) del(sortedreal,r2_dr) areal(r2_mirror) end), "you place a mirror",ac_mirrorkey,"a strange altar")
ac_mir2 = clone(ac_mir1)
ac_mir2.loc = nvt(24,0,22)
add(actions,ac_mir2)

ac_death = auto(newact(-7,6,6,2,"", function() deathtrap1=true setmusic(8) time = 0 end, nil,nil,nil,25))
ac_death2 = clone(ac_death)
ac_death2.loc = nvt(-7,0,-2)
add(actions,ac_death2)
zsound=function() setmusic(9) end
ac_zomb1=auto(newact(-25,37,20,1,"a zombie arrives", zsound, function() trap.loc.z += 0.25 end,nil,nil,12))
ac_zomb2=auto(newact(-27,-26,11,1,"the window broke", zsound,nil,nil,nil,15))
ac_zomb3=auto(newact(-23,-29,11,2,"it's a trap", zsound,nil,nil,nil,15))

for n=1,5 do
	sound(-26+n*8,0,10,2,8)
end
sound(-28,22,12,2,10)
sound(-28,29,12,2,10)
sound(-23,-29,12,2,10)

function v_sub(v1,v2)
	local vf = clone(v1)
	vf.x -= v2.x
	vf.y -= v2.y
	vf.z -= v2.z
	return vf
end

function v_len(p0)
	return sqrt(p0.x*p0.x + p0.y*p0.y + p0.z*p0.z+0.001)
end

function v_mulf(v1,f)
	local vf = clone(v1)
	vf.x *= f
	vf.y *= f
	vf.z *= f
	return vf
end

function v_add(v1,v2)
	local vf = clone(v1)
	vf.x += v2.x
	vf.y += v2.y
	vf.z += v2.z
	return vf
end

function dot(v1,v2)
	return v1.x*v2.x + v1.y*v2.y + v1.z*v2.z
end

function v_cross(v1,v2)
	local vf = clone(v1)
	vf.x = v1.y*v2.z - v1.z*v2.y
	vf.y = v1.z*v2.x - v1.x*v2.z
	vf.z = v1.x*v2.y - v1.y*v2.x
	return vf
end

function v_norm(v1)
	local vf = clone(v1)
	local len = 1.0/sqrt(vf.x*vf.x+vf.y*vf.y+vf.z*vf.z+0.0001)
	vf.x = vf.x*len
	vf.y = vf.y*len
	vf.z = vf.z*len
	return vf
end

function lerp(a,b,alpha)
	return a*(1.0-alpha)+b*alpha
end

function clampy(v)
	return max(cpy-1,min(csy,v))
end

function swap(x1,x2)
	return x2,x1
end

function otri(x1,y1,x2,y2,x3,y3,c)

	if y2<y1 then
		if y3<y2 then
			y1,y3=swap(y1,y3)
			x1,x3=swap(x1,x3)
		else
			y1,y2=swap(y1,y2)
			x1,x2=swap(x1,x2)
		end
	else
		if y3<y1 then
			y1,y3=swap(y1,y3)
			x1,x3=swap(x1,x3)
		end
	end

	y1 += 0.001

	local miny = min(y2,y3)
	local maxy = max(y2,y3)

	local fx = x2
	if y2<y3 then
		fx = x3
	end

	local cl_y1 = clampy(y1)
	local cl_miny = clampy(miny)
	local cl_maxy = clampy(maxy)

	local steps = (x3-x1)/(y3-y1)
	local stepe = (x2-x1)/(y2-y1)

	local sx = steps*(cl_y1-y1)+x1
	local ex = stepe*(cl_y1-y1)+x1
		
	for y=cl_y1,cl_miny do
		rectfill(sx,y,ex,y,c)
		sx += steps
		ex += stepe
	end

	sx = steps*(miny-y1)+x1
	ex = stepe*(miny-y1)+x1

	local df = 1/(maxy-miny)

	local step2s = (fx-sx) * df
	local step2e = (fx-ex) * df

	local sx2 = sx + step2s*(cl_miny-miny)
	local ex2 = ex + step2e*(cl_miny-miny)

	for y=cl_miny,cl_maxy do
		rectfill(sx2,y,ex2,y,c)
		sx2 += step2s
		ex2 += step2e
	end
end

function clearroom1()
	back = nil
	horse = nil
	chair = nil
	box1 = nil
	pilars = {}
	bars = {}
	barils = {}
	window = nil
	bench = nil
	trap = nil
	box2 = nil
	box3 = nil
	table = nil
	library = nil
end

function clearstatic2()
	r2_enter = nil
	r2_center = nil
	r2_hall = nil
	r2_1 = nil
	r2_2 = nil
	r2_3 = nil
	r2_4 = nil
end

function clearroom2()
	r2_win = nil
	r2_ted = nil
	r2_mirtab = nil
	r2_lamp = nil
	r2_lamp2 = nil
	r2_etag = nil
	r2_door =  nil
	r2_door2 = nil
	r2_couch = nil
	r2_carpet = nil
	r2_brok = nil
	r2_box1 = nil
	r2_box2 = nil
	r2_bath = nil
	r2_bar = nil
	r2_bar2 = nil
	r2_arm = nil
	r2_alt = nil
	r2_alt2 = nil

	r2_enter = nil
	r2_center = nil
	r2_hall = nil
	r2_1 = nil
	r2_2 = nil
	r2_3 = nil
	r2_4 = nil
	r2_dl = nil
	r2_dr = nil
end

function acam(x,y,z,i,j,k,r)
	add(cams,{pos=nvt(x,y,z),tar=nvt(i,j,k),room=r})
end

function add_objects()

	cams = {}
	bground = {}
	sortedback = {}
	sortedreal = {}

	clearroom1()
	clearroom2()

	reload()

	if room_number == 1 then
		acam(35,12,-20,0,1,-15,0)
		acam(-1.908,16.321,43.371,-11,4,29,0)
		acam(-26.415,18.96,45.171,-5,4,25.2,0)
		acam(31.581,4,42.31,12,14,17,0)
		acam(-18.658,15.585,-9.15,-24,1,-30,0)
	else
		acam(15.47,8.81,3.53,6,6,2,0)
		acam(-35.9,9.39,5.26,-26,6,2,0)

		acam(20.97,11.18,27.9,8,6,27,2)
		acam(-11.83,8.44,32.587,1,8,27,2)

		acam(-22.1,9.9,36.2,-25,2,25,1)
		acam(-19.6,11.94,12.32,-25,6,25,1)

		acam(-53.9,14.4,6.5,-46,1,-9,5)
		acam(-46.18,17,-9.9,-53,5,0,5)

		acam(-33.5,9.2,-15,-11,3,-24,4)
		acam(-1.41,9.37,-33.21,-11,8,-28,4)

		acam(3.5,3.87,-31.64,11,7,-8,3)
		acam(6.7,9.2,-8.36,12,3,-32,3)

		acam(32.2,11.133,-3.91,29,-6,18,6)
		acam(41.9,14.13,2.4,26,-3,-13,6)

		acam(0.05,9.32,-3.55,-7,5,0,0)
		acam(-20.73,12.394,1.7,-10,10,2,0)

		acam(-8.244,20.552,-1.515,-11,12,-1,0)
	end

	if selectscreen then
		acam(6,10,0,0,10,0,0)

		title=smesh(title, -3,15.05,0.91,2,"80558080ac8080558d80498d80ac8d80b98080556a80ac6a80ac7780557780497780b96a80b97780498080955080ac5080955d80ac5d80b9508055ac80acac8055b980acb980b9b980b9bf8049b98049ac8049a58055a58049998055998063998049e3808be38049f0808bf08096f08096e380bce380bcf080c6e380c6f080c6f78096f780bcd8808bd48096d4808bc88096c880b5c880b5d480c6d28049d480b95d80b96380495d808538809a38808545809a4580b93880494580551a808b1a808b2780961a80962780ac1a80ac2780b91a80491a804906808b0980552780492780ac0780b92780b92d80b9ac80b98d80496a80acbf8063a580bcf7808bf78049c880ac6380495080b94580493880550680960980b90780ac2d","070a2c2c2524222321070a5252191718154f080a080c090d02060550080a0304010e0a0b0751050a1e1f1d2053050a292a282b54030a2c5524070a26262f2e303556050a1336123757070a131210110f3858090a5a5a3e393b3a3c3d59050a4b473f485b090a4b4b4a3f414042495c070a43434544464c5d050a464d454e5e040a05030201040a0809070a070a17171516141a1b050a1e1d1c141b070a2928272526222e090a30312f3233342d2927040a3b3c0f10040a44434241")
	else
		title=nil
		acam(5,9.5,0,0,6.5,0,0)
	end

	if selectpers or selectscreen then
		pers=pmesh(pers, charstart.x,charstart.y,charstart.z, 2 ,8192,435,442)
	end
	if not selectpers or selectscreen then
		fepers=pmesh(fepers, charstart.x,charstart.y,charstart.z, 2 ,9069,411,443)
		if not selectscreen then
			pers = fepers
		end
	end

	pers.loc = charstart
	pers.rot = charstartrot

	if room_number == 1 then
		
		if not back then

			pilars = {}
			bars = {}
			barils = {}

			back=pmesh(back, 0,0,0, 20 ,9923,423,509)
			horse=pmesh(horse, -6.28,4.12,-34.58, 2.04 ,10855,228,289)
			chair=pmesh(chair, 26.91,4,-17.65, 1.5 ,11372,198,274)
			baril=pmesh(baril, -32.7,2.9,-12.2,1.2 ,11844,123,117)
			box2=pmesh(box2, -30.5,8.6,ac_box2.anim and 0.2 or 15.2, 3.5 ,12084,132,98)
			box1=pmesh(box1, ac_box1.anim and -10.78 or 1.22,2.4,34.7, 1.76 ,12314,96,124)

			window=pmesh(window, -34.7,13.3,-1.5, 2.6 ,0,48,48)
			pilar=pmesh(pilar, -19.8,11.3,33.8, 4.5 ,96,24,30)
			bar=pmesh(bar, -19.6,23.5,0.0, 19.45 ,150,96,66)
			bench=pmesh(bench, 8.3,1.8,-6.3, 0.84 ,312,105,90)
			trap=pmesh(trap, -17.2,0,31, 3.37 ,507,24,24)
			box3=pmesh(box3, 23.5,2.9,26.4, 2.33 ,555,72,82)
			library=pmesh(library, 26.7,2.6,6.2, 3.39 ,709,24,24)

			barils[1] = baril
			barils[2] = cloneent(baril,-32.7,2.9,-16.8)
			barils[3] = cloneent(baril,-32.7,2.9,-21.4)

			bars[1] = bar
			bars[2] = cloneent(bar, 1.7,23.5,0.0)
			bars[3] = cloneent(bar, 20.3,23.5,0.0)

			pilars[1] = pilar
			pilars[2] = cloneent(pilar, -19.8,11.3,2.0)
			pilars[3] = cloneent(pilar, -19.8,11.3,-33.2)
			pilars[4] = cloneent(pilar, 1.56,11.3,2.0)
			pilars[5] = cloneent(pilar, 20.2,11.3,33.8)
			pilars[6] = cloneent(pilar, 20.2,11.3,2.0)
			pilars[7] = cloneent(pilar, 20.2,11.3,-33.24)

			table = cloneent(library,32,2,-21)
			table.rot = 0.75

		end
	end

	cur_addr = 0x4100
	dcol(0)
	dcol(64)

	if(not ac_door3.anim) setcol(1,112,15,3,4)
	if(not ac_door2.anim) setcol(1,106,20,3,1)
	if(not ac_door1.anim) setcol(1,88,20,3,2)

	if(ac_box1.anim) ac_box1.start()
	if(ac_box2.anim) ac_box2.start()
end

function fillsorted()

	bground = {}
	sortedback = {}
	sortedreal = {}

	if selectscreen then
		if(isintroanim) then
			areal( title)
		else
			areal( pers)
			areal( fepers)
			abck( title)
		end
		return
	end

	if finalvic then
		areal( pers)
		return
	end

	if (zombi) areal( zombi)

	if deathtrap2 then
		return
	end

	areal( pers)

	zombi2 = smesh(charzombi, 37,0,-35,2,strzombv,strzombi)
	zombi2.rot = 0.65
	if cur_cam == 12 then
		zombi2.loc.z = 35
		zombi2.rot = 0.4
	end

	if room_number == 1 then
		agrd( back)
		if(cur_cam != 4) abck( horse)
		abck( chair)	
		if((cur_cam != 1) and (cur_cam != 2)) abck( box1)
		for i=1,7 do
			abck( pilars[i])
		end
		for i=1,3 do
			abck( bars[i])
		end
		for i=1,3 do
			abck( barils[i])
		end
		abck( window)
		abck( bench)
		if(cur_cam != 1) abck( box2)
		abck( box3)

		abck( library)

		if cur_cam == 0 then
			areal( chair)
			areal( pilars[4])
		end
		if cur_cam == 1 then
			areal( box1)
			areal( box2)
		end
		if cur_cam == 2 then
			areal( box1)
			areal( pilars[1])
			areal( box3)
			abck( table)
		end
		if cur_cam == 3 then
			areal( box3)
		end
		if cur_cam == 4 then
			areal( horse)
		end
	else

		local s = 9

		clearroom2()

		r2_center=pmesh(r2_center, -6.9,6.38,0.72,s/0.785 ,757,594,533)
		r2_1=pmesh(r2_1, -29.6,6,25.2,s ,1884,144,149)
		r2_2=pmesh(r2_2, 4.5,6.12,25,s/1.3 ,2177,108,90)
		r2_3=pmesh(r2_3, 9.44,8.0,-23.58,s/1.56 ,2375,174,176)
		r2_4=pmesh(r2_4, -17,6,-24,s ,2725,96,85)
		r2_enter=pmesh(r2_enter, -48.9,6.3,-5.6,s/0.64 ,2906,306,326)
		r2_hall=pmesh(r2_hall, 41.,1.5,0.5,s/0.56 ,3538,450,423)
		r2_dl=pmesh(r2_dl, 0,0,0,s/0.56 ,4411,33,28)
		r2_dr=pmesh(r2_dr, 0,0,0,s/0.56 ,4472,33,31)

		agrd( r2_enter)
		agrd( r2_center)
		agrd( r2_hall)
		agrd( r2_1)
		agrd( r2_2)
		agrd( r2_3)
		agrd( r2_4)

		if sroom > 0 and sroom < 6 then
			r2_win=pmesh(r2_win, 0,0,0,s/2.56 ,4536,102,86)
			r2_mirtab=pmesh(r2_mirtab, 0,0,0,s/2.12 ,4724,204,192)
			r2_couch=pmesh(r2_couch, 0,0,0,s/2.87 ,5120,105,85)
			
			r2_carpet=pmesh(r2_carpet, 0,0,0,s/2.72 ,5429,180,96)
			r2_box1=pmesh(r2_box1, 0,0,0,s/4.56 ,5705,84,91)
			r2_arm=pmesh(r2_arm, 0,0,0,s/2.89 ,5880,84,95)

			r2_box2 = cloneent(r2_box1, -58,4,-30)
		end
		r2_lamp=pmesh(r2_lamp, -10,10,-8.1,s/9.13 ,6059,87,71)
		r2_lamp2 = cloneent(r2_lamp, 0,0,0)
		r2_lamp2.rot = 0.5
		
		r2_door=pmesh(r2_door, 7.5,0,9.5,s/1.96 ,7729,90,102)
		r2_door.rot = ac_door1.anim and 0.5 or 0
		r2_door2 = cloneent(r2_door, -28,0,11.5)
		r2_door2.rot = ac_door2.anim and 0.18 or 0.5
		if ac_door3.anim then
			r2_door3 = cloneent(r2_door, -35,0,4.5)
		else
			r2_door3 = cloneent(r2_door, -37,1,4.5)
		end
		
		r2_door3.rot = ac_door3.anim and -0.7 or -0.25
		
		if sroom == 0 then
			abck( r2_lamp)
			abck( r2_lamp2)
			r2_lamp2.loc = nvt(-10,10,9)
			r2_brok=pmesh(r2_brok, -8.5,0,1,s/3.18 ,6217,120,88)
			add(cur_cam==16 and sortedreal or sortedback, r2_brok)
			agrd( r2_door)
			add(cur_cam==1 and sortedreal or bground, r2_door2)
			if(cur_cam!=1) abck( r2_door3)
		elseif sroom == 1 then
			areal( r2_mirtab)
			r2_mirtab.loc = nvt(-16,0,24)
			r2_mirtab.rot = 0.75
			areal( r2_couch)
			r2_couch.loc = nvt(-39,0,28)
			abck( r2_win)
			r2_win.loc = nvt(-26.8,7,37.2)
			r2_win.rot = 0.5
			abck( r2_arm)
			r2_arm.loc = nvt(-35,7,14)
			r2_arm.rot = 0.75
			abck( r2_door2)
		elseif sroom == 2 then
			abck( r2_win)
			r2_win.loc = nvt(8.8,7,37.2)
			r2_win.rot = 0.5
			abck( r2_arm)
			r2_arm.loc = nvt(-2,6.5,36.0)
			r2_arm.rot = 0.25
			abck( r2_box1)
			r2_box1.loc = nvt(-9,4,21)
			r2_ted=pmesh(r2_ted, -6.8,6.5,22,s/6.63 ,6425,150,98)
			abck( r2_ted)
			r2_ted.rot = 0.25
			abck( r2_mirtab)
			r2_mirtab.loc = nvt(15,0,36)
			r2_mirtab.rot = 0.5
			r2_bed=pmesh(r2_bed, 11.5,0,25,s/1.4 ,5310,72,47)
			abck( r2_bed)
			r2_bar=pmesh(r2_bar, 4,0,31,s/1.48 ,6673,108,96)
			r2_bar2 = cloneent(r2_bar, 4,0,20)
			areal( r2_carpet)
			r2_carpet.loc = nvt(12.3,2.5,24.1)
			abck( r2_bar)
			abck( r2_bar2)
			abck( r2_carpet)
			agrd( r2_door)
		elseif sroom == 3 then	
			abck( r2_arm)
			r2_arm.loc = nvt(16,7,-13)
			r2_arm.rot = 0.5
			abck( r2_mirtab)
			r2_mirtab.loc = nvt(5,0,-33)
			r2_mirtab.rot = 0
			r2_bath=pmesh(r2_bath, 14,0,-26,s/3.35 ,6877,54,49)
			areal( r2_bath)
		elseif sroom == 4 then
			abck( r2_couch)
			r2_couch.loc = nvt(-29,0,-29)
			abck( r2_carpet)
			r2_carpet.loc = nvt(-16,0,-26)
			areal( r2_mirtab)
			r2_mirtab.loc = nvt(-7,0,-33)
			r2_mirtab.rot = 0
			abck( r2_win)
			r2_win.loc = nvt(-16,7,-36.5)
			r2_win.rot = 0
			abck( r2_lamp2)
			r2_lamp2.loc = nvt(-13,10,-11)
		elseif sroom == 5 then
			r2_etag=pmesh(r2_etag, -38,-1,-20,s/1.5 ,6980,219,239)
			abck( r2_etag)
			abck( r2_arm)
			r2_arm.loc = nvt(-57,6,-10)
			r2_arm.rot = 0
			abck( r2_box1)
			r2_box1.loc = nvt(-58,4,-19)
			abck( r2_box2)
			areal( r2_door3)
		elseif sroom == 6 then
			r2_alt=pmesh(r2_alt, 25,0,-28,s/2.13 ,7438,159,132)
			r2_alt2 = cloneent(r2_alt, 25,0,28)
			r2_alt2.rot = 0.25
			abck( r2_alt)
			abck( r2_alt2)
			r2_mirror=pmesh(r2_mirror, 0,0,0,s/7 ,7921,54,46)
			
			if (finalanim<4) areal(zombi2)
		end

		if cur_cam == 1 then
			r2_dr.loc = nvt(-28.3,1.9,9.1)
			r2_dl.loc = nvt(-28.5,2.2,-7)
			r2_dl.rot = -0.25
			r2_dr.rot = 0.25
			areal( r2_dr)
			areal( r2_dl)
		elseif cur_cam == 2 then
			r2_dr.loc = nvt(6.7,2.3,11.9)
			r2_dr.rot = -0.25
			areal( r2_dr)
		elseif cur_cam == 0 then
			r2_dl.loc = nvt(7.3,2.4,9.2)
			r2_dl.rot = 0.25
			r2_dr.loc = nvt(6.9,2.4,-7.9)
			r2_dr.rot = -0.25
			areal( r2_dr)
		elseif cur_cam == 13 then
			r2_dl.loc = nvt(21.2,1.7,2.4)
			r2_dl.rot = 0
			r2_dr.loc = nvt(21.2,1.7,-1.8)
			r2_dr.rot = 0
			abck( r2_dl)
			abck( r2_dr)
			areal( r2_dl)
			areal( r2_dr)
			r2_mirror.loc = nvt(25,8,-27.9)
			r2_mirror.rot = 0.825
			if (ac_mir1.anim) abck( r2_mirror)
		elseif cur_cam == 12 then
			r2_mirror.loc = nvt(25,8,27.9)
			r2_mirror.rot = 0.125
			if (ac_mir2.anim) abck( r2_mirror)
		elseif cur_cam == 5 then
			r2_dl.loc = nvt(-13.5,1.7,30.5)
			r2_dl.rot = 0.5
			areal( r2_dl)
		end
	end

	room_ram = stat(0)
end

function sorttrisloop(t,n)
	local tv = #t-1
	for j=1,n do
		for i=1,tv do
			local t1 = t[i]
			local t2 = t[i+1]
			if t1.avg < t2.avg then
				t[i] = t2
				t[i+1] = t1
			end
		end
	end
end

function sortalltris(t)
	local tv = #t-1
	local loop = true
	while loop do
		loop = false
		for i=1,tv do
			local t1 = t[i]
			local t2 = t[i+1]
			if t1.avg < t2.avg then
				t[i] = t2
				t[i+1] = t1
				loop = true
			end
		end
	end
end

function compcam(ent)
	local crot = cos(ent.rot)
	local srot = sin(ent.rot)

	local ldecal = v_mulf(rotvec_y(v_sub(campos, ent.loc), crot, srot), -1)
	local lcamright = rotvec_y(camright, crot, srot)
	local lcamup = rotvec_y(camup, crot, srot)
	local lcamdir = rotvec_y(camdir, crot, srot)
	return ldecal,lcamright,lcamup,lcamdir
end

function draw_tris_do(ent,ptable,tverts)
	local tn = #ptable

	if ent.sort then
		for i=1,tn do
			local ct = ptable[i]
			ct.avg = tverts[ct.v1].z + tverts[ct.v2].z + tverts[ct.v3].z
		end

		if tele_cam then
			sortalltris(ptable)
		else
			sorttrisloop(ptable,2)
		end
	end

	if finalanim>2 and ent == zombi2 then
		if not zendsfx and finalanim>2.3 then sfx(25) zendsfx=true end
		local size = (finalanim-2)*4
		size *= size
		size += 1
		for i=1,tn,1 do
			local ct = ptable[i]
			local v1 = tverts[ct.v1]

			circfill(v1.x,v1.y,size,ct.c)
		end

		return
	end


	for i=1,tn do
		local ct = ptable[i]
		local v1 = tverts[ct.v1]
		local v2 = tverts[ct.v2]
		local v3 = tverts[ct.v3]

		local back = (v2.y-v1.y)*(v3.x-v1.x) - (v2.x-v1.x)*(v3.y-v1.y)

		local minx = min(min(v1.x,v2.x),v3.x)
		local maxx = max(max(v1.x,v2.x),v3.x)
		local miny = min(min(v1.y,v2.y),v3.y)
		local maxy = max(max(v1.y,v2.y),v3.y)
		local minz = min(min(v1.z,v2.z),v3.z)

		local clip = maxx < 0 or minx > 128 or maxy < cpy or miny > csy or minz < 0.01

		if back>=0 and not clip then
			otri(flr(v1.x),flr(v1.y),flr(v2.x),flr(v2.y),flr(v3.x),flr(v3.y),ct.c)
		end
	end
end

function draw_tris(ent)

	if ent == table then
		pal(4,3)
		pal(5,1)
	end

	local ldecal,lcamright,lcamup,lcamdir = compcam(ent)

	local vtable = ent.ver
	local ptable = ent.tri

	local tverts = {}
	local tv = #vtable
	for i=1,tv do
		local cur = clone(vtable[i])

		local side = 1
		if(cur.z<0) side = -1

		cur = v_add(cur,ldecal)
		local cur2 = clone(cur)
		cur2.x = dot(cur,lcamright)
		cur2.y = dot(cur,lcamup)
		cur2.z = dot(cur,lcamdir)

		local invz = 64.0*(1.0/max((cur2.z),0.1))
		cur2.x = (-cur2.x * invz + 63.5)
		cur2.y = (-cur2.y * invz + 63.5)

		tverts[i] = cur2
	end
	
	draw_tris_do(ent,ptable,tverts)

	pal()
end

function rotvec_y(vec, cangle, sangle)
	local cur2 = clone(vec)
	cur2.x = vec.x * cangle + vec.z * sangle
	cur2.z = -vec.x * sangle + vec.z * cangle
	return cur2
end

function draw_tris_checkanim(ent)

	if ent == r2_dl or ent == r2_dr then
		if cur_cam == 5 then
			pal(3,13)
		elseif cur_cam == 2 then
			pal(4,3)
		end
	end

	if ent == zombi2 then
		pal(3,6)
		pal(8,13)
	end

	if ent == pers or ent == zombi then
		draw_tris_anim(ent)
	else
		draw_tris(ent)
	end

	pal()
end

function achar()
	local set = {}
	set.isanim = false
	set.str = 0
	set.time = 0
	return set
end

char = achar()
charzomb = achar()

function draw_tris_anim(ent)

	local vtable = ent.ver
	local ptable = ent.tri

	local cc = char
	if(ent == zombi) cc = charzomb

	if cc.isanim then
		cc.str = lerp(cc.str,0.0,0.1)
	else
		cc.str = lerp(cc.str,1.0,0.5)
	end
	if(cc.str>0.99) cc.time = 0.0

	local runtime = cc.time * 0.8
	local anim = sin(runtime)*0.08
	local canim = lerp(cos(anim),1,cc.str)
	local sanim = lerp(sin(anim),0,cc.str)
	local uanim = lerp(max(0,sin(runtime*1.0 + 0.25)),0,cc.str)
	local anim2 = sin(runtime-0.05)*0.08
	local canim2 = lerp(cos(anim2),1,cc.str)
	local sanim2 = lerp(sin(anim2),0,cc.str)
	local uanim2 = lerp(max(0,sin(runtime*1.0 + 0.5 + 0.25)),0,cc.str)

	local oanim = lerp(max(0,sin(runtime*2.0)),0,cc.str)

	local ldecal,lcamright,lcamup,lcamdir = compcam(ent)

	local cv1 = selectpers and 0.98 or 1.02
	local cv2 = selectpers and 0.3 or 0.9

	local tverts = {}
	local tv = #vtable
	for i=1,tv do
		local cur = clone(vtable[i])
		
		local side = 1
		if(cur.z<0) side = -1

		if cur.y<0.0 and abs(cur.z)<0.95 then
			local oldx = cur.x
			local oldy = cur.y
			local can = canim
			local san = sanim
			local uan = uanim
			if cur.y<-2.3 then
				can = canim2
				san = sanim2
			end
			if(cur.z<0) uan = uanim2

			cur.x = oldx * can + side*oldy * san
			cur.y = -oldx * side * san + oldy * can
			cur.y += -(uan) * cur.y * 0.2
		end
	
		if abs(cur.z)>cv1 then
			local oldx = cur.x
			local oldy = cur.y - 2
			local can = canim
			local san = sanim
			local uan = uanim
			 if cur.y<cv2 then
			 	can = canim2
			 	san = sanim2
			 end

			cur.x = oldx * can - side*oldy * san
			cur.y = oldx * side * san + oldy * can + 2
		end
	
		cur.y += -(oanim) * 0.2
	
		cur = v_add(cur,ldecal)
		local cur2 = clone(cur)
		cur2.x = dot(cur,lcamright)
		cur2.y = dot(cur,lcamup)
		cur2.z = dot(cur,lcamdir)

		local invz = 64.0*(1.0/max((cur2.z),0.1))
		cur2.x = (-cur2.x * invz + 63.5)
		cur2.y = (-cur2.y * invz + 63.5)

		tverts[i] = cur2
	end

	draw_tris_do(ent,ptable,tverts)
end

function _init()

	reset()
	setmusic(-1)

end

function reset()

	room_number = 1

	zombi = nil
	ac_zomb1.anim = nil
	ac_zomb2.anim = nil
	ac_zomb3.anim = nil
	ac_death.anim = nil
	ac_death2.anim = nil

	if(room_number == 2) then
		charstart = nvt(36,4.5,-10)
	else
		charstart = nvt(20.0,4.5,-21.0)	
	end
	
	charstartrot = 0
	add_objects()
	deathtrap1 = false
	deathtrap2 = false
	forcecam = false

	deathanim=0
	finalanim=0
	victoryanim=0

	setmusic(0)
end

function getcam(mx,mz)
	local c = 0
	if room_number == 1 then
		if mx<-10 then
			c = mz>-9.7 and 1 or 4
		else
			if mz>4.5 then
				c = mx>0.0 and ((mx>23 and mz>16) and 3 or 2) or 1
			end
		end
		if(forcecam) c = 5
	else
		if mz>9 then
			if mx<-45 then
				c = 7
			elseif mx<-12 then
				c = mz>29 and 5 or 4
			elseif mx<19 then
				c = mx>8 and 3 or 2
			else
				c = 12
			end
		elseif mz<-10 then
			if mx<-35 then
				c = 6
			elseif mx<0 then
				c = mx>-10 and 8 or 9
			elseif mx<19 then
				c = mz<-21 and 11 or 10
			else
				c = 13
			end
		else
			if mx<-35 then
				c = mx<-43 and 7 or 6
			elseif mx<-28 then
				c = 14
			elseif mx<-5 then
				c = 1
			elseif mx<10 then
				c = 0
			elseif mx<20 then
				c = 15
			else
				c = 13
			end
		end
		if(deathtrap1) c = 16
		if(forcecam) c = 17
	end
	return c
end

actmsgtime=0
actmsggoal=0
acttxttime=0
acttxtgoal=0

actiondone = false

function doaction(action)

	if room_number==action.r and not actiondone then

		local dx = (action.loc.x-pers.loc.x)/action.s
		local dz = (action.loc.z-pers.loc.z)/action.s

		if (dx*dx+dz*dz)<1 then
			if action.sound then
				footsound = action.sound
			elseif action.search or not action.anim then
				if btnp(5) or btnp(4) or action.auto then
					if not action.need or action.need.anim then
						if (not deathtrap1) sfx(action.give and 13 or (action.sfx and action.sfx or 17))
						if action.at or action.search then
							if not action.anim then
								action.anim = 1
								if(action.start) action.start(action)
							end
						end
						acttxt=action.give and action.give or action.t
						action.give=nil
					else
						acttxt=action.needtxt and action.needtxt or "you dont have the key"
						sfx(17)
					end
					acttxtgoal=acttxtgoal>50 and 0 or 100
					actiondone = true
				end
				if action.at then
					actmsg=action.at
				else
					actmsg="look"
				end
				actmsggoal=10
			end
		end

		if action.anim then
			if action.anim>0 then
				if(action.apply) action.apply(action)
				action.anim-=dt
			else
				if action.loop then
					action.loop(action)
					action.anim=nil
				end
			end
		end
	end
end

dt = 1.0/30.0

function czombi(zx,zy,zz)
	zombi = smesh(charzombi, zx,zy,zz,2,strzombv,strzombi)
	areal(zombi)
	return zombi
end

function finalcharanim(ent, off, off2)
	ent.loc = nvt(0,4.5,off)
	ent.rot = sin(time*0.3) * 0.1 + off2
end

charfoot = false

function _update()

	if deathtrap2 or finalvic or selectscreen then
		forcecam = true
	else
		forcecam = false
	end

	numup += 1

	if deathtrap1 or deathtrap2 then
		if time>1 and (btnp(4) or btnp(5)) then
			reset()
		end
	end

	if ac_zomb1.anim and trap.loc.z>35 and zombi == nil then
		czombi(-11,0,34)
	end

	if ac_zomb2.anim and zombi == nil then
		czombi(-27,4.5,-9)
	end

	if ac_zomb3.anim and zombi == nil then
		czombi(-27,4.5,-9)
	end

	if zombi and zombi.loc.y<4.5 then
		zombi.loc.y += 0.1
	end

	if ac_mir1.anim and ac_mir2.anim then
		if(finalanim==0) sfx(24) setmusic(-1)
		finalanim += dt
		if finalanim > 3 then
			del(sortedreal,zombi2)
			setcol(0,69,4,5,3)
			setcol(0,69,25,5,3)
			for k=1,#acsta do del(actions,acsta[k]) end
		else
			if zombi2 then
				zombi2.rot += dt*finalanim
			end
		end
	end

	if room_number == 2 and pers.loc.x>40 then
		if not victory then
			if cur_cam == 12 then
				vicpos = nvt(47,4.5,25)
			else
				vicpos = nvt(45,4.5,-25)
			end
		end
		victory = true
	end

	actmsg = ""
	actmsggoal=0
	actiondone = false
	footsound = 6
	foreach(actions, doaction)

	if not zombi then
		if room_number == 1 then
			if pers.loc.x < -21 and pers.loc.z < -38 then
				charstart = nvt(-52,4.5,6.9)
				charstartrot = 0.25
				room_number = 2
				add_objects()
			end
		else
			if pers.loc.x <-49 and pers.loc.z >12 then
				charstart = nvt(-30,4.5,-33)
				charstartrot = -0.25
				room_number = 1
				add_objects()
			end
		end
	end

	local rspeed = 0.01

	local forward = 0.0
	if deathtrap1 then
		local prog = -deathanim*deathanim*0.03
		pers.loc = nvt(-8,4.5+prog,0.85)
		r2_brok.loc.y = prog
		char.isanim = false
		if (deathanim<100) deathanim +=1
	elseif deathtrap2 then
		finalcharanim(zombi,0,0)
		charzomb.time += dt
		charzomb.isanim = true
		char.isanim = false
	elseif victory then
		victoryanim += dt
		if victoryanim>5 then
			if (not finalvic) time = 0 setmusic(6)
			finalvic = true
			finalcharanim(pers,0,0)
			char.isanim = true
		else
			local dir = (cur_cam == 12) and 1 or -1

			pers.rot = (pers.rot+0.5)%1-0.5

			vicpos.z -= dir*dt*3
			pers.rot = lerp(pers.rot, dir*0.25,0.05)
			pers.loc.x = lerp(pers.loc.x, vicpos.x,0.05)
			pers.loc.z = lerp(pers.loc.z, vicpos.z,0.05)
			pers.loc.y -= dt
			char.isanim = true
		end		
	elseif selectscreen then
		if introanim<introanimdur then

			local titlefinal = nvt(-3,15.05,0.91)
			local titleinit = nvt(2,3.5,-4.1)

			local an = min(1,introanim/introanimdur)
			an*=an
			title.loc.x = lerp(titleinit.x,titlefinal.x,an)
			title.loc.y = lerp(titleinit.y,titlefinal.y,an)
			title.loc.z = lerp(titleinit.z,titlefinal.z,an)
			title.rot = lerp(0.125,0,an)

			introanim+=dt
		else
			if isintroanim then
				setmusic(7)
				isintroanim=false
				need_paste=false
				tele_cam=true
			end

			time /=3
			finalcharanim(pers,-3,-0.1)
			finalcharanim(fepers,3,0.1)
			time *=3
			if btnp(0) or btnp(1) then
				sfx(17)
				selectpers = not selectpers
			end
			if btnp(4) or btnp(5) then
				sfx(17)
				selectscreen = false
				reset()
			end
		end
	else
		if(btn(0)) pers.rot += rspeed
		if(btn(1)) pers.rot -= rspeed
		if(btn(2)) forward += 0.3
		if(btn(3)) forward -= 0.15

		if btn(0) or btn(1) or btn(2) or btn(3) then
			char.isanim = true
		else
			char.isanim = false
		end
	end
	char.time += dt

	if char.isanim and not finalvic then
		local runtime = char.time * 0.8
		local anim = abs(sin(runtime))
		if anim>0.75 then
			if not charfoot then
				if (victory) footsound = 8
				sfx(footsound+rnd(2))
				charfoot = true
			end
		else
			charfoot=false
		end
	end

	local crot = cos(pers.rot)
	local srot = sin(pers.rot)

	local iscol = checkcol(pers.loc.x,pers.loc.z)
	local nx = pers.loc.x + crot * forward
	local nz = pers.loc.z + srot * forward
	local ncol = checkcol(nx,nz)
	if ncol and not checkcol(nx,pers.loc.z) then
		nz = pers.loc.z
		ncol = false
	end
	if ncol and not checkcol(pers.loc.x,nz) then
		nx = pers.loc.x
		ncol = false
	end
	
	if not ncol then
		pers.loc.x = nx
		pers.loc.z = nz
	end

	if zombi and not deathtrap2 and zombi.loc.y>4 then
		charzomb.isanim = false
		charzomb.time += dt

		local edx = (pers.loc.x - zombi.loc.x) * 0.1
		local edz = (pers.loc.z - zombi.loc.z) * 0.1
		local edist = sqrt(edx*edx + edz*edz)
		if edist > 0.3 then
			edx /= edist
			edz /= edist

			local ang = (1 - edx) * 0.25
			if(edz >= 0) ang = (edx+3) * 0.25

			zombi.rot = ang
			zombi.loc.x += edx*0.3
			zombi.loc.z += edz*0.3

			charzomb.isanim = true
		else
			deathtrap2 = true
			setmusic(8)
			time = 0
		end
	end

	local lastcam = cur_cam
	cur_cam = getcam(pers.loc.x, pers.loc.z)

	if not (lastcam == cur_cam) then
		need_paste = false
		tele_cam = true
	end

	local curcam = cams[cur_cam+1]

	sroom = curcam.room

	camtar = clone(curcam.tar)
	campos = clone(curcam.pos)
	camup = nvt(0,1,0)

	camdir = v_norm(v_sub(camtar,campos))
	camright = v_norm(v_cross(camup,camdir))
	camup = v_cross(camdir,camright)

	time += dt
end

function ent_compavg2d(ent)
	local p2d = v_sub(campos, ent.loc)
	p2d.x *= 0.1
	p2d.z *= 0.1
	ent.avg = (p2d.x*p2d.x+p2d.z*p2d.z)
end

function setcol(val,x,y,sx,sy)
	for i=x,x+sx-1 do
		for j=y,y+sy-1 do
			mset(i,j,val)
		end
	end
end

function checkcol(x,y)

	local px = 35
	local sx = 35
	local py = 50
	local sy = 50
	local dx = 0
	if room_number == 2 then
		px = 40
		sx = 40
		py = 62
		sy = 55
		dx = 64
		x,y = y,x
	end

	local pi = 64-(y + py) / (2*sy)*64 + 0.5
	local pj = (x + px) / (2*sx) * 32 + 0.5

	if pi<0 or pi>63 or pj<0 or pj>31 then
		return true
	end

	local v = mget(pi+dx,pj)
	return v==1
end

function dcol(offx)
	for j=0,31 do
		for i=0,63,8 do		
			local mul = 1
			for k=0,7 do
				mset(i+offx+k,j, min(band(peek(cur_addr),mul),1))
				mul *= 2
			end
			cur_addr += 1
		end
	end

end

frame_chunk_0 = 0x3E00
frame_chunk_1 = 0x4300

need_paste = false

strzombv = "7d5b907d5b8a768890650e766b1b76780f7081ce8481c88487c88462ad916fae9168c79e87c87e81c87e81ce7e6a41777755706b21767d5570850f7c780e8f6b1b89650e899baf5e9bbc5774bb6468c15e74c86b9bb6517d55777d558a7d55906b21897755906b418a63878163879187db8b8ddb848de18a75c79767c7656ece81638771768871705b706eae717bae77705b8a715b907bae8a6be5857aee857aee7edbb75ddbb150ceb7578ed5838ddb7e87d48487d57e8ed57f87db78e1aa5687d18487d17ecfb6aae2b0b0dbb6a374c7845cad819bbbaa68c0a475ba9e9cafa49cb5b074c87e7ae1748de179e2aaa962ae717d5b707c887d74da8b6ec7846ec77e76887d7d5b7774db787ae18f68ba977688846be57e87c37e88c384850f83705b77"
strzombi = "03022b555603030c0b2903031c2f2a03030c470a03035333030b033132250103025c3124250a040339373840040350454443070358522d2e2c24470303512d2c0503140605041407031113121e1011120503601716156007031f202122231f2113033f3b3d3e3c3a273b284f3536345d594e3f364f090335345a5426073c414209030e0d5e095f084607540703545446594d0f0e03033c272604032835265a06032e612458572d05031d1939181d05034b48434c4b06033c423d0f3f59030359543405030e5e4d5f460303364e5d03033b3a3e0507424109070805070e0f0d42090308240a4705080c0a0b250305084b4a482949070829290c2b47512c05085b4b494c480808191d1b181a191c1b0d085353302d2f512a2b1c563033530308302f1c070803030b3329552b0308565533030a282627030a4f3b3f"

function ptext(x,y,s,t)
	rectfill(x,y,x+s,y+10,1)
	circfill(x+s,y+5,5,1)
	circfill(x,y+5,5,1)
	print(t,x,y+2,7)
end

function _draw()

	if need_paste then

		memcpy(0x6000,frame_chunk_0,0x0400)
		memcpy(0x6400,frame_chunk_1,0x1c00)

	else

		cls()
		if selectscreen then
			rectfill(0,0,128,128,1)
			if not isintroanim then
				rectfill(18,4,114,48,0)
				rectfill(10,64,52,108,5)
				rectfill(10+64,64,52+64,108,5)
			end
		end

		fillsorted()
	
		foreach(bground, ent_compavg2d)
		if(room_number == 2 and cur_cam == 1) r2_1.avg = 10
		sortalltris(bground)
		foreach(bground, draw_tris)

		foreach(sortedback, ent_compavg2d)
		sortalltris(sortedback)
		foreach(sortedback, draw_tris)

		clearstatic2()
		bground = {}
		sortedback = {}

		memcpy(frame_chunk_0,0x6000,0x0400)
		memcpy(frame_chunk_1,0x6400,0x1c00)
		need_paste = true	

	end

	if room_number == 2 then
		if cur_cam == 2 then
			cpy = 40
			csy = 90
			clip(0,cpy,128,csy-cpy)
		end

		del(sortedreal, r2_bar)
		del(sortedreal, r2_bar2)
		if pers.loc.z>24 then
			areal( r2_bar)
		else
			areal( r2_bar2)
			if cur_cam == 3 then
				areal( r2_bar)
			end
		end
	else
		if cur_cam == 1 then
			del(sortedreal, pilars[1])
			del(sortedreal, pilars[2])
			areal( pilars[(pers.loc.z>15) and 1 or 2])
		end
	end

	if room_number == 1 and cur_cam != 0 then
		draw_tris(trap)
	end

	if selectscreen and not isintroanim then
		cpy = 0
		csy = 108
		clip(0,cpy,128,csy-cpy)
	end

	foreach(sortedreal, ent_compavg2d)
	sortalltris(sortedreal)
	foreach(sortedreal, draw_tris_checkanim)

	cpy = 0
	csy = 128
	clip()

	if room_number == 1 and cur_cam == 0 then
		circfill(-1000,10000,10000 - 42,3)
	end
	
	tele_cam = false

	if deathtrap1 or deathtrap2 then
		ptext(4,min(0,time*18-11),119,"you died alone ... in the dark")
		if time>1 then
			print("press x to continue anyway",12,16,flr(time*3)%2+6)
		end
		actmsgtime = actmsggoal
		acttxttime = acttxtgoal
	elseif finalvic then
		ptext(4,min(0,time*18-11),119,"you escaped from the mansion")
		if time>1 then
			print("thank you for playing",20,16,7)
			print("nusan - 2016",40,120,7)
		end
	elseif selectscreen then
		if not isintroanim then
			print("nusan - 2016",40,4,5)
			print("in",94,29,10)
			print("pico",94,38,10)
			local cm = selectpers and 7 or 0
			local cf = selectpers and 0 or 7
			rect(10,64,52,108,cf)
			rect(10+64,64,52+64,108,cm)

			print("emily",24,110,cf)
			print("hartwood",18,116,cf)
			print("edward",84,110,cm)
			print("carnby",84,116,cm)
			print("select your character",24,56,7)
		end
	else
		actmsgtime += min(1,max(-1,actmsggoal-actmsgtime))
		acttxttime += min(1,max(-1,acttxtgoal-acttxttime))
		ptext(0,128-actmsgtime,24,actmsg)
		if(acttxt) ptext(36,128-min(10,50-abs(acttxttime-50)),120,acttxt)
	end
	
	--[[
	if false then
		local debcol = (numup>1) and 8 or 7
		numup = 0
		print("cpu:"..stat(1)*100,96,0,debcol)
	end]]--

end
__gfx__
c7bdc1c7bd3ec7f33ec7be7078be7078e27078bdc1c7be8fc7e28f78be8fc7e27078bd3e78e28f78f3c178f33ec7f3c17000909080a040506070004040b06090
d0a0a00020c030f001e0107020c0a0407050c0a0f0d0e060705040502030100147afb847af47475047b8af47b85047b8afb8b850b84750b84000203010804000
60704050704080801060204050704020203050807060b798efb798fdb7c7fd4898fd4898ef48c7efb7c7ef48c7fdb7c79d48c79db7989db7989848989d48c798
b7c798b7983848989848c738b7c738b798c248983848c7c2b7c7c2b798624898c248c762b7c762b7981048986248c710b7c71048981050006070803090d00080
90a0f0e031217161b1a1f1e1504050604080a0504070103020b0d04030b090c0f00131417181b1c1f1d04040a0d0e01121516191a1d1e102d82be7d42be79552
e8262bd46352c68252e84c2bd4a92b979a52f5392b839a52c2dc52b3594e387e4e13594ef059fbf0ff4e387efb137e4e5dfffb38594e7f7efb5d344e5d59fb7f
124e3834fb5d344e1312fb3834fb13692b584c2bfabb42d9392b4cbb429cad42cb5000506020301030005020405000c0709080a0300090a0b0600032f1221202
e1210001e02111413161518171a191c1b1d1f001e04040103040504040c0b070a040403202f1e150403111d0e0f050409171d05131404091d0b1f0f7c84ff7c8
b7f7f7b7dfc8b7dff7b7dfc84fdff74ff7f74fa00030205040706080103020405030508070405040206010508be7508b0050b300388b0038b300388be738b3e7
50b3e7484ed7484e0248a3021e4e021ea3021e4ed71ea3d748a3d7038bef038b0803b308ea8b08eab308ea8befeab3ef03b3ef60005040706080106000514171
6181116020d0c0f0e00190704011118131512141304051718170406040205030708030403111215040602010308040704121611190e0c0c0e0a090b001d0f040
e0c0d0a0b0507a7a507a85508585af7a85af8585af7a7aaf857a50857aa040407050803010206040704040405020304050706080109516b995162a1616b99516
d5951636161636961636561696b616969516969516f6f516f6951677f516773616f75616671616687616689516689516c89516392616c81916b958162a59162a
2816d52916265916d5d816a65916a65916f6c816575916575916d7c816d7591658981658c816d86816d8a81649a816b9402b75402b8a300a2740378ae1a98a73
29751229751229f42d37752d2b752ca97545378a452b8aa92b8a452b75453775a937755f37752d16752d378a5f378a5f168aa92b755f37d82d2b8a5f2b8a300a
3940377540168a45168a451675a916755916d5a9168a2d168a5f2b755f89d89aa975a9378ae1a9759a168a401675404727404739a33775a3a975e13775e11675
123775e1168aa3168aa31675a3a98a7316757337757337f412378a12298a12290b73378a73168a73160ba3378a73298ae1378a9a378ada378a2c16752c3775fb
37759aa98a2ca98afb398a2c378a2c168afb378a1216751216f47329f47316f412168a12160b73370b12370b73290b1237f49a1675da3775da1675da16f4da39
8ada391bda168ada371bfb1675fb37f49a3775da3975fb3975da39f4da37f4fb168ada161bfb39f4fb16f4fb371bfb161bfb391b5ff8985f16d85f26985f8927
5f16755f37275f2667cf26985ff867cff8675f16275f3767cf37675f3798cf3798cff898cf266759162a95162a40162740175730995740163940170930990956
162a8616d58616f69516f7781649561639b61639d616c85616b95916b9d816267616f78816a66816f62816f68816579816e76816585916d85916499516d55916
26401657401609e0001303f7a5776797f5160687f21303e0004636e796c7567666b7a7d7264636e0003828298898f619c8d8b8e8183828e00058485927395749
f8096878c65848e000d9894a3a5a69f9e92a1a6ac9d9897030c2c244b2d2e2a69030e4e499d4b3332343e6303044d2557030757515a254c245703033334304f4
a3a8303015548570300404a3839375657030b2b2e263e55386b030b60507731724d334e3e414303017d337303099b3b93030c2a2b24030637353053030e434d4
30307583a2704075150385a595679040a7b526a636e296e5865040968656c5667040f5d50665f2750390406825c6b64807271737904088d6f6e6c843b8f4a850
4027375747f85040b8a818082890405c9aaa45bac2ea44558040a6b5d26455cada6c9040e6d623c3b3a9b90ac96040897914f3e3d37040b62505b45374c57040
65d59384a3940870409a9a45355495855040f3c4d347379040b9b999e9e469143a893040ea55da3040c58653304008a8a34040c91ab9e9605050a06080709070
5001e0f02b11314150508191718b2c5050e14cb1c1a170509271822c621c42505051103020fa40505060400b50501b80c0a0b040503b82726260504151614b6b
5b405051304b7b5050f1e1d1b19b4050abf021117050221202f1cbd1bb3050cbdb02605042223202fbeb5050624252320c60507a8a7484643590507a7aa4b494
c4c3f3a95050c0b0e0d02b50508a3c84a49430507a74b43050114161121c2612b52612b523121c23c7b523c7b526fa1c23fab523ddb523fab526fab559c7b559
c7b59cddb526dd1c2312b559121c59dd1c26ddb559fab59cfa1c9cdd1c9cc71c9c12b59c121c9cddc90cdd1c5968d923c71c237ad923dd99ebdd990a9e990add
b59cddc9e9ddb50addb5eb9eb5eb9eb50a9e99eb88a92368c5235ab5237ac5235aa923ddb50cddb5e988b523a00012027242625282f112029020c280e170c1d1
5040304020809070f050207151416122502041d0718191302050a2c15040b2c2d2e1c1704052e2f1a10232f23040f242025040d2c192a203905030205060a0c0
b0d04150509080e0a0b05050e0b03141227050d0d081c00160203050a0805090d0a1a132b13121e0f09090d081819101112010304050d0e222a161b130d031f2
32fe4db5fe4dc1fe05c17a4dc17a05c1fe05b5464dc1b04dc1b005c14605c14605b54605e946051e7a051eb005b5b005e9b04db57a05b57a05e9fe05e9fe4de9
b04de9b0051eb04d1e7a4d1efe4d1efe051eb08a2db08aca5705c1572ac1492ac1b0052d464d1e4905c1b005ca713012c17181d022e091b1a141516010302050
400270f1a0e130305002325030116101d1427030a0709080f011014030c1d181619050d0e0c031b0215060305050c0b0f0a090505071d001c0f03050b050a060
5060214131b1e0920aca920a8f92538f180a8f4d0a8f4d538f84898f4d53ca4d53c51853c54d0aca18538f9253ca9253c5920ac54d0ac51853ca1853c04d53c0
4d0ac09253c0920ac0d6538fd6898f080ac053abca53ab8f9cab8f53abc09cabca08abc0b4fcc09cabc54bfcca53abc5b4fcc518ab8f4bfc8f9cabc04bfcc508
fc8f49ad8f4bfcc049adc5b4fc8fa6ad8fa6adc008fcc049adc0b4fcca49adca08ad8ff7adc0f7adc5f7adcaa6adc5a6adca84538f7130808090b001e1122282
33c2736383f2420232d1f061e0517130d0d0301020a1b123d293e2734333a22262e1c1b0508060b0307393832342a13210f0d0e0d030f2536313c2b282721241
013190705051e0a01180c060505051a0219031505030c0d011e03050a08090b0d053531303b2f1729141213170d03020704081c07130d03070a390d043a29262
52c140506090d053f20302f1d191615190d04343e292d252b1402030d060c04030d0512191121cb9121c0d12c50d831c0d83c50d12c5b9b61c0ddd1c0db6c50d
94c5b9f8c576b9c54376c543ddc5b9ddc576dd1cb9b5c57612c576ddc50dd7c5b9121c76dd1c76ddc543dd1c43761c43121c4312c54306b50d06a90d44a90db9
1c4344b50d8020a1b191d0f1c08171902030205040e170d190c1302050e1024020319080709050e0e0314190a050603090502121b111d0b0c0f0719050606021
a01141b0e0f080d0b1a121516010302080d03180e001f0617181da7687a57687da76abda767ada797ada495ada79d8da76d8da49f8a576aba59aabd579aba5a8
4ada7614a57614da76f1da9a87a59a87da9af1a59af197b9f1da9a14a59a14a576f1da76f83b76f8da765a3b495a3b49f80879abd579fcda9aab0879fcd579df
0876abd576ab0876fcd576fcd5b6fc08b6fcd5b64d08f64dd5f64dd5f68d08b64d08478dd5478dd547dd08f68d0877ddd577ddd5772e0847dd08b72ed5b72ed5
b77e08772e08087ed5087ed508ee08b77e0879df0808ee08087e08b6fcd5b6fcd5087ed5961d08961da5a8e8a50ae8c50ae8a50a4ac50a4ac5a84ac5e92ac5a8
e8c5c82aa5c82ac5e909a5c809a5e909c5c809a5e92aa5492aa54909c54909c5492ac5592ac55909a5590997b8f1e8b8f1c8c8f1c899f1b799f1e8b9f1b7c8f1
3b765ad5e7ae08e7aea5592a400062725282400092b2d2a24000c2f213e2400003335323400043739363400083b3d3a34000657555854000a5b59566700004f3
e3c32234f1300004e312b000b1b191a190d160c1b136a1a0008474a494b4d0d4648474b00005053515e4f4c445052515a000e5d5f516065126c5e5d540101525
f445603022f112e1523250301214045456503046443424f150301161e031019030d0d0642021f071814150306242f1c0e130302212e38030e010117002503040
303070108090306464742194b0d0a0204040a59575855040b140605070504060709080919040e4e435d40584c4a4b44040d4e4b4c44050625242324050729282
d24050b2c2a2134050f203e2534050334323934050738363d34050b3c3a3f3405026e506f57050301020e0f0018130503020a070d042a0c0b0e1023030d0e130
3290d0010181c541513116d540d031d501c5fa3633fa46e5faf736faf790fa4b9038f79038a79039a790fa4b33fa4b36faf733fa0790fa070138a73338573339
579038a73339a79038a633383633fa361238c53338c5c3fac5c33855c3fa55c3385554fa555438f454faf45438f4c4faf4c43874c4fa74c4387435fa74353814
35fa1435381416fa1416fa04c5394790fab533fa8601f3f736f34b36f3d967fa1416fa14e9fa461afaf7ccfaf7c9fa36ccf3f733f3a736f3f7c9f3a7c9f3f798
f3f7ccf34bccf34b6ff3f790f3a73338f76ff3f76ff34bc9faf76ffa07fef34b33f3a7ccfa4bc9fa4bcc384b6ffa4b6f38a7c938a73638a76f39a76ff3a76f38
a7cc39a76f39576f3857cc1a576f3807cc1a076ffa076f3836ccfa36ccfac5cc38c5ccfac53c38c53cfa553c38553cfa55ab3855abfaf4ab38f4abfaf43b38f4
3bfa743b38743bfa74ca3874cafa14ca3814cafa14e9fa043afa076f39476ff3a790f3d998f3b968f3f767f39798f3f768f3b997f39767f3f797384b9038a790
380733fa07901a0790faa612faa601fac533faa690fa93c5f34b9038a7ccfa36ed3814e9faa66ff39768f39797fa0701fa07fefaa6fe38a6ccfaa6ed8c36cc8c
043a8b056d8c57ef8b26ff1a5790fa36338be2ea4000f001e0214000415131e7400091a171814000d1e1b1c140001222f1024000526232424000152505354000
95a585b54000c5e5d5f5400006261636400046665676400086a696b64000b7d7f0494000f7a831b74000610841594000456535554000b8c855d84000e858d885
6030905040608070603044e634e404d450304080c0a218f030d39404a4348433744330201092b228c0300414d3b3c3832417e2f2d237403078f6e6e430301783
a3703069690919f839296030c0d040b090a0703074a030b010d0c27030d6d6132303209270309738e35463e2d2503033435323d64030509760e3303010c2b240
3053443334303043202330404535253040f731e73040855895304001f04930405141593040d8c8e84040e02111a74040718161084040b1c191a14040f102d1e1
404032421222c040885747a3938364b3f414d4044040657555b84040a5c5b5d54040e506f51640402646365640406686769650407268c6b6a64040d7b7c7a850
4062528272c64040d41548059040706007e3f36373d23770409877873767f2175040671727a3573040377773d050d4d4f44864b493c473e0f37007f7f759f7a7
59f7f728f7f928f7b908f74b59f79728f79708f7f997f74b87f7b9975030a06040103030304090a05040102030708070408080305040b090f7f7a6f74ba6f7f9
d7f7a7a6f7f7d7f7b9f7f797d7f797f7f7f968f74b68f7b968503050103020a03030a0903050408070504010504050306090b030406080505a77f7d908f7a608
f7d99957d9085716bff7a62ff7d92ff71677f75abff7a69d57d99d57d92f57a62f57a60857a69957d708f76808f7d72ff79649f7d949f796e9f7965bf7d95bf7
96ebf7964df7d94df796edf7d99b57a69b57682ff7d9e9f7d9ebf7d9edf77000d0c080d12040505000205030f0015000e1b070e0d03000d08070400001e13070
7010b0e1d10140f0505010d1c0b0d0e04040f1312111404002615141404012918171404022c1b1a1a04030706080a02010309060d55b76d55b89d58b492a3c76
2a3c892a1c49d53c89261c89866bf88618f8e518f8d53c761a6b791a18791a18f81a6bf87918f8866b79861879c98e76368e76369c76c61f76391f76885f76d5
ae76d53c762a3c76c99c76765f7657af762aae76895f76a8af76775f76796b79791879796bf8e56b79e51879e56bf81a6b071a18071a1886866b078618078618
86796b07791807796b86791886e56b07e51807e56b86e51886d91c89268b892a5b89d98b892a1cb62a8b492a5b762a8bb6d51c49d51cb6d58bb61a6b86866b86
4000e0f0d001400031a021904000115262424000b08292724000b2c2a2344000e2f2d24440003313230340007353634380002414c00470302010a0006050d3a3
f3e3c34060504000302410c04040a0b09092604093807050c0404040f0110162404052e042d0404082317221404013b203a2404053e243d2f0400202c1d1b161
a151e171f1322291816040d1024112812270405050a3b32093704040808350b3506071514161d1506041817191324090809383b3409060d3c3f3409014240430
d9c9acc4c9acc4da6ec489d8d989d8d9c9b4d958acd958b4c458b4c49af0d958d8c40b72d90b72d99af0c4c9b4d9da6ec46aafc458acd96aafc9587cc9982dc9
272df8277cf8587cf8982df8272dc958d4c927d4c92724f827d4f89824c99824c9277cf858d4f82724400090a080e04000703121114000814171124000a16191
514000c1b1e122400002d1f132f03031311101301020504060f0d0c0e0a0504050107001314040516141124040c1d1b1025040e0d080605040408050b070a459
faa459a5a428a53b59a53b28a5a428fa3b59faa49ffaa49fa5a47ea53b9fa53b7ea53b9ffaa47efaa49ffaa47efaa47ea5a49fa53b7ea53b9ffa3b7efa3b28fa
3b7efa3b9fa54000405020304000617060104000b0c090a0400080e0d07190108181312111f0014151404020301060404090a080e0a108e72c08e72c0847a108
ea2c08ea2c084aa4085d65085d6508d468085d29085d2908d465084a68084a6808e72908472c08472c08d4a10847a40847a408d46508476808476808d4a1084a
a4084aa408e7a1085da4085da408ea65085d68085d6808ea29084a2c084a2c08e729085d2c085d2c08ea2c085d7d086e7d08c350086ea1085da108d42c08d4a1
0847a1084aa408d46808d46508e72908d4a108d46508d4a108e7a108ea6508ea2908e72908ea5008c34060203010f24060506040034060809070134060b0c0a0
234080e0f0d0334080112101434080415131534080718161634080a1b191734080d1e1c18340800212f1934080324222a34080627252b370e0d2d2c2b28292a2
70e08282e2a2d2c3b2f3c41ff3c4e0f331e00cc4e00c31e00cc41f0cf3cdf3311f0c781f0c78e0f378e0f38ce00ca7cdf3781f0c8c1f0c8ce00c6932f38c1f0c
69cd0c9b320c9bcd0c95cd0c95320ca7320cf3320c02cd0c311f0c0232a010f001c0a0b04020503080a010c021f0e090106080b1509020c0c021b0e020103080
b0201111410151f0319011a001a02081a0d0906160714081a0b0205050b1a16070409150c1a14040114131514040718161d0404070a191c16933ba6933bb6912
ba4812ba4812656912652533bb697ebb2520bb2612bb4812bb2612ba2512ba2512656920bb26126569336569334469ad65253344261244252044481244692044
257e4469adba257ebb697e446020f020b070a090702081812171415161902041412191c1b1807020d0402121816071505101e0c0d0a090304051e061b040f0f0
20301060112131c18050403180a1201070406060503040b0a0304030f0b05040a0c04001504090113110a1957b5e957b79b6f9aa6a7b796a7b5e49f93db6f93d
49f9aaca2daeca2d292aceb9352dae2ace1e352d29d5ce1e399f1d399fbac69fbad5ceb9c69f1d08f97c77f96b77b80b88f96b88b80b08e7eb0877e77768c788
68c74040308070604040112101417040d191b1a17151614040a19151813040b171c1b090010111d0b090a050406080b0907070301020c0e0f0314121b0904141
01f0d0c09010507060c408603308a1e408a19c0881ab0833bc0843140813b40854650813c208542408f5b308d77408c7cb08873b08496c08874308596308ba94
0859d508ca65086c6b087c24086c24081e33081e2408afbd08815a08606a08541b08549b08b56c08b53b08ea6c08fabb0849eb082e0c087cfa08af8d083ed208
067050b1b140c130102050506040503090b0500101f0e0d0f1b0d18090703050d0b0c08050223212f0413121116050526142518171605072426281a1914050e1
50d1903050d1f102405082b0a0804050516141123050f0d031952c0546e957860da7860d85c97c05390da769e957297e77187e8798fd77588d38578d48d70d38
b77e77b67e8747fd77361e45361e77d74f26d7cc48791e77d499c6f54bc664da16d37846b619b7e4a94696d9a7e819b79a99c60bda16994bc6d7e9d7d91e653a
5f55499fb5367955390d85797955791e45569fb5e51e65d6ae95855f55c52c1609d9a7c92c169aa9468b7846b8ae953000a080903000d0b0c0300001e0f04000
a1d1c1e24040d28171614040c1b1a1914040f202f1e1404032422223b0408282625160411230201052504072507060124040b292a2c24040e2d1031360403111
2140301030406260506040304121513182d76928d769d7d7d7d72869d728d7d728692828d728d7d72848c94848c9b7b7c9b7e79be7b7c948e79b18c7cb38189b
e7189b1838cb38d71c28c7cbc738cbc7281c28281cd7285ed7d71cd7285e2838bec7d75e28d75ed7c7bec7d7dfd738be38c7be3828dfd728df28d7df28b00091
41f0c0e0b0d020103080b000612151110190a060407050900051716181a1b10222329000f03191c1d112e142f1b04071514101c0a0b040205030b04031f021e0
11d090106080709040419171d181e1b1f1229040216131a1c102123242c45f9fc45f60c4e7603b5f60a95f21ca5f943b5f9fc4e79f085fde355f0ea9aa21ca5f
0ecaaa94565f2156aa21355f943be79fcaaa0e4050108070114050e0f050b0406020301080606021c0d060b050907090a0100120e04050605070406070c09030
7090107067a84349c74349a84367c7d267c743672f43677faf677fd2672a43671bd267d9d2677b43677cd249f84367d94367f84349d9d249c7d2671b4349ddd2
497cd2492a43497b43677c4367bc4367bc3f67a83f67c7af67f83f67ddd2497fd2672e4367dd4349bc43491bd2492e4349f83f672a3f492a3f497b3f49bc3f67
7b3f672e3f492e3f497faf671b3f671baf672f3f49c73f49c7af67d93f67d9af497caf677caf677c3f67dd3f67ddaf49a8af49ddaf67c73f49d9af491baf492f
3f491b3f49dd3f497c3f49d93f49d943491b43497c4349dd43492f4349a83f500011214020505000e00152d133500061907262e2500071c082a2735000229192
a18350004202c2b203500023c113c3b13000f3c20330000472e2300014928330002482733000345233d00070d280f1e141d051a032b011403000b19413401030
102050401001e0f0444010906131544010c0718164401091221274401002426084d010a323c1d343e3f25363b393d27080406290f0b0014010509040f0f06233
43d1c1b1c390409112e10280607003b26040a2c031a090b06040a19181d0c0a03040d091e140400110d1b190400212b28393a16373a27040434362f2e2a23130
408173a13040b293703040a2f263194c07194c19192ce8e64c19171c19376bb83718b8f618b8e64c07096b090918090918b8096bb8b818b8376b09371809b86b
09b81809b86bb8f66b09f61809767f78189c78189c28096b67091867091807376b67371867371807b86b67b81867b86b07b81807f66b67f61867587f96189c38
789c48e81c19179b19e66b19196b19e89b19192c27198be8196b07f66bb8767f28096b07376b07a87f96198b274000b0c0a0d040000170f0604000e021311140
00718161134000a1b191234000d1e1c1334000220212f1400062725243b000f2f2b2e2203010d2f253e240407080600360409250402090104040c0e0d0314040
21b011a04040510141f0404002a1f191404042d132c170402020b2c2a292404040508220c24090509282c2409030e2d25374af28744b28b49b28369b28b45f28
f70828f74b28c7ea2806ea28b4ea28b4682874082836082806682876ea28766828c76828361b28f54b28764b28c79b28c75f28f7af2836682874afc7f74bc7f7
08c7744bc7f7afc77408c7c000e1c0c1209110d171a170b160504051614050304040a0b090e040400111f080d0904121f08101d0116080704151406090b0a020
3130405090203010506170908181d0e0c0b0205090e081902131509051706171103090a0903130908041f040a02141314008747508748a085208083b3c083bc3
08fc750837db27079c08372427076327a30b27cbe227a3f408fc8a27cb1d27fdf427210827fd0b80400121e0f0408070208040b01130d010a09050404080b020
307040a0a050c06001e090c03010209070504060e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111100000000000000000000005500505005505550550000000000000055505550550050000000000000000000000000000001111111111111
11111111111111111100000000000000000000005050505050005050505000000000000000505050050050000000000000000000000000000001111111111111
11111111111111111100000000000000000000005050505055505550505000005550000055505050050055500000000000000000000000000001111111111111
11111111111111111100000000000000000000005050505000505050505000000000000050005050050050500000000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaa000005050055055005050505000000000000055505550555055500000000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaa000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaaa00000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
1111111111111111110000000aaaaa00aaaaa0aaaaaa000000000aaaaaaaaaaa0aaaaaa00aaaaa00aaaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa00aaaaaa0aaaaa000000000aaaaaaaaaaa0aaaaaa00aaaaa00aaaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa0aaaaa000000000aaaaaaaaaaa0aaaaaa00aaaaa00aaaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa0aaaaa000000000aaaaaaaaaaa0aaaaaa00aaaaa00aaaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa0aaaaaa0000000aaaaaaaaaaaa0aaaaaa00aaaaa00aaaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaaa0aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaaa0aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000aaaaaaaaaaaaaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaaaaaa00000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaaaaaa00000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaaaaaa00000000000000000000000001111111111111
11111111111111111100000aaaaaaaaaaaaaaa000aaaa00000000aaaaa0aaaaa00aaaaaaaaaaaa000aaaaaaaaa00000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa0aaaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa0aaaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa00000000aaa0aa0000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000a00a0a000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000a00a0a000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000a00a0a000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa00000000aaa0a0a000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa00000000aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa0aaaaa00aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa0aaaaa00aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa0aaaaa00aaaaa0aaaaa00aaaaa00aaaaa000aaaaa000000000000000000000000000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaa0aaaaa00aaaaa0aaaaa00aaaaa00aaaaa000aaaaa00000000aaa0aaa00aa00aa0000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaaaaaaaa00aaaaaaaaaaa00aaaaa00aaaaa000aaaaaaaaa0000a0a00a00a000a0a0000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaaaaaaaa00aaaaaaaaaaa00aaaaa00aaaaa000aaaaaaaaa0000aaa00a00a000a0a0000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaaaaaaaa00aaaaaaaaaaa00aaaaa00aaaaa000aaaaaaaaa0000a0000a00a000a0a0000001111111111111
1111111111111111110000000aaaaa000aaaaa000aaaaaaaaaa00aaaaaaaaaaa00aaaaa00aaaaa000aaaaaaaaa0000a000aaa00aa0aa00000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111117717771711177711771777111117171177171717771111117717171777177717771177177717771777111111111111111111111
11111111111111111111111171117111711171117111171111117171717171717171111171117171717171717171711117117111717111111111111111111111
11111111111111111111111177717711711177117111171111117771717171717711111171117771777177117771711117117711771111111111111111111111
11111111111111111111111111717111711171117111171111111171717171717171111171117171717171717171711117117111717111111111111111111111
11111111111111111111111177117771777177711771171111117771771117717171111117717171717171717171177117117771717111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111117777777777777777777777777777777777777777777111111111111111111111000000000000000000000000000000000000000000011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
11111111117555555555555555555555555555555555555555557111111111111111111111055555555555555555555555555555555555555555011111111111
111111111175555555555555555555aaa95555555555555555557111111111111111111111055555555555555555544444455555555555555555011111111111
1111111111755555555555555555a9999f9995555555555555557111111111111111111111055555555555555555444444445555555555555555011111111111
11111111117555555555555555a999fffffff5555555555555557111111111111111111111055555555555555554444444444f55555555555555011111111111
11111111117555555555555555999ffffffff55555555555555571111111111111111111110555555555555555ffffffffffff55555555555555011111111111
11111111117555555555555555999ffffffff95555555555555571111111111111111111110555555555555555ff7ffffffffff5555555555555011111111111
11111111117555555555555559999ffff7ff795555555555555571111111111111111111110555555555555555ff77ffff77fff5555555555555011111111111
11111111117555555555555555999f777fff795555555555555571111111111111111111110555555555555555ffffffff77fff5555555555555011111111111
11111111117555555555555559999ff7ffffff5555555555555571111111111111111111110555555555555555fffffffffffff5555555555555011111111111
11111111117555555555555559999ffffffff95555555555555571111111111111111111110555555555555555fffff4ffffff55555555555555011111111111
11111111117555555555555559999ffffff2f99555555555555571111111111111111111110555555555555555fff444f44ff555555555555555011111111111
11111111117555555555555559999fff222ff555555555555555711111111111111111111105555555555555555ff44f444ff555555555555555011111111111
11111111117555555555555559999ffff2fff555555555555555711111111111111111111105555555555555555f44fff44f5555555555555555011111111111
11111111117555555555555559999ffffff5555555555555555571111111111111111111110555555555555555544fffff4f5555555555555555011111111111
1111111111755555555555555555f9ffff5555555555555555557111111111111111111111055555555555555555fffffff55555555555555555011111111111
1111111111755555555555555555ffffff7333333555555555557111111111111111111111055555555555555555ffffff355555555555555555011111111111
111111111175555555555555555ffffff77333333555555555557111111111111111111111055555555555333333333c33333555555555555555011111111111
11111111117555555555555555537777777733333555555555557111111111111111111111055555555553333333bbccb3333335555555555555011111111111
111111111175555555555555533377777777333335555555555571111111111111111111110555555555333333bbbbcccbb33333355555555555011111111111
1111111111755555555555533333777777777333335555555555711111111111111111111105555555553333bbb3bccccbbbb333333555555555011111111111
1111111111755555555553333333777777777733335555555555711111111111111111111105555555533333bbb33cccccbbbb33333555555555011111111111
1111111111755555555333333333777777777773335555555555711111111111111111111105555555533333bbb3333ccc3333bbb33555555555011111111111
1111111111755555553333333333777777777723333555555555711111111111111111111105555555333333bbbb333c33333bbb333355555555011111111111
1111111111755555533333333333777777777722335555555555711111111111111111111105555555333333bbbb333c33333bbb333355555555011111111111
11111111117555553333333333337777777772223355555555557111111111111111111111055555533333333bbc33ccc333bbbb333355555555011111111111
11111111117555553333333333337777777772222355555555557111111111111111111111055555533333333bbccccccc3ccbbb333335555555011111111111
11111111117555533333333333322777777772222255555555557111111111111111111111055555333333333bb2cccccccccbb3333335555555011111111111
11111111117555333333333333322277777722222235555555557111111111111111111111055555333333333bb2ccccccccccb3333333555555011111111111
111111111175553333333333333222277777222222255555555571111111111111111111110555533333333333b22ccccccccc23333333555555011111111111
111111111175533333333333333222227777222222225555555571111111111111111111110555533333333333b22ccccccc22b3333333355555011111111111
111111111175533333333333333222222772222222255555555571111111111111111111110555533333553333b222ccccc22233333333355555011111111111
111111111175333333333333333222222272222222555555555571111111111111111111110555533333553333b2222ccc222233333333335555011111111111
111111111175333333333333333222222222222223555555555571111111111111111111110555533333553333bb222cc2222233333333335555011111111111
1111111111753333333333333332222222222222335555555555711111111111111111111105555333335533333b222222222b33333333333555011111111111
1111111111733333333533333332222222222222335555555555711111111111111111111105555333335533333b222222222333353333333555011111111111
1111111111733333335533333332222222222223333555555555711111111111111111111105555333335533333b222222222333355333333355011111111111
11111111117777777777777777777777777777777777777777777111111111111111111111000000000000000000000000000000000000000000011111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111177717771777171117171111111111111111111111111111111111111111100010011010100010001001111111111111111111111
11111111111111111111111171117771171171117171111111111111111111111111111111111111111101110101010101010101010111111111111111111111
11111111111111111111111177117171171171117771111111111111111111111111111111111111111100110101010100010011010111111111111111111111
11111111111111111111111171117171171171111171111111111111111111111111111111111111111101110101000101010101010111111111111111111111
11111111111111111111111177717171777177717771111111111111111111111111111111111111111100010001000101010101000111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111171717771777177717171177117717711111111111111111111111111111111111110010001000100110001010111111111111111111111
11111111111111111171717171717117117171717171717171111111111111111111111111111111111101110101010101010101010111111111111111111111
11111111111111111177717771771117117171717171717171111111111111111111111111111111111101110001001101010011000111111111111111111111
11111111111111111171717171717117117771717171717171111111111111111111111111111111111101110101010101010101110111111111111111111111
11111111111111111171717171717117117771771177117771111111111111111111111111111111111110010101010101010001000111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

__gff__
06042c181a191c1b0904222928242a2321262705042820221f250d3a440d3abb0d4e9ff23abbf2b1bbdd9dbbf23a44f24e60f2b144dd4d440db1440db1bb0dcbaa229d44dd9d44229dbb224dbb0d9c9f0d9c600d4e60f29c60f29c9ff24e9f0dcb550dd891f2cbaaf2cb55f2d891f2d86e0dd86edd4dbb224d44060113120c03
02010601161509080704060109051604170806010c0b1301140304020107020407021e1e19180d0b0c04021314120304021617150807021c1c1d1a1b05090b03040402110c100506041f110b030101070a090f0b0e01200a040d0f0a0e20040d1011061f070d1c1d1e1b18090b070d1e191c0d1a0c0500000000000000000000
__map__
8bea7a8bea778bec788aea838beb828aec866b9fa2719f9c71939c84178b78188586528b85e7727be97285ed7385ed8a7bea8b85e78b8be5828bef7f8be57b91e57f89db8689db7871997f7d9e9173c8966f6a79865e798d817f72186e78187a74477a8417748652746f6a85865e857447857e176e7b5e977a47977a47687a5e
686a76a87676a2707ca2779fa27193a87793a2719fa87db09072b0906b94a289f67f85f18885f17579f48473c86772c27379d37f7fdf7879dc7f73eb76888c6e7ec76d7d9e6d78188b6c0d8b890c97888d917ec79076879676876889d77f8de37f7c817f6a827f73c89672b06d7db06d73c8677ec76d7ec7678ac77f8acd8a8a
c1857ec8967ec79073eb876b9f5c719f566b935c71935676935c779f5c719f62721891890b688f0b746c0c748f0b8b72c28a75709c8ac1798acd738ee57f7e18916b88748bbc8a8daf7f7fd17f8bbc736b888b707c566a7c5c767b5c719362707c627fdf8675765c6a7656707c5c757062756a5c756aa27818747fd3797fd385
79f479707ca8767ca2707c9c6a7ca28beb7b8aea876a76a8707ca27676a275709c756aa275765c707c5c6a7656757062756a5c0600444365454443060063627e6463620c01196c4d1c4c1e2425260c0b0a0901202223272a1f2120230801487128242926610b060148280c296b6103010c6b0a07011c6c2b4923401e05014c24
4d71190501251e0c46480601231e1d1c212a030121231d04011c2b2a2304026d1e6e70030356545503035468690d031e4041423a193b663c1b80476f070366191b1a47461e06033b3c3a7f416f050319711a484605034049426c190f03838431092f0833344e0732353082830f0374725d5c5b5a514f50605f755e767407035e
5e5f5b5351520603312f32574e5804035250535f04032f335758070372735c755a604f0303757376070334080709358582030309848504033230318304035b5e5d740b0412101137393681380e0f0d0504174b6a18150304176a1304043714363807040e3d3f3e59771107040e0e813f39591104070203018604070506048704
0b6f476d1e040b1e41706f040c706f6e6d0a0f4b174a6f180d150f1438070f6f171213101437050f672e2d2c7d050f7c79787a7b050f806f771211050f0e0d3d6f7f050f8c888a898b050f908e8d8f91030f4b4a18050f1413166a15050f80773c3e3d030f3d7f3c030f1416158ce8858cea818aea878cea7e8ce87a8aea788a
c47386d0808ac48087e28a88da878ce085850d7a850d74910d7a8ac48c8a988c8a988096b193908b8090b1808a78677185678a98738b46737e4c6d779873781a747e1a7a7e4c7a7e1a7483b76796b16d85ef7785f17588f67f70bd9283b79971989f70b79f7dca997db79f6b7e806b98997172a57f13747f137a71b7607db760
7197607dd0877dca668de5828ceb8085ef887185998a78998b468d7e4c867e4c9377988c7798808ddd808dd98088da788ce07b70bd6d6b975a6b725471725a71eb7974ed8678f57f716ca5656cac715fa56572a56b72ac64989f6b72a56b729f7dd07884d7807ed77c7eda788b467a9172807e148d7f1486850d877e1a867e1a
8d910d87780d746b98a571659f85eb7387dd727eda7587e2758b4686781a8d6b97676b726070bd8087dd8d7ed78390e6808de57d8ce0808ee18085eb8c85f18a7eda8a78dc807eda8770db806b725a716561716b5a88f47f850d8d64976065725a780d8d715f5a656b54716ca5715fa5656cac6b72a571659f6b725a716b5a71
6561656b54715f5a0d001f2e1c5e2f2e0e1f0f1d0d2f0e03001c2f1d0d005b59667d58595a5b5d5c7a585a030066585c03000f0d0e03005d7a5a09013b3b1e2b1a17191657070157393a383c2b3b05013a6557561905021013151221030207152105023f426e6f0c03020c3f6e1903121311263d253e69433430313220431b3e
2b3d3811391457160703111112141816170703072120181b172b0b034d4e4f5f28272a262910330b0346453244307b436732684607032627252c4f514d07032933695234072005032c272d5f4e03032c2d51030321121803031026130503457c7b686705032a2928254f03033420310303457b44030329692503070301020307
060405070707071509100833040709070852060961232224793707097374720b6a0a3707092264624163557303092262610509247137706a040963737572090a6a7072487547636162070a70714849472361040a23492471050f60504a4b4c050f7e7f787677050f8182808384050f8785868889150f0b746b7354555341403f
0b0c0a6f356d6c3635370a090f1f561d1e1c1a1f1956060f6d6f6442413f0a0f3308535254336b530b40070f3c3c3a5c655b66050f5c3c663b65070f37377936226d647795167795047780044c802d698041508023808041778016d99516c09516bf8016b6802dd98023c29504d99504d9bf046980cd7e80946980b1c3809ed9
809ed9807fb1802daf801698806ab5806ab58038c38060d98060d9804126bf232680232aa1233c80605380606980608080605380cd6980e38080dc888088ac809eac807f82807fc780d9d980dcd980bd508004c3804151808769809f69807f5280bfc3807faf80c2c780b7d9bf2398803888807f3c802350bf233c802a268060
26804126807f4a80805180809680dc3c80d42680d4308bd4378bd4378bfa3c80f44f80d93c80dd5380e35380fa6980fa8080fa9680faac80fab180d9c380fa2e95d42e95fa3c8bd42695fa4280d73c8bfa2695d450bf0438802338a12338a11f3cbf232aa11f2aa1082a80232a801f38801f2a800838800838a1084ea11f4e80
1f4ea1084e800826bf4226bf6126bf7f26bf9e2680bd26809e26bfbd26bfd4d9bf6069bffaacbffad980fad9bffad9bf9ed9801696bffad9bf7fd9bfdc308bfa53bffad9bf41c3bffad9bfbd80bffa31bffa26bffb3c80fa3cbffab0950477bf04af9516b1bf04c2bf040400020301080a008d8c0e890a8b0b180c1704002711
4d260f0087875a4a4c4b5926351333122c293b0d0065656a696b5f6862666164216305007073727132050004063c3d600800548278792e7e2f83030072324209004546475b55585686850600782e542d533709004c4557485a49567f4703004845470600655d5f5e612106006a6b6c68676604005a56888505002e2f2d383703
005647550300625f61030069655f03005a4c570402305c063d050246715b73740902201f406d3f6e416f7005027b0d0939100c02390d811e751d7d167a15832f030270724104028658745b030209100f04030a0b097b04030818018b04040f0e090a040489028b0109055151504428121113260d050b0c0d311e1c1d36161415
382f13050404060508073a25193b2b292a1237445352540a053b252c3433323545594c0b05250724052304223e4063200405327145460605874e4a4d4b260605403f2241427203050b0d7b0905043c3e5d63656467660405656a676c04050330080605054f502728110705310c1b173a1808050537382a143604054f274e4d03
0544515207052524342343423205052a362b1a190505361c1a311b0305344332030523224204061a1b193a04077f494748040d0f100e8d050d8a5c0230030e0d825477527c518450764f804e5a87050d601f212063050d5d3c5e6021030d5a8880040d8c8a89026667c76662b56633c79a62b59a33c79a67c7663bd99a3bd99a
31d99a89b39a7c90667c90667c796689b366b07f667c5f9ab07f6da4b36dbf9575c1ce94a4b394bf9575dcbb8cc1ce9ab04e75b3e78cb3e78cc0f175d6e275c0f19a6e4b666e4b66372c8cdfd18cd8e175dfd076ebeb7ae0db9a7c799a7c5f668e3366b04e74b63a87e0db8bebec8cdcbb9a8e339a3d209a372c9a351c663d20
8cb63a8c7e16747e166631d96629c79a29c79a248d9a42f69a2d28662d289a1c55661c5566351c664d079a4bf5664bf56642f69a1a8d661a8d66248d9a26556657089a57089a4d076626551903483c3132304b4a49334140323d3c3e483a47033837390905080903292a2b34352f36292b04032f34192a0b034444074308423b
443707030b0303053a3945463f474c483106033f4c3d21403303034a3330030331214c0403083b093705033a453e3f3d0303444243040347463839030335362b040332414b490504192a0f100d0504272811190f03062d2c23070613131714241d2507062121332029102a09060d0d0f0c0e0201030704061d141e1a05061413
120f0e04072425261d07072c2d2223181c1b060731301f2f2819080727110b0a0406050807070a111516182e220b0f232c2622242e171613110f040f2f3029330f0f3131211f202810270d0b0c04020503090f1412150e0a01060708080f1518141b1a1c1e1d040f261d231c63b59c63ebae63c09c6c689c6c68636368636c68
526c5852636852b568aeb56852639c9c6368ae63a89c63d89c63eb9c63faa76c58ae6304ae6c04ae63689c63586363589c6c68ae6c9c636cebae6cd89c6ceb9c6304526c04526cb59c6cc09c63049c6c589c6c049c6c58636304636cd8636ceb526ceb636cb5636cc06363eb52639c6363a8636ca8636cfa586ca89c63b56363
eb6363fa586cf47063c06363d8636cfaa76c9c9c6cfa9c63fa9c6cfa6363f48e6cf48ea55852a558ae63f4706c046363fa6307001a1a180d12131404000519062c04001625244104002e292d3104002a2635360400283b32420400123f180a05000d1a02371106042e303818040a06040c150d17132107042c2c0609161d2507
0438382e1907050b070403030f0210113a07042a2a2627282f3b060435362b3233420604201b1a1c373904040616151709040c0d0e02010331352b060418301a1f202a06041c1b3d2634280504312b2d092c070407072e27292a1f04042d2c0e0c0704323240363c0f10070915150604050a0b0a093b2f33272b0709081d1e04
092223172105092e2d300e0105092a3520030f0509283234403c04090b3e07080409150c04380309011f3003090f1b20050911373a391c030933423b0609343c3d101c3a2d2480452445450645807f1f3b7f3b45c44580242dc47f3b8024d24524ba4506ba1f7f80ba2445e07f80d22480ba24bad206803b7fc4807fe045c4ba
c47fc480062dd2c4808006d2bac4baba064580c42dbac445d2e58080c4d280e5d22dc4802de580bae54580e52d45e54545e5ba80f980bae5ba2d0680ba06ba0504271d26222305042125261f27040421262423110414141e131915170e1c081b0406050c010a10040c0a12091310150f0e0d08070402050107040606200c1412
130b060f0f0d1a0716020301280b090601010a0b0918102911040610110f1a130619191e1f1425202106241b231c22171d19271fa11b32a11b1fa1011faa1b1faa011faa1b32aa0132a101324d1b1f561b1f56011f561b325601324d1b324d0132a11bdfa11bcca101ccaa1bccaa01ccaa1bdfaa01dfa101df4d1bcc561bcc56
01cc561bdf5601df4d1bdf4d01df4bfa1dacfa1dac1b1dacfae3ac1be3bb46cb4bfae34b1be34b1b1dbbcf35bbcfcbbb46354d011f4d01cc04000405020304000a0b092b04001017151604001d1e1b1c050025262223240600282a20211f2703002429220804050407060801030206040b0a0d0c0f0e08041710121114131615
__sfx__
00140000135421f200135401654013540155401654016542155401654015540165401554413542135421654013540155401654016542155401654013540165401454014542145441852014540165401854018542
001400001654018540145401854016544145421454218540145401654018550185521455018550165701457013570135721355213532135121f5051a5441a5421f5341f5321f5321f5321f5341f5321d5441d542
002800001d5421d5441c5341c5321c5341b5241b5221b5241a5441c5441f5241e5441c5441a5441c5441c5421c5441e5341e5321a5441f5441f5421f5441d5341d5321d5341c5241c5221c5241b5341b5321b534
001400001a5441a5421f5541f552225442254221534215321e5341e5321a5441a5421e5341e5321e5321e5321c5441c5421a5441a5421a5421a542265242a52426524285242a5142a512285242a524265242a524
001400002852426524265222a52426524285242a5142a512285242a524265242a5242b5142b5121f535225351f5352153522535165021b5351f5351b5351d5351f53522505165751b575165751a5751b5750f505
001400001b5751b5551b5651b5451a5751a5051a5751a5451a5351a5551b575000001a5751a5551a5651a5551b5750f5051a5751a5051b5650f5051a5651a5051b5750f5051a5721a5421a5521a5721354213502
000100000a73008730077100771005620056300563005630056200562005610056100561005600056000560005600056000560006600066000000000000000000000000000000000000000000000000000000000
00010000077200c730086300864007720077100561008630056400562005610056100561005600056000560005600056000560006600066000000000000000000000000000000000000000000000000000000000
000100003265031640106200f6100f6100f6100e6100b6100b6001b6101b6300e6300d6300c6102c6003060032600336000e600336000d6100d6100e6000e60030600306000e6000e6002f6002f6002e6002e600
000100001d6501d6401063011620126201361013610000002a6402a63019620196201a62000000000000000000000000001761015610000000000000000000000000000000000000000000000000000000000000
000200000761007620076100761007610076100761007610076100761000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000461005620056200562005620056100462004620046200561005610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000066100a6200f6301064010660106600f6600f6700e6700e6700d6700d6700d6700c6600c6600b6600a660096500965008650076500764006640056300563005620046200462003610036100000000000
011000001f7751f70527775377753a7743a7523a7323a7152070120701207012c7042c7042c7022c7022c70500700005000050000000000000000000000000000000000000000000000000000000000000000000
00030000356700a7600a7502c6400a7400a720186200a700156101562013620136201263012630126301263012630116401164010640106400f6400f6300e6300c63007630066200562005620046100461004600
000200003967036660256503154539565346502f6403956534650346502b545335653a5552d65031650335452f660365652b6502a6502866027660246602365021650206501d6401b64019630186201662015610
000300000e610156201c6202762031630396303a6403a650206402063020610206201f6401e6401d6501c6501c6501b6501b6501b6501a6501965019650196501964018640176401764015630146201362000000
000300002671427732287322873228722287222871228712287112871128711287112860200402000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001e0000293722935227372273522e3722e3522b3722b352243622435224342243350000000000000000000000000000000000000000000000000030305353050000000000000000000000000000000000000000
001e00201b5721b5521b5321b5121f5721f5521f5321f51229572295522953229512225722255222532225121b5721b5521b5321b512225722255222532225121f5721f5521f5321f51227572275522753227512
000f0000275722755227532275122b5722b5522b5322b5122e5722e5522e5322e51235575335753057533575305752e575305752e5752b5752e575305753357530575335752e5752b57527572275522753227515
001200200c3620c3720c3320c312113621137211332113120f3620f3720f3320f3120a3620a3720a3320a3120c3720c3720c3620c352183621837218352183321636216372163521633218362183721833218312
011200201837218362183421833224372243421f3621f362183721835218332183322b3722b33222332223521d3721d3721136216342183721635213332113421837218352273322735224372243621834218322
011200201507300000116331d635150731d6551d6751d63515073000001163300000150730000011633000001507300000116331d635150731d6551d6751d6351507300000116330000015073000001163300000
000c000003110071300c15012160171701c17021170271602d150341503b1503e1603e1703d1603b160391603516032170301702d1702b1702816025160211601b160161600f1600a15006140031300112001110
00030000216302f650376603e6703e6703d6703667034660316602f6602d6502a650286202562022610216102161021610396401d6301c6300f6301763032630066200c6200e6202a6200c620056102461004670
00040000073230a3330f3431134316343163531635316353163530a3430f3330f3331333313323163231632316323163131632316333153331434311343103530d3530c3530c3430b3430a333073230531303313
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffff0000000000000000000000000000003ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ffffffff3ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77
ff1ffc0f000000000000000000000000000000000000000000000000000000000000000000000000000000003ff773ff773ff773ff773f7713c77000f77078473f7713c77000f77018473f7713c7700077700847
000000800000000c773f100008060000000c773f061008060000000f771f061008060000000f771f0000000000000008770f0000000000000008000f0000000000000008000f0000000000000008000f00000000
0f0000000f0000000000000008670f4700000000000008670f4700080601000008670f4700080601000008670f4700080601000008670f4700000000000008670f0000000000000008670f000000000000000867
ffffffff00000008670f0000000000000008670f8040700000000008670f867078470000020f770f867078470000020f770f867078470000020f771f867078473ff773ff773f867078473ff773ff773f80407847
e3fb7f703f300008473ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff773ff77078473ff773ff773ff77078473ff7723f573ff77078473ff7723f573f107008473ff77
00001ff8008471f847238043f107008471f847238043f107008471f8472380407007008471f847238043f007008001f847238043f8073ff161f847238043fb473ff161f847238043fb473ff161f8472380401000
23c0ff872380401000000000380423000000000000000804238040100000000008042380401000000000380423804010000000003804238043fb673ff163ff14238043fb673ff163ff14238040f8001f8043ff14
ffffffff1f8042ff77238043ff303f30020f7723f573ff303f3003ff7723f573ff303f3003ff7723f573ff303f3003ff773ff773f730180003ff773ff773f000000003ff773ff773ff773ff773ff773ff773ff77
__music__
01 00464344
00 01474344
00 02484344
00 03424344
00 04424344
02 05424344
03 16174344
03 13424344
03 15424344
03 1a424344

