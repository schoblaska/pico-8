pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--switch block dungeon v1.0
--created by mitch_match
--music by gruber

--tables
function _init()
		player={
				sp=0,x=444,y=140,
				w=8,h=8,flp=false,
				dx=0,dy=0,max_dx=5,max_dy=2,
				acc=0.15,boost=3,anim=0,
				running=false,jumping=false,
				falling=false,sliding=false,
				landed=false,dashing=false,
				wallslide=false,screenx=0,screeny=0,
				deaths=0
		}

		--scenes and menus
		_set_fps(60)
		scene=0
		block_x=390
		block_y=0

		--physics
		gravity=0.2
		friction=0.85
		first_fall=0
		freeze_player=false
		
		--camera
		camera_x=0
		camera_nextx=128
		camera_lastx=0
		camera_y=0
		camera_nexty=128
		camera_lasty=0		
		stop_screen=false
		fading_timer=0
		draw_player=true
		hold_cam_x=0
		hold_cam_y=0
		hold_cam=false
		scene_fade=false
		st_lock=false
		dont_freeze=false
		
		--change in hitbox
		ch=0  ch2=0

		--walljump forgiveness
		late=0
		air=-5
		wallslide_overrid=false
		
		
		--in game timer
		igt_sec=0
		igt_min=0
		igt_frame=0
		igt_color=7
		igt_lock=false
		min_x_add=0
		timer=0
		timer2=0
		timer3=0
		timer4=0
		timer4_max=100
		timer5=0
		timer6=0
		timer7=0
		timer7_lock=true
		timer8=0
		timer8_lock=true
		timer9=0
		green_timer=0
		t_add=0
		k_add=0
		last=0
		
		--set respawn point
		respawn_x=player.x
		respawn_y=player.y
		rsp_ban_x=-10
		rsp_ban_y=-10
		shine_lx=-200
		shine_ly=-200
	

		--features
		tap_jump=true
		anti_wallslide=false
		fps_display=false
		
		
		--interactable variables
		coins=0
		coin_max=252
		key_1=false
		key_2=false
		key_3=false
		key_4=false
		dest_blocks={}		
		springs={}
		run_key_code=false
		big_key_y=302
		expon=0
		expon2=0
		expon3=0
		r_expon=0
		l_expon=0
		draw=0
		
		
				
		--other
		result={}
		index={}
		checkp_x=-10
		checkp_y=-10
		timer_onoff=400
		brick_onoff=false
		jump_brick_onoff=false
		statcolor=4
		color_r=7
		unlock_colors=false

		
		--music
		song0=0
		song1=1
		song2=2
		delay1=0
		delay2=0
		
		--menu items
			menuitem(
  1,"display fps",
  function()
  		if fps_display==true then
  				fps_display=false
  		else
  				fps_display=true
  		end
  end
 	)
 	
		menuitem(
  2,"tap jump",
  function()
  		if tap_jump==true then
  				tap_jump=false
  		else
  				tap_jump=true
  		end
  end
 	)

		menuitem(
  3,"reset player",
 	function()
				death()
  end
 	)

		--menuitem(
  --4,"display timer",
  --function()
  --		if igt_display==false then
  --				igt_display=true
  --		else
  --				igt_display=false
  --		end
  --end
 	--)

end

--explosion init
		sparks={}
		for i=1,70 do
				add(sparks,{
				x=0,y=0,velx=0,vely=0,
				r=0,alive=false,mass=0,
				col=0,dir="all"
				})
		end

	
--update all
function _update60()
		
		if scene==0 then
				update_intro()
				update_game()
				music_play(0)
		elseif scene==1 then
				update_game()
				music_play(1)
		elseif scene==2 then
				update_outro()
				update_game()
				music_play(2)
		end
end
  
--draw all
function _draw()

		if scene==0 then
				draw_intro()
		elseif scene==1 then
				draw_game()
		elseif scene==2 then
				draw_outro()
		end
end
-->8
--update_gm + draw_gm
function update_game()

		if scene ==1 then
				player_update()
				player_animate()
		end
		
		--camera
		--handle x camera
		if not hold_cam then
		
		if player.x+2>camera_nextx then 
				camera_x+=128
				camera_nextx+=127
				camera_lastx+=127
		end
		if player.x-2<camera_lastx then 
				camera_x-=128
				camera_nextx-=127
				camera_lastx-=127
		end
		--handle y camera 
		if player.y+5>camera_nexty then 
				camera_y+=128
				camera_nexty+=127
				camera_lasty+=127
		end
		if player.y+2<camera_lasty then 
				camera_y-=128
				camera_nexty-=127
				camera_lasty-=127
		end
		
		--player out of bounds
		if player.x>1015 then
				player.x=1015
		elseif player.x>1010 then
				camera_lastx=889
		elseif player.x<1 then
				player.x=1
				camera_lastx=0
		end
		
		if player.y>503 then
				player.y=503
		elseif player.y<1 then
				player.y=1
		end

		--camera out of bounds
		if camera_x>896 then
				camera_x=896
		elseif camera_x<0 then
				camera_x=0
		end

		--fix key respawn cam bug
		if timer8>0 then
				camera_y=256
		end

		if not stop_screen then
				if timer7>30 and camera_y>256 then
						camera_y=256
				end
				camera(camera_x,camera_y)
		end
		
		player.screenx=(camera_x/128)
		player.screeny=(camera_y/128)
		
		end
		
		--hold camera during death
		if hold_cam==true then
				camera_x=hold_cam_x
				camera_y=hold_cam_y
		end
		
		--intro falling code
		if timer7_lock==false then
				timer7+=1
		end		
		
		if timer7>30 then	
				camera_y=256
		end
		
		if timer7==40 then
				dont_freeze=true
				player.x=444
		end
		
		if timer7==70 then
				sfx(42)
		elseif timer7==160 then
				dont_freeze=false
				timer7_lock=true
				timer7=0
		end

		
		--key respawn falling code
		if timer8_lock==false then
				timer8+=1
		end		
		
		if timer8>0 then	
				camera_y=256
		end
		
		if timer8 ==40 then
				dont_freeze=true
				player.x=444
		end
		
		if timer8==160 then
				dont_freeze=false
				timer8_lock=true
				timer8=0
		end		
		
		--spring code
		if key_4==false then
			for spring in all(springs) do
				
				if spring.life==100 then
						sfx(18)
						mset(spring.x,spring.y,spring.sp1)
				elseif spring.life==95 then
						mset(spring.x,spring.y,spring.sp2)
				elseif spring.life==90 then
						mset(spring.x,spring.y,spring.sp1)
				elseif spring.life==85 then
						mset(spring.x,spring.y,spring.sp2)
				elseif spring.life==80 then
								mset(spring.x,spring.y,spring.sp1)
				elseif spring.life==70 then			
						mset(spring.x,spring.y,spring.sp0)
						del(springs,spring)
				end
				
				spring.life-=1
			end
		end
		
		
		--destructable block code
		if key_3==false then
			for block in all(dest_blocks) do
				mset(block.x,block.y,block.sp)
				
				block.life-=1
				if block.life==block.og_life-1 then
						sfx(5)
				end
				if block.life==block.og_life-block.change then
						block.sp+=1
						explode(flr(block.x)*8+rnd(8),block.y*8+3,2,1,5,"down")
				elseif block.life==block.og_life-block.change*2 then
						block.sp+=1
						explode(flr(block.x)*8+rnd(8),block.y*8+3,2,1,6,"down")
				elseif block.life==block.og_life-block.change*3 then
						block.sp+=1
						explode(flr(block.x)*8+rnd(8),block.y*8+3,2,1,block.last_color,"down")
				elseif block.life==-50 then
						block.sp-=4
						--only execute if on screen
						if (flr((flr(flr((flr(block.x)*8))/8))/16)) == player.screenx
						and (flr((flr(flr((flr(block.y)*8))/8))/16)) == player.screeny then 
								explode(block.x*8+2,block.y*8+2,3,2,7,"all")
								explode(block.x*8+2,block.y*8+2,3,2,6,"all")
								explode(block.x*8+2,block.y*8+2,3,2,block.last_color,"all")
								sfx(10)
						end
				elseif block.life==-51 then
						del(dest_blocks,block)
				end
			
			end
		end
		
		--explosion code
		for i=1,#sparks do
				if sparks[i].alive then
						if sparks[i].dir=="all" then
								sparks[i].x +=sparks[i].velx / sparks[i].mass
								sparks[i].y +=sparks[i].vely / sparks[i].mass

				  elseif sparks[i].dir=="down" then
								sparks[i].y +=1 / sparks[i].mass

						elseif sparks[i].dir=="torch" then
								sparks[i].y -=0.2 / sparks[i].mass
						end 
						sparks[i].r -=0.1
						if sparks[i].r < 0.1 then
								sparks[i].alive = false
						end
				end
		end
		
		
		
end







function draw_game()
		if not stop_screen then
				cls()
		end
		

		--draw torhc glow circ
		local glowx=camera_x
		local glowy=camera_y
		for i=1,16 do
				for i=1,16 do
						if mget((glowx)/8,(glowy)/8)==30 then
								circfill(glowx+4,glowy+2,13+t_add,14)
								circfill(glowx+4,glowy+2,11+t_add,1)
								circfill(glowx+4,glowy+2,7+t_add,13)
						end
						glowx+=8
				end
				glowy+=8
				glowx=camera_x
		end

		
		--draw background bricks
		local brickx=0
		local bricky=0
		for i=1,16 do
				for i=1,16 do		
						spr(43,brickx+camera_x,bricky+camera_y)		
						brickx+=8
				end
				bricky+=8
				brickx=0
		end

		
		map(0,0,0,0,128,64)
		spr(45,flr(checkp_x)*8,flr(checkp_y)*8)


		--explosion draw
		for i=1,#sparks do
				if sparks[i].alive then
						if not stop_screen then
						circfill(
						sparks[i].x,
						sparks[i].y,
						sparks[i].r,
						sparks[i].col
						)	
						end
				end
		end

		
		--place timers
		timer+=1
  if timer>20 then timer=0 end
  if timer>10 then t_add=1 else t_add=0 end
  timer2+=1
  if timer2>200 then timer2=0 k_add=-1 end
  if timer2==50 then k_add=0 end
  if timer2==100 then k_add=1 end
  if timer2==150 then k_add=0 end
  timer3+=1
  if timer3>200 then timer3=0 end
  if timer3==0 then shine_lx=0  shine_ly=0 end
  if timer3==2 then shine_lx-=1 shine_ly-=1 end
  if timer3==6 then shine_lx-=1 shine_ly-=1 end
  if timer3==8 then shine_lx-=300 shine_ly-=300 end
		if fading_timer !=0 then
				fading_timer-=1
		end

 	map_place()

		
		--laser cannons flip
		spr(85,552,56,1,1,true,false)
		spr(84,832,112,1,1,false,true)
		spr(84,856,112,1,1,false,true)
		spr(84,832,48,1,1,false,true)
		spr(84,856,48,1,1,false,true)
		
		spr(85,552,56,1,1,true,false)
		spr(85,760,48,1,1,true,false)
		spr(85,760,72,1,1,true,false)
		spr(85,760,96,1,1,true,false)
		
		spr(85,680,200,1,1,true,false)
		
		--draw player
		spr(player.sp,player.x,player.y,1,1,player.flp)
	
		--anti wallslide block prep
		anti_wallslide=false
	
		--new interactable collision
		newx=0
		newy=0
		for i=0,10 do
				for i=0,5 do
						newx+=1
						--collide coin
						if (mget((player.x+newx)/8,(player.y+newy)/8)==46)	then 
  						coins+=1
  						mset(flr(player.x+newx)/8,flr(player.y+newy)/8,0)
  						explode((flr((player.x+newx)/8)*8)+4,(flr((player.y+newy)/8)*8)+4,2,1,9,"all")
								explode((flr((player.x+newx)/8)*8)+4,(flr((player.y+newy)/8)*8)+4,2,1,10,"all")
  						sfx(6)
  				end
  				
  				if (mget((player.x+newx)/8,(player.y+newy)/8)==51)	then 
								coins+=5
								mset(flr(player.x+newx)/8,flr(player.y+newy)/8,0)
								explode((flr((player.x+newx)/8)*8)+4,(flr((player.y+newy)/8)*8)+4,3,1,10,"all")
								explode((flr((player.x+newx)/8)*8)+4,(flr((player.y+newy)/8)*8)+4,3,1,9,"all")
								sfx(46)
						end

  				--collide checkpoint (cp)
  				if mget((player.x+newx)/8,(player.y+newy)/8)==44 then
								if not (flr(player.x/8)*8 == flr(checkp_x)*8) 
								and not (flr(player.y/8)*8 == flr(checkp_y)*8) then
  								checkp_x=flr(player.x+newx)/8
  								checkp_y=flr(player.y+newy)/8
										respawn_x=player.x+newx
										respawn_y=player.y+newy
										if flr(respawn_x/8)*8 != rsp_ban_x and flr(respawn_y/8)*8 != rsp_ban_y then  
												sfx(13)
												rsp_ban_x=flr(respawn_x/8)*8   
												rsp_ban_y=flr(respawn_y/8)*8
										end						
								end	
						end

  				--spring code
  				if (mget((player.x+newx)/8,(player.y+newy-5)/8)==27) then
  						add(springs,{life=100,sp0=27,sp1=58,sp2=57,x=(flr(player.x+newx)/8),y=(flr(player.y+newy-5)/8)})
  						player.dy=-4
  				elseif (mget((player.x+newx+4)/8,(player.y+newy-1)/8)==15) then
  						add(springs,{life=100,sp0=15,sp1=63,sp2=62,x=(flr(player.x+newx+4)/8),y=(flr(player.y+newy-1)/8)})
  						player.dy=-2
  						player.dx=5
  				elseif (mget((player.x+newx-4)/8,(player.y+newy-1)/8)==126) then
  						add(springs,{life=100,sp0=126,sp1=77,sp2=76,x=(flr(player.x+newx-4)/8),y=(flr(player.y+newy-1)/8)})
  						player.dy=-2
  						player.dx=-5
  				end

						--destructable blocks
						local chg_x=0   local chg_y=0							
  						--red
  						if (mget((player.x+newx+2)/8,(player.y+newy)/8)==64) then
  								add(dest_blocks,{sp=65,life=90,og_life=90,last_color=8,change=10,x=(flr(player.x+newx+2)/8),y=(flr(player.y+newy)/8)})
  								mset(flr(player.x+newx+2)/8,flr(player.y+newy)/8,69)
  						end
  						if (mget((player.x+newx-2)/8,(player.y+newy)/8)==64)
  						and player.wallslide==true then
  								add(dest_blocks,{sp=65,life=90,og_life=90,last_color=8,change=10,x=(flr(player.x+newx-2)/8),y=(flr(player.y+newy)/8)})			
  								mset(flr(player.x+newx-2)/8,flr(player.y+newy)/8,69)
  						end 		
  						if (mget((player.x+newx)/8,(player.y+newy-1)/8)==64) 
  						and player.jumping==true then
										add(dest_blocks,{sp=65,life=90,og_life=90,last_color=8,change=10,x=(flr(player.x+newx)/8),y=(flr(player.y+newy-1)/8)})
  								mset(flr(player.x+newx)/8,flr(player.y+newy-1)/8,69)
  						end 
  						if (mget((player.x+newx)/8,(player.y+newy+1)/8)==64) then
  								add(dest_blocks,{sp=65,life=90,og_life=90,last_color=8,change=10,x=(flr(player.x+newx)/8),y=(flr(player.y+newy+1)/8)})
  								mset(flr(player.x+newx)/8,flr(player.y+newy+1)/8,69)
  						end  
  				
  						--purple
  						if (mget((player.x+newx+2)/8,(player.y+newy)/8)==9) 
  						and player.wallslide==true then
  								add(dest_blocks,{sp=10,life=200,og_life=200,last_color=13,change=40,x=(flr(player.x+newx+2)/8),y=(flr(player.y+newy)/8)})		
  								mset(flr(player.x+newx+2)/8,flr(player.y+newy)/8,14)
  						end
  						if (mget((player.x+newx-2)/8,(player.y+newy)/8)==9)
  						and player.wallslide==true then
  								add(dest_blocks,{sp=10,life=200,og_life=200,last_color=13,change=40,x=(flr(player.x+newx-2)/8),y=(flr(player.y+newy)/8)})			
  								mset(flr(player.x+newx-2)/8,flr(player.y+newy)/8,14)
  						end 		
								if (mget((player.x+newx)/8,(player.y+newy-1)/8)==9) 
  						and player.jumping==true then
										add(dest_blocks,{sp=10,life=200,og_life=200,last_color=13,change=40,x=(flr(player.x+newx)/8),y=(flr(player.y+newy-1)/8)})
  								mset(flr(player.x+newx)/8,flr(player.y+newy-1)/8,14)
  						end 
  						if (mget((player.x+newx)/8,(player.y+newy+1)/8)==9) then
  								add(dest_blocks,{sp=10,life=200,og_life=200,last_color=13,change=40,x=(flr(player.x+newx)/8),y=(flr(player.y+newy+1)/8)})
  								mset(flr(player.x+newx)/8,flr(player.y+newy+1)/8,14)
  						end 
  						
  					--anti wallslide block
  					if (mget((player.x+newx+2)/8,(player.y+newy)/8)==47) or (mget((player.x+newx-2)/8,(player.y+newy)/8)==127) then
  							anti_wallslide=true 							
  					end 

  						
  		end
  		newx=0
  		newy+=1
  end
  
  		--fade from key peices
				if run_key_code==true	then 
  				stop_screen=true
  				timer8_lock=false
  				fading_timer=100
  				player.x=444
  				player.y=140
  				respawn_x=444
  				respawn_y=140
						sfx(-1)
						sfx(7)
  				run_key_code=false
  		end
  
				--key identification
				--key1
				if flr(player.x)<23 and flr(player.y)<40 then
						mset(46,33,33)
						mset(46,32,33)
						key_1=true
						run_key_code=true
				--key2
				elseif flr(player.x)>990 and flr(player.x)<1006 and flr(player.y)<42 then
						mset(66,32,33)
						key_2=true
						run_key_code=true
				--key3
				elseif flr(player.x)>464 and flr(player.x)<475 and flr(player.y)>390 and flr(player.y)<405 then	
						mset(32,44,33)
						mset(32,43,33)
						mset(32,42,33)
						mset(32,41,33)
						key_3=true
						run_key_code=true
				--key4
				elseif flr(player.x)>1000 and flr(player.x)<1015 and flr(player.y)>145 and flr(player.y)<160 then	
						mset(69,47,33)
						mset(70,47,33)
						mset(71,47,33)
						mset(72,47,33)
						mset(73,47,33)
						key_4=true
						run_key_code=true
				end
				
				
				--draw key peices
				if key_1 then
						spr(70,414,294+k_add)
						if timer==20 and camera_x==384 and camera_y==256 then
								explode(416+rnd(9),294-2+rnd(12),2,5,7,"torch")
								explode(416+rnd(9),294-2+rnd(12),2,5,7,"torch")
						end
				end
				if key_2 then
						spr(71,474,294+k_add)
						if timer==20 and camera_x==384 and camera_y==256 then
								explode(472+rnd(9),294-2+rnd(12),2,5,7,"torch")
								explode(472+rnd(9),294-2+rnd(12),2,5,7,"torch")
						end
				end
				if key_3 then
						sspr(48,40,9,8,397,310+k_add)
						if timer==20 and camera_x==384 and camera_y==256 then
								explode(400+rnd(9),310-2+rnd(12),2,5,7,"torch")
								explode(400+rnd(9),310-2+rnd(12),2,5,7,"torch")
						end
				end
				if key_4 then
						spr(87,489,310+k_add)
						if timer==20 and camera_x==384 and camera_y==256 then
								explode(488+rnd(9),310-2+rnd(12),2,5,7,"torch")
								explode(488+rnd(9),310-2+rnd(12),2,5,7,"torch")
						end
				end
				
				--draw keys sprite
				spr(71,1000,32+k_add)	
				spr(70,16,32+k_add)
				sspr(48,40,9,8,467,396+k_add)
				spr(87,1008,152+k_add)
				
				--draw key explode
				if timer==20 and scene==1 then
						--key1
						explode(17+rnd(9),32+rnd(12),2,5,7,"torch")
						explode(17+rnd(9),32+rnd(12),2,5,7,"torch")
						--key2
						explode(1000+rnd(9)-2,30+rnd(12),2,5,7,"torch")
						explode(1000+rnd(9)-2,30+rnd(12),2,5,7,"torch")
						--key3
						explode(469+rnd(10),394+rnd(12),2,5,7,"torch")
						explode(469+rnd(10),394+rnd(12),2,5,7,"torch")
						--key4
						explode(1006+rnd(10),150+rnd(12),2,5,7,"torch")
						explode(1006+rnd(10),150+rnd(12),2,5,7,"torch")	
				
				end

  
  		--end game for all 4 keys
  				if key_1 and key_2 and key_3 and key_4 then
  						timer6+=1
  						music(-1,10)
  						music_play(2)
  						key_1=false
  						key_2=false
  						key_3=false
  						key_4=false
  						igt_lock=true
								--contains player
  						mset(48,42,38) 	mset(63,42,38)
  						mset(48,43,38)  mset(63,43,38)
  						mset(48,44,38) 	mset(63,44,38)
  						--delete red/blue blocks from appearing in cutscene
  						mset(35,6,0) mset(36,6,0) mset(36,5,0)
								mset(43,5,0) mset(43,6,0)
								mset(44,5,0) mset(44,6,0)
  				end
  				
  				if timer6>0 then
  						timer6+=1
  						--timer8=-2
  				end
  				if timer6>100 then 
  						r_expon+=0.1+expon
  						expon+=0.01
  				end

  				if timer6<162 and timer6>0 then
  						sspr(8*6,40,9,8,397+r_expon*1.8,310-(r_expon/12))
								spr(70,416+r_expon,294+(r_expon/3))
								spr(87,488-(r_expon/0.5)/1.2,310-(r_expon/12))
								spr(71,472-r_expon,294+(r_expon/3))
						end
						if timer6==163 then
								explode(448,312,12,20,7,"all")
								--explode(448,312,4,2,6,"all")
						end
						
						--key collide explode
						if timer6>163 and timer6<410 then
								spr(70,440,big_key_y,2,2)
								explode(440+8,big_key_y+10,10,10,7,"torch")
  				end
  				if timer6==164 then
  						sfx(9)
  						sfx(20)
  						pal(5,5,1)
  				end
  				
  				if timer6>300 then
  						big_key_y+=expon2
								expon2+=0.01
  				end
  				if big_key_y>349 then
  						big_key_y=350
  				end
  				
  				if timer6==400 then
  						sfx(9)
  						sfx(19)
  				end
  				
  				if timer6>400 and timer6<470 then
  						rectfill(447,254,447-l_expon,381,7)
  						rectfill(448,254,448+l_expon,381,7)
  						l_expon+=0.1+expon3
  						expon3+=0.1
  				end
  				
  				if timer6==440	then
  						hold_cam=true
								fading_timer=100
								draw_player=false
								freeze_player=true
  						scene=2
  				end

						
		--draw player hitting ground
		if first_fall==2 then
				explode(player.x,player.y+6,3,1,6,"all")
				explode(player.x,player.y+6,3,1,7,"all")
				sfx(11)
				first_fall=0
		end
		
		
		--screen fade in/out
		if fading_timer==90 then
					 pal(3,1,1) 
						pal(4,2,1) 
						pal(5,1,1) 
						pal(6,5,1) 
						pal(7,6,1)	
						pal(8,16+136,1)
					 pal(9,4,1)
					 pal(10,9,1)
					 pal(11,2,1)
					 pal(12,16+140,1)
					 pal(13,16+141,1) 
					 pal(15,6,1)
						
																	
		elseif fading_timer==85 then
					 pal(2,16+128,1) 
					 pal(3,1,1) 
						pal(4,1,1) 
						pal(5,0,1) 
						pal(6,1,1) 
						pal(7,5,1)	
						pal(8,16+130,1)
					 pal(9,16+130,1)
					 pal(10,16+130,1)
					 pal(11,16+128,1)
					 pal(12,1,1)
					 pal(13,16+130,1) 
					 pal(15,1,1)

		elseif fading_timer==80 then
						pal_1()

		elseif fading_timer==75 then
						for i=1,15 do
								pal(i,0,1)
						end
		
		elseif fading_timer==70 then
				stop_screen=false
				draw_player=true
				hold_cam=false
				if scene_fade==true then
						scene=1
						scene_fade=false
						camera_y=256
				end
				
		elseif fading_timer==45 then	
						pal_1()
				
		elseif fading_timer==40 then
						pal(2,16+128,1) 
					 pal(3,16+128,1) 
						pal(4,1,1) 
						pal(5,0,1) 
						pal(6,1,1) 
						pal(7,5,1)	
						pal(8,16+130,1)
					 pal(9,16+130,1)
					 pal(10,16+130,1)
					 pal(11,16+128,1)
					 pal(12,1,1)
					 pal(13,16+130,1) 
					 pal(15,1,1)
						
		
		elseif fading_timer==35 then
						pal(2,2,1) 
						pal(3,1,1) 
						pal(4,2,1) 
						pal(5,1,1) 
						pal(6,5,1) 
						pal(7,6,1)	
						pal(8,16+136,1)
					 pal(9,4,1)
					 pal(10,9,1)
					 pal(11,2,1)
					 pal(12,16+140,1)
					 pal(13,16+141,1) 
					 pal(15,6,1)
					 
		elseif fading_timer==30 then
				freeze_player=false
				if scene==2 then
						pal(5,0,1)
				end
				pal_0()
		end
		
		function pal_0() 
				pal(1,1,1) pal(8,8,1)
				pal(2,2,1) pal(9,9,1)
				pal(3,16+140,1) pal(10,10,1)
				pal(4,4,1) pal(11,16+141,1)
				pal(5,5,1) pal(12,12,1)
				pal(6,6,1) pal(13,13,1)
				pal(7,7,1)	pal(14,16+129,1)									
															pal(15,14,1)	
		end
		
		function pal_1()
						pal(1,16+129,1) 
						pal(2,16+129,1) 
						pal(3,0,1) 
						pal(4,16+129,1) 
						pal(5,0,1) 
						pal(6,1,1) 
						pal(7,1,1)	
						pal(8,16+129,1)
					 pal(9,1,1)
					 pal(10,1,1)
					 pal(11,1,1)
					 pal(12,1,1)
					 pal(13,1,1) 
					 pal(14,16+129,1) 
					 pal(15,1,1)		
				
		end 
		
		--color pallet changes
		if time()<0.1 then
				pal_0()
		end
		
		if unlock_colors==true then
				pal(15,11,1)
				pal(3,14,1)
				if color_r>14 then
					color_r=5
				end		
		end
		
		--screen freeze player
		if freeze_player then
				if not dont_freeze then
						player.x=flr(respawn_x/8)*8
						player.y=flr(respawn_y/8)*8
				end
		end
		
  --on/off laser flag change			
				if brick_onoff==false then
						--red on, blue off
						fset(115,2,true)
						fset(113,2,true)
						fset(83,2,true)
						fset(99,2,true)
						fset(114,2,false)
						fset(112,2,false)
						fset(98,2,false)
						fset(82,2,false)
				else
						--red off, blue on
						fset(115,2,false)
						fset(113,2,false)
						fset(83,2,false)
						fset(99,2,false)
					 fset(114,2,true)
					 fset(112,2,true)
					 fset(98,2,true)
					 fset(82,2,true)
				end
				

		if fps_display then
				if stat(7)==60 then statcolor=13 elseif stat(7)==30 then statcolor=15 end
				out_line(stat(7),camera_x+2,camera_y+2,statcolor,1)
		end
		
		if scene==1 and igt_lock==false then
				
				igt_frame+=1.01
				if igt_frame>=60 then
						igt_sec+=1
						igt_frame=0
				end
				if igt_sec>=60 then
						igt_sec=0
						igt_min+=1
				end
		end
		

		--print(player.x,1+camera_x,38+camera_y,7)
		--print(timer8,51*8,37*8,8)
		
		--print(flr(player.y),camera_x,camera_y+60,6)
		--print(count(dest_blocks),1+camera_x,24+camera_y,7)
		--print(player.dy,2,18,7)
		--print(player.dy,2,18,7)
		--print(flr(player.x),1+camera_x,32+camera_y,7)
		
		--print(igt_min,1+camera_x,58+camera_y,7)
		--print(igt_sec,1+camera_x,58+camera_y+10,7)

		--print(flr(checkp_x)*8,1+camera_x,60+camera_y,7)	
		--print(flr(checkp_y)*8,1+camera_x,70+camera_y,7)			

		--print(time()-last,1+camera_x,50+camera_y,7)
		--print(time(),1+camera_x,60+camera_y,7)
		
end


--explosion function
function explode(x,y,r,particles,col,dir)
		local selected = 0
		
		for i=1,#sparks do
				if not sparks[i].alive then
				sparks[i].x=x
				sparks[i].y=y
				sparks[i].vely= -1+rnd(2)
				sparks[i].velx= -1+rnd(2)
				sparks[i].mass= 0.5+rnd(2)
				sparks[i].r= 0.5+rnd(r)
				sparks[i].alive = true
				sparks[i].col=col
				sparks[i].dir=dir
				selected +=1
				if selected == particles then
						break end
				end
		end		
end

--death function
function death()
		explode(flr(player.x),flr(player.y),5,50,8,"all")
		hold_cam_x=camera_x
		hold_cam_y=camera_y
		hold_cam=true
		player.x=flr(respawn_x/8)*8
		player.y=flr(respawn_y/8)*8
		player.deaths+=1
		fading_timer=110
		draw_player=false
		freeze_player=true
		sfx(45)
		sfx(2)
end

--map place sprites
function map_place()
		
		local placex=camera_x
		local placey=camera_y
		local target_sp=0

		for i=1,16 do
				for i=1,16 do

						target_sp=mget((placex)/8,(placey)/8)
						--start of scene 1
						if scene==1 then
						
						--on/off brick draw
						if target_sp==81 and brick_onoff==true then
								mset(flr(placex)/8,flr(placey)/8,97)
								sfx(12)
						end
						if target_sp==97 and brick_onoff==false then	
								mset(flr(placex)/8,flr(placey)/8,81)
								sfx(12)
						end
						if target_sp==80 and brick_onoff==false then
								mset(flr(placex)/8,flr(placey)/8,96)
								sfx(12)
						end
						if target_sp==96 and brick_onoff==true then	
								mset(flr(placex)/8,flr(placey)/8,80)
								sfx(12)
						end

						--work
						--laser draw
						if camera_y <= 128 then
								--blue laser vertical
								if brick_onoff==true then
						
								if target_sp==114 then	
										draw_laser(flr(placex),flr(placey),12)

								--blue laser tail vertical
								elseif target_sp==112 then
										draw_laser(flr(placex),flr(placey),13)

								--blue laser horizontal
								elseif target_sp==98 then
										draw_laser(flr(placex),flr(placey),14)
						
								--blue laser tail horizontal
								elseif target_sp==82 then
										draw_laser(flr(placex),flr(placey),15)
								end
						
								end
					
					
								if brick_onoff==false then
								--red laser vertical
								if target_sp==115 then	
										draw_laser(flr(placex),flr(placey),8)

								--red laser tail vertical
								elseif target_sp==113 then
										draw_laser(flr(placex),flr(placey),9)

								--red laser horizontal
								elseif target_sp==99 then
											draw_laser(flr(placex),flr(placey),10)

								--red laser tail horizontal
								elseif target_sp==83 then
										draw_laser(flr(placex),flr(placey),11)
								end
						
						end
						
						
						end
						
						
						--jump block on/off		
						if jump_brick_onoff==true then
								if target_sp==59 then
										mset((placex)/8,(placey)/8,60)
								sfx(4)
								end
								if target_sp==60 then
										mset((placex)/8,(placey)/8,59)
								sfx(4)
								end
						end
					
						--on/off spikes	


						--up spikes	
						if brick_onoff==false then
						
								if target_sp==101 then
										mset((placex)/8,(placey)/8,117)
								elseif target_sp==89 then
										mset((placex)/8,(placey)/8,73)
								--left spikes	
								elseif target_sp==100 then
										mset((placex)/8,(placey)/8,116)
								elseif target_sp==88 then
										mset((placex)/8,(placey)/8,72)
								--right spikes	
								elseif target_sp==102 then
										mset((placex)/8,(placey)/8,118)
								elseif target_sp==90 then
										mset((placex)/8,(placey)/8,74)
								--down spikes	
								elseif target_sp==103 then
										mset((placex)/8,(placey)/8,119)
								elseif target_sp==91 then
										mset((placex)/8,(placey)/8,75)
								end
								
						end
						
						
						--up spikes	
						if brick_onoff==true then
						
								if target_sp==117 then
										mset((placex)/8,(placey)/8,101)
								elseif target_sp==73 then
										mset((placex)/8,(placey)/8,89)
								--right spikes	
								elseif target_sp==118 then
										mset((placex)/8,(placey)/8,102)
								elseif target_sp==74 then
										mset((placex)/8,(placey)/8,90)
								--left spikes
								elseif target_sp==116 then
										mset((placex)/8,(placey)/8,100)
								elseif target_sp==72 then
										mset((placex)/8,(placey)/8,88)
								--down spikes	
								elseif target_sp==119 then
										mset((placex)/8,(placey)/8,103)
								elseif target_sp==75 then
										mset((placex)/8,(placey)/8,91)
								end
								
						end
						
					--end of scene 1
					end
					
						--torch explode draw
						if target_sp==30 then
								if timer==20 then
										explode(placex+4,placey+3,2,3,8,"torch")
								end
								
								spr(30+t_add,placex,placey)
						end
						
						--cp shine change
						if target_sp==44 then
								line(4+placex+shine_lx,6+placey+shine_ly,4+placex+shine_lx+3,6+placey+shine_ly-3,7)
								line(4+placex+shine_lx,5+placey+shine_ly,3+placex+shine_lx+3,6+placey+shine_ly-3,7)
								line(3+placex+shine_lx,5+placey+shine_ly,3+placex+shine_lx+3,5+placey+shine_ly-3,7)
						end
						
						placex+=8
				end
				placey+=8
				placex=camera_x
		end

		--finish jump brick logic
		if jump_brick_onoff==true then
				jump_brick_onoff=false
		end

end





function draw_laser(x1,y1,col)
		--red laser vertical
		if col==8 then
				rectfill(x1,y1,x1+7,y1+7,8)
				rectfill(x1+1,y1,x1+6,y1+7,9)
				rectfill(x1+2,y1,x1+5,y1+7,7)
		--red laser vertical tail
		elseif col==9 then
				rectfill(x1,y1,x1+7,y1+5,8)
				rectfill(x1+1,y1,x1+6,y1+6,8)
				rectfill(x1+2,y1,x1+5,y1+7,8)
				
				rectfill(x1+1,y1,x1+6,y1+5,9)
				rectfill(x1+2,y1,x1+5,y1+6,9)

			 rectfill(x1+2,y1,x1+5,y1+5,7)
		--red laser horizontal
		elseif col==10 then
				rectfill(x1,y1,x1+7,y1+7,8)
				rectfill(x1,y1+1,x1+7,y1+6,9)
				rectfill(x1,y1+2,x1+7,y1+5,7)
		--red laser horizontal tail
		elseif col==11 then
				rectfill(x1+2,y1,x1+7,y1+7,8)
				rectfill(x1+1,y1+1,x1+7,y1+6,8)
				rectfill(x1,y1+2,x1+7,y1+5,8)
				
				rectfill(x1+2,y1+1,x1+7,y1+6,9)
				rectfill(x1+1,y1+2,x1+6,y1+5,9)

			 rectfill(x1+2,y1+2,x1+7,y1+5,7)
		
		--blue laser vertical
		elseif col==12 then
				rectfill(x1,y1,x1+7,y1+7,12)
				rectfill(x1+1,y1,x1+6,y1+7,6)
				rectfill(x1+2,y1,x1+5,y1+7,7)
		--blue laser vertical tail
		elseif col==13 then
				rectfill(x1,y1,x1+7,y1+5,12)
				rectfill(x1+1,y1,x1+6,y1+6,12)
				rectfill(x1+2,y1,x1+5,y1+7,12)
				
				rectfill(x1+1,y1,x1+6,y1+5,6)
				rectfill(x1+2,y1,x1+5,y1+6,6)

			 rectfill(x1+2,y1,x1+5,y1+5,7)
		--blue laser horizontal
		elseif col==14 then 
				rectfill(x1,y1,x1+7,y1+7,12)
				rectfill(x1,y1+1,x1+7,y1+6,6)
				rectfill(x1,y1+2,x1+7,y1+5,7)

		--blue laser horizontal tail
		elseif col==15 then
				rectfill(x1,y1,x1+5,y1+7,12)
				rectfill(x1+1,y1+1,x1+6,y1+6,12)
				rectfill(x1+2,y1+2,x1+7,y1+5,12)
				
				rectfill(x1,y1+1,x1+5,y1+6,6)
				rectfill(x1,y1+2,x1+6,y1+5,6)

			 rectfill(x1,y1+2,x1+5,y1+5,7)
		end
end


-->8
--collision

function collide_map(obj,aim,flag)
  --obj(x,y,w,h), this is a table
		
		local x=obj.x  local y=obj.y
		local w=obj.w  local h=obj.h
		
		local x1=0  local y1=0
		local x2=0  local y2=0
		
		if aim=="left" then
				x1=x-1+ch		y1=y+ch2
				x2=x+ch			y2=y+h-1-ch2
		
		elseif aim=="right" then
				x1=x+w-1-ch	y1=y+ch2
				x2=x+w-ch   y2=y+h-1-ch2
		
		elseif aim=="up" then
				x1=x+2    y1=y-1+ch
   	x2=x+w-3  y2=y+ch
		
		elseif aim=="down" then
				x1=x+1   	y1=y+h-ch
   	x2=x+w-2  y2=y+h-ch
				
		end
		
		--pixles to tiles
		x1/=8		y1/=8
		x2/=8		y2/=8
		
		if fget(mget(x1,y1),flag)
		or fget(mget(x1,y2),flag)
		or fget(mget(x2,y1),flag)
		or fget(mget(x2,y2),flag) then
				return true
		else 
				return false
		end

end
-->8
--player_update

function player_update()		
		--physics
		player.dy+=gravity
		player.dx*=friction

		if btnp(➡️) then
				--key_1=true
				--player.x=2*8
				--player.y=10*6	
		end

		if btn(0,1) or btn(⬅️) then
				player.dx-=player.acc
				player.running=true
				player.flp=true
		end
		
		if btn(1,1) or btn(➡️) then
				player.dx+=player.acc
				player.running=true
				player.flp=false
		end
		
		--look down
		if (btn(3,1) or btn(⬇️))
		and player.running==false
		and player.landed==true
		and player.dashing==false then
				player.sp=4
		end
		
		--slide
		if player.running 
		and not (btn(0,1)or btn(⬅️))
		and not (btn(1,1)or btn(➡️))
		and not player.falling
		and not player.jumping then
				player.running=false
				player.sliding=true
		end
		
		--jump
		if ((btnp(4,0) or ((btnp(2,1))and tap_jump==true) or (btn(⬆️)and tap_jump==true))) and player.landed then
						player.dy-=player.boost
						player.landed=false
						explode(player.x,player.y+6,2,2,7,"all")
						jump_brick_onoff=true
						sfx(0)
		end
		
		
		--switch blocks
		if btnp(5,0) then
 			if brick_onoff==false then
 					brick_onoff=true
 			else
 					brick_onoff=false
 			end
 	end
				
		--spike collisions
		ch=4	ch2=3
		if collide_map(player,"down",2) 
		or collide_map(player,"up",2) 
		or collide_map(player,"left",2)				
		or collide_map(player,"right",2) then
				death()
		end
		ch=0  ch2=0

		--chain ladder collison
		ch=4
		if collide_map(player,"left",3)				
		or collide_map(player,"right",3) then
				player.sp=2
				player.wallslide=false
				wallslide_override=true
				player.landed=false
				player.falling=true
				gravity=0
				if btn(0,1) or btn(0,0) then
						player.dx=-1
				elseif btn(1,1) or btn(1,0) then
						player.dx=1
				else 
						player.dx=0
				end
				if btn(2,1) or btn(2,0) then
						player.dy=-1
				elseif btn(3,1) or btn(3,0) then
						player.dy=1
				else 
						player.dy=0
				end
				if player.dy>1 then 
						player.dy=1
				elseif player.dy<-1 then 
						player.dy=-1
				end
		else
				gravity=0.2
				wallslide_override=false
		end
		ch=0
	
  --cap player up speed
  if player.dy<-4 then 
  		player.dy=-4
  end
  
  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false
    player.wallslide=false

   	player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    		player.wallslide=false
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",1) then
      player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then
   	player.dx=limit_speed(player.dx,player.max_dx)
    
    if collide_map(player,"left",1) then
      player.dx=0
      if player.landed==false and anti_wallslide==false then
      		player.wallslide=true
      end
    else
    		player.wallslide=false
    end
  elseif player.dx>0 then
				player.dx=limit_speed(player.dx,player.max_dx)
    
    if collide_map(player,"right",1) then
      player.dx=0
      if player.landed==false and anti_wallslide==false then
      		player.wallslide=true
      end
    else
    		player.wallslide=false
    end
  end

  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end
  
  --wallslide and jump
  if player.wallslide and not wallslide_override then 
  		late=8 
  end
  if player.landed then 
  		air=-5 
  end
  late-=1
  air+=1
  if late<-50 then
				late=-20
		end
		if air>40 then
				air=35
		end
  if (player.wallslide or late>0) and air>0 and not wallslide_override  then
  		if player.dy>0 then
  				player.dy=0.4
				end
  		if (btnp(4,0) or ((btnp(2,1)or btnp(⬆️)))) then
  				sfx(3)
  				--player.dy=0
  				explode(player.x,player.y,2,3,rnd(2)+6,"all")
  				jump_brick_onoff=true
  				if collide_map(player,"right",1) then
  						player.dy=0
  						player.dx-=2
  						player.dy-=3
  				elseif collide_map(player,"left",1) then
  						player.dy=0
  						player.dx+=2
  						player.dy-=3
  				end
  		end
  end
  
  --first fall detection
  if first_fall==2 then
  		firstfall=0
  end
  if player.landed==false then
				first_fall=1
		end
		if first_fall==1 and player.landed==true then
  		first_fall=2
  end
  
  --janky walls mode
  --if player.wallslide then
  --		player.dy-=1
  --end
  
  player.x+=player.dx
  player.y+=player.dy
		
end


--animate function
function player_animate()
		if player.jumping then
				player.sp=2
		elseif player.falling then
				player.sp=3
		elseif player.sliding then
				player.sp=3
		elseif player.running then
		 if time()-player.anim>.1 then
      player.anim=time()
      player.sp+=1
      if player.sp>1 then
        player.sp=0
      end
   end
  else --player idle
    if time()-player.anim>.4
    and not (btn(3,1)or btn(⬇️)) then
      player.anim=time()
      player.sp+=5
      if player.sp>5 then
        player.sp=0
      end
    end
  end
  if player.wallslide then
				player.sp=29
				if player.flp==true then
						 player.flp=false
				elseif player.flp==false then
						 player.flp=true
				end
		end
		if draw_player==false then
				player.sp=38
		end
end

function limit_speed(num,maximum)
		return mid(-maximum,num,maximum)
end


-->8
--update_in + draw_in
function update_intro()
		
		camera_x=384
		camera_y=0
		
		--menu inputs
		if (btnp(🅾️) or btnp(❎)) and not st_lock then
				st_lock=true
				scene_fade=true
				hold_cam_x=384
				hold_cam_y=0
				hold_cam=true
				fading_timer=100
				draw_player=false
				freeze_player=true
				timer7_lock=false
				music(-1,10)
				sfx(20)
		end
		
end

function draw_intro()
		if not stop_screen then
				cls()
		end
		
		draw_game()
		

		if t_add==1 then
				color_1=7
		else
				color_1=13
		end

		--line(64+384,10,64+384,120,8)
		
		--switch
		sspr(64,56,35,8,51.75*8,30-6,70,16)
		--block
		sspr(64,48,27,8,52.75*8,50-6,54,16)
		--dungeon
		sspr(91,48,40,8,(51-1.25)*8,70-6,80,16)
		sspr(99,56,16,8,(60.25-1.25)*8,70-6,32,16)
		
		--menu text
		out_line("start",55+384,94,color_1,1)

		out_line("game by:mitch_match",27+384,111,13,1)
		out_line("music by:gruber",419,121,13,1)
		
		out_line("v1.0",111+384,121,13,1)
		
		out_line("❎",427,94,7,1)
		out_line("❎",427,93,7,1)
		out_line("🅾️",463,94,7,1)
		out_line("🅾️",463,93,7,1)
		
end

function out_line(text,x,y,color1,color2)
		print(text,x+1,y,color2)
		print(text,x-1,y,color2)
		print(text,x,y+1,color2)
		print(text,x,y-1,color2)
		print(text,x+1,y+1,color2)
		print(text,x+1,y-1,color2)
		print(text,x-1,y-1,color2)
		print(text,x-1,y+1,color2)
		print(text,x,y,color1)
end
-->8
--update_ot + draw_ot
function update_outro()
		camera_x=384
		camera_y=0
		unlock_colors=true
		
end

function draw_outro()
		
		draw_game()
		draw_player=false
		
		green_timer+=1
		
		if green_timer>60 then
				pal(5,11,1)
		end
		
		timer9+=1
		if timer9>48 then 
				timer9=0 
		end
		
		if timer9==6 then
				color_r=3
		elseif timer9==12 then
				color_r=5
		elseif timer9==18 then
				color_r=7
		elseif timer9==24 then
				color_r=8
		elseif timer9==30 then
				color_r=9
		elseif timer9==36 then
				color_r=10
		elseif timer9==42 then
				color_r=11
		elseif timer9==48 then
				color_r=12
		end


		--fireworks
		if timer==20 then		
				explode(rnd(127)+381,rnd(127),8,10,flr(color_r),"all")
				sfx(44)
		end
		
		
		--line(64+camera_x,10+camera_y,64+camera_x,120+camera_y,8)
		
		out_line("you escaped!",41+camera_x,20+camera_y,7,1)
		out_line("thanks for playing",28+camera_x,30+camera_y,7,1)
				
		if time()>8 then

				out_line("deaths",53+camera_x,63+camera_y,13,1)
				if player.deaths<10 then
						out_line(player.deaths,63+camera_x,72+camera_y,flr(color_r),1)
				elseif player.deaths<100 then
						out_line(player.deaths,61+camera_x,72+camera_y,7,1)
				else
						out_line(player.deaths,59+camera_x,72+camera_y,7,1)
				end
		
				out_line("coins",55+camera_x,84+camera_y,13,1)
				if coins==coin_max then
						out_line(coins,59+camera_x,93+camera_y,flr(color_r),1)
				elseif coins>99 then
						out_line(coins,59+camera_x,93+camera_y,7,1)
				elseif coins<100 then
						out_line(coins,61+camera_x,93+camera_y,7,1)
				end
		
				out_line("time",57+camera_x,42+camera_y,13,1)		
		
				if igt_min<5 and time()>8 then
						igt_color=color_r
				end
		
				if	igt_min>99 then
						out_line(igt_min,camera_x+54,camera_y+51,igt_color,1)
						min_x_add=2
				elseif igt_min>9 then
						out_line(igt_min,camera_x+56,camera_y+51,igt_color,1)
				else
						out_line(igt_min,camera_x+59,camera_y+51,igt_color,1)
						min_x_add=-1
				end
		
				if flr(igt_sec)<10 then
						out_line(flr(igt_sec),camera_x+70+min_x_add,camera_y+51,igt_color,1)
						out_line("0",camera_x+66+min_x_add,camera_y+51,igt_color,1)
				else
						out_line(flr(igt_sec),camera_x+66+min_x_add,camera_y+51,igt_color,1)
				end
		
				out_line(":",camera_x+63+min_x_add,camera_y+51,igt_color,1)
		
	 end

		
		out_line("game by:mitch_match",27+384,111,13,1)
		out_line("music by:gruber",419,121,13,1)
		
		out_line("v1.0",111+384,121,13,1)
				
end
-->8
--update music
function music_play(song)
		
		if song==song0 then
			 music(7,0,3)
				song0=-1
		end
		if song==song1 then
				delay1=200
				song1=-1
		end
		if song==song2 then
				delay2=55
				song2=-1
		end
		
		--music delay lower
		if delay1>-2 then
				delay1-=1
		end		
		if delay2>-2 then
				delay2-=1
		end

				
		if delay1==0 then
				music(0,0,3)
		end
		if delay2==0 then
				music(17,0,3)
		end

		
end
__gfx__
0066660000666600006666000066660000000000000000006db26ddb26dd26ddbdd62bd60555555005555550055555500551155001111110055555508f700000
067777600677776006777760067777600066660000666600db21dbb21ddb1ddb2bbd12bd57776dd557776dd5577006d5570000d51000000157776dd588700000
067171600677176006717160067171600677776006777760211e111111111db21111e11257655dd557611dd5570110d5500110051001100157655dd588f00000
0677776006777760776777670677776006777760067171606db1eeeeeeeee111eeee1bdd575005d5571001d5501001051010010110100101575005d588f00000
0d6767600d6776607dd767d77d6767600671716006777760db21eeee111eeeeeeeee12bd565005d5561001d5501001051010010110100101565005d528800000
7dd666d70d7666700d6666d077d666d70d6767600d676760211111e12bd111111e1111125dd55dd55dd11dd55d0110d550011005100110015dd55dd528800000
772222770772227002222220022222777dd666d77dd666d76d16db1dbdd1bdd1b1bd61d65dddddd55dddddd55dd00dd55d0000d5100000015dddddd528800000
00dd0dd00dd000dd0dd000dd0dd000dd772d2d77772d2d77db2db22bdd62dd62d12bd2bd05555550055555500555555005511550011111100555555022800000
00000000000000000000000000000000000000006ddd26d26dd26dd22dd62dd66d26d2d6444222227767666500000000ddd55555066660000000000000088000
0000000000d000d0000000000000000000000000dddb1db1ddb1ddb11bdd1bdddb1db1db4aa949426ddddd5100000000d766ddd5677776000008800000089800
00dd00d00d6d0d6d0d00dd000000000000000000db221b21dd21db2112bd1bddb21b21120422222006ddd510000000005555555567171600000898000089a800
00d7dd7d0d6d0d6dd7dd7d00000000eee00000002111e11edb211111e11112bd21e111d64a9994420015510000000000d6576565677776000089a980008a7a80
000d77d6d677d6766d77d00000000e11eee000006dd1eeee111eeeeeeeeee1126d1ee1db2994444200011000000000005d56d5d5d67766000014441000144410
000d676dd676d677d676d0000000e1bd111e0000ddb1e000eee00000000e1bd6db1ee1b2022222200000000077ff888855555555d76660000014421000144210
00d7d66dd677d676d66d6d000000e1dd1db1e000db21e00000000000000e12bddb1eee124944442200000000f8888882566dddd5772200000001210000012100
000d6ddddd6ddd6dddd6d000000ee1111dd1e000211ee00000000000000ee112b21ee1db22222222000000008888222255555555dd0000000000100000001000
00dd677d15555551d677dd00000e1dd1111ee0002111e0000000000000e1ddd6db21ee1270670760060d00d0eeeeeeee0000d00000008000000000002111e000
0d667776577766d5677766d0000e1bd1dd1e0000db21e0000000000000e1bdddddb1e1d6070770000dd20d110e000000000d7d0000087800000000006d51e000
00dd666d57655dd5d666dd000000e111db1e0000ddb1e0000000000000e122bd6dd1e1dd0670600000b001010e00000000d776d000877a800007a00066d1e000
0000dddd575765d5dddd000000000eee11e000006dd1e00000000000000e1112211ee1bd7070000006dd00010e0000000d7776d208777a9200a994007661e000
00dd777d5656d5d5d677dd000000000eee0000002111e00000000000000e1dd6db1ee11270700000020d0010eeeeeeee00d66d20008aa92000a994002111e000
0d6676765dd55dd5677766d00000000000000000db221e0000000000000e1bdddd1e1dd660000000000200010000e0000002d20000029200000440006d551e00
00dd666d5dddddd5d666dd000000000000000000dddb1e0000000000000e12bd6d1e1bdd00000000000000010000e000005626500056265000000000666d1e00
0000dddd15555551dddd000000000000000000006ddd1e0000000000000e111221ee12bd00000000000000000000e00005d676d505d676d50000000076661e00
000d6ddddd6ddd6dddd6d0000000000006707607211ee00000000000000ee112bd1ee12b000000000000000044444444444444440056650000008f70008f7000
00d7d76dd677d676d77d7d000009990000077070db21e00000000000000e12bd21eee1bd77ff88880000000047477a944eeeeee400dd55000607887007887000
000d776dd676d677d677d00000977a40000607606db1e00000000eee000e1bdd2b1ee1bdf8888882000000004a4a99944eeeeee40d766650656588f06588f000
000d76d6d677d6766d67d0000097a92000000707211eeeeeeeeee111eeee1dd6bd1ee1d68888222277ff8888494999944eeeeee40d6006505d5d88f05d88f000
00d6dd7d0d6d0d6dd7dd7d00004a992000000707db21111e111112bde11e11126d111e12075dddb0f8888882444444444eeeeee4056006b05d5d28805d288000
00dd00d00d6d0d6d0d00dd000002220000000006ddb1db2112bd12dd12b122bd2112b12b00655b008888222247a994944eeeeee405666d205d5d28805d288000
0000000000d000d0000000000000000000000000ddb1ddb11bdd1bdd1bd1bdddbd1bd1bd065dddb0075dddb0499994944eeeeee40055b2000505288005288000
00000000000000000000000000000000000000006dd26dd22dd62dd62d62ddd66d2d62d600655b0000655b004444444444444444005765000000228000228000
05555550055555500555555005511550011111100555555000000499994000000088a778000000008a77880088a888a808220000000822000000022222200000
577768855777688557700685570000851000000157776885000049777a940000089a777a00800080a777a9808a778a7a0882505000088250000227aa99922000
576558855761188557011085500110051001100157655885000497aaaaa9400000889aa8089808988aa988008a7a8a770882d5d5000882d50027a4411449a200
57500585571001855010010510100101101001015750058500097aa99aaa90000000888808a808a8888800008977897a0882d5d5000882d502a9444114449a20
56500585561001855010010510100101101001015650058500097a9009aa9000008877788977897a8a77880008a808a80f88d5d5000f88d50294447766444920
5885588558811885580110855001100510011001588558850009aa9009aa9000089a7a7a8a7a8a77a7a7a980089808980f885656000f88562744765555664492
58888885588888855880088558000085100000015888888500097aa99aaa900000889aa88a778a7a8aa988000080008007887060000788702a44651111564492
05555550055555500555555005511550011111100555555000049aaaaaa940000000888888a888a8888800000000000007f800000007f8002a47511111116492
333333332222222200000000000000001111111111110111000049aaaa94000000220002000000002000220022022202294446511e6444922a46511111116492
373776c32727798200000000000000001555555115d5165100000497a9994000020000000020002000000020200020002944751111e644922946511111116492
3636ccc329298882000000000000000015ddddd115d65d5100000097a77a9000002200020202020220002200200020002944651111e6449229465111111e6492
3c3cccc32828888201111010020222201ddd665115d656510000009aaaaa90000000222202020202222200002000200029475111111e64922944651111e64492
333333332222222200111010020222000155551015dd5d510000009aa99940000022000220002000200022000202020229465111111e649229ddd6511e66dd92
376cc3c32798828200000000000000001ddd6d6115dd5d510000009aa7aa9000020000002000200000000020020202022946555e5eee64922955556516555592
3cccc3c328888282000000000000000015555551155d1d5100000097aaaa90000022000220002000200022000020002029466666666664922955556516555592
333333332222222200000000000000001111111111110111000000499994400000002222220222022222000000000000294444411444449229dd67511e6d6692
3333333322222222000000000000000000cc677c00000000c677cc00cc6ccc6c3333330033000000000033330002222222022222202220220222222022222202
3eeeeee32eeeeee200000000000000000c66777600c000c0677766c0c677c676376ccc337630000033333763333276ddd227622dd276226d276dddd276dddd27
3eeeeee32eeeeee2000000000000000000cc666c0c6c0c6cc666cc00c676c67736ccccc36c333333376c36c36c326d22dd26d22dd26dd2dd26d22dd26d222226
3eeeeee32eeeeee201111100022222000000cccc0c6c0c6ccccc0000c677c67636c33cc3cc3766c36ccc36cccc326d222d26d22dd26ddddd262222226ddd2026
3eeeeee32eeeeee2001111100022222000cc777cc677c676c677cc000c6c0c6c3ccccc33cc36ccc3cc333ccc3302dd222b2dd22db2dddddd2d22ddd2dd22222d
3eeeeee32eeeeee200000000000000000c667676c676c677676766c00c6c0c6c3cc33cc3cc3cc3c3cccc3ccccc32dd22db2dddddb2dd2ddb2dd22db2dddddb2d
3eeeeee32eeeeee2000000000000000000cc666cc677c676c676cc0000c000c03cccccc3cc3cccc33ccc3cc3cc32ddddb222bdbb22db22bb2ddddbb2ddbdbb2d
333333332222222200000000000000000000cccccc6ccc6ccccc0000000000003333333033033330333333303332222222022222202202220222222022222202
00000000000000000000000000000000001100010000000010001100110111010022222000000000220022000000222200022222022202200000082200e16667
0000100000002000000010000000200001000000001000100000001010001000027798820000000279227920222227920006dddd276226d20000088200e1d666
000110000002200000011000000220000011000101010101100011001000100027988882222222229822982227982982200d22dd26dd2dd20000088200e155d6
0001100000022000000110000002200000001111010101011111000010001000288822227929288222298882988829888202222d26ddddd200000882000e1112
0001100000022000000110000002200000110001100010001000110001010101022888229828288298288882882228888822222d2dddddb200000f88000e1667
000000000000000000011000000220000100000010001000000000100101010127928882888888828822882288882882882d22db2dd2ddb200000f88000e1d66
000110000002200000010000000200000011000110001000100011000010001028888882288288228822882228882882882dddbb2db22bb200000788000e15d6
0000000000000000000000000000000000001111110111011111000000000000022222202222222022002200222222222222222202202220000007f8000e1112
00000000316363636363636363636363636363636363636341000031731252000000000000316363636363410072d35200006231637300000000536341620000
3173d353636363636363634100000000003173121313131313125363636363636373d30000012115021222050121d351f71212000000000000000000000000d3
00003163739200021222000000a200000000000000a2000053636373a2d352000000000000720000000003536373d35200003173000000000000000053410000
7292d3000000000000a200520031634100729100000000000000a200000000000000d300001222b4031323760212d3f2f7d3d300000000000000e100000000d3
63637300000000021222000000000000000000e10000e2000000000000d352000031634131730000000000000000d35200007200000000000000000000520000
7200d300000000000000005363731252317391f0e200e100e2000000e10000000000000000032300000000000323d3f2f7d300000000940000000000000000d3
011100000000000313230000e100c200000000000000000000000000000052003173125373150000e10000000000d3520031730000e100000000e10000534100
7200d30000e200e1000000000500d352f71291000000000000000000000000000000e10000c1f00000e100000000d3f2f7000000008415a40000560000516161
0204a40000000000050000000000516161616161805656949400e100e20052007292d3000015000000000000e100d35231730000000000000000000000005341
7291d3000000000000e200000500d352f7d3920000b1b1b1000000915161616171000000000000e2000000e2000000f2f70000e10000e2000046056600f20000
0204a4e200e100000500000000005341003163731212121212000000000052007200d30000150000e20000000000d35272000000000000000000000000000052
3271128105050500000000000500d352f7d312121212121212121212f2000000729100c20000949401112156560000f2f79100000011b1110000e20000f20000
0204a4000000e2000500001515e2915200721223000000012100e200000052007291d30000150000000000000000d35272000000a1000000000000a100000052
0032617200000000151515516171d352f7d3d3d3d3d3d3d3d3d3d3d3f200000032616171910015150212220505000053327105050512c1120011b11100f20000
031300000000000005000000003391520072d30000e1000323000005050553413271d35161800015151500516171125272000000000000000000000000000052
0000317300000000000000534172d35232616171120000000000d3d3534100000031636370801212c113c1121215151231737676760313230012c11200f20000
21000000009090011121050500e291520072d3000000000000000005000000536373d3537300000000000053413261427200a100000000000000000000a10052
3163730000000000000000005373d35200003173220000000000e2d343f20000317300a2000012c123e203c11215151272122100000000000003132300534100
2300e1000000000212220000000051420072d3151515159090050505000000000000d30005000000000000005363636373000000000000000000000000000053
7300000000e1000000e100001500d352000072122300e200e100940000f20000729200000000d3d3000000d3d3000051327122b10000e1000000000000005341
210000000111210212220001111152000072d30000000000000000000000e1000000d30005000000e10000000000000000000000e1000000000000e100000000
00000000000000e2000000001500d352003173d300005600008415a4005341007300e2000000d3d3e200e2d3d3000052007222c10000e2000000e10000001252
122100011212125161711151616142000072d30000e2000000000000000000000000d300050000000000e2000000000000000000000000e4f400000000000000
000000c200000000000000001500d3520072a2d3004605660000b40000a2f200c1f00000606171d300e100d351616142007212210000b1000000e2000000d352
7122e20251616142003261420000000000720000000000e100e20000000000000000d300050000000000000000c2000000000000000000e5f500000000000000
00005161711515151515516161711252007200d3000076000000b1000000f200c1f000e7c15273d3000000d353413163413271220012c1120000b1000000d352
72220002520000000000000000000000007291219090900000000000c20051616171125161617105050505516161616161616171000000c5d500000051616161
61614200722200e200025200003261420072c2d30000b1000002c12200005341c1f0e1e7c182000000b100004352721253417222005161710012c11200c2d352
72225602520000000000000000000000003261711111210090909051616142000032614200007211111111520000000000000032616161616161616142000000
00000000720505050505520000000000007291d30002c1220003132300e29152c1f000e7c1822100b1c1b100015272d30052721211520072005161710091d352
72120512536363636341000000000000626262326161711111111152626262626262626262623261616161426262626262626262626262626262626262626262
62000000722200e20002520000000000003271d3000313230000000000015142c1f000e7c1821211c112c111125272d33352721212520072115200722181d352
72000000000000000052317312536363636363634100003173230313132312537300000000000053637300000000005363636341729200000000000000000000
62316341722300000003520000000000000072d3000000000000000000e7c153720000005363634172121212125373d31253636373125200007212536373d352
72000000e100000051427292d300000000000000534100722200000000000000000000000000001500050000000000000000a252722100009400000000000000
31739253730000000000536363636341000072d3000000000000e2000000e7c17200000000a20053417192e2000000d3d300000000435363637392000000d352
72c200000000000052007200d30000000000000092523173230000000000000000000000e1000015e2050000e100049171c133527222008415a4000000000000
72000000000000e10000000000919252003173d30000e10000000000000000517200e1000000001252326171003300d3d30000e1000000333300000000000053
729100000000009152317300d300e1000000e1000052722200e20000e100000000c200000000001500050000000001513261614272120400b400000000e10000
720000e2000000000000c20091919152007292d300000000e2000000000000527200000000e2e7c153636341719100d3d300000000000115150000e100000091
32617104040451614272a200d30000000000000091527222000000000000125161712100000001516171c1000001125263634100721222330000000000000000
721200000012516161616161616161420072000000000000000000000000b1527200c20000000003131312523261616171151500e2000215150000000000b191
000072909090520031730000d30051617121e2015142722200004690660001520072122104011252003261616161614291035341721222e200e1000000000001
32719494945142003163636341000000317300841515a4000000e1000094c152721212120000000056e7c15341000000f712f00000000215a400e2000505c151
003173040404536373000000d3005200327104514231732300000000000002520072122204021253636363636363636380000353731204005600000000011112
62f7151515f2003173a200005363636373000000b4b400000000000000b402527292000000e100460566031253636341f712f00000000215a400000005052153
317323000000031323000000d30053410072335200722200e20000e1000002520072122304031212121313131212122300000003132300460566000111125161
62f7b4b4b45363730000000000460566a20000000046050566000000e2b1025272000000000056057600000313131252f7050500e1000215a400000046052212
7223000000000000000000000000a252317304534172220000000000000002523173230000000313230000000313230000000000000000007600041251614231
62f70000000000000000000000460566000000e1000076760000000056c1514272111121004605660000000094e7c153f712f000000002151500e10046052212
720000e10000050000e10000e20000537323e20353732300008490a4000151427223000000008404a40000004604660000000000000000000033021252003173
31730000000000000000e1000046056600000000000000000000000076025200326171c1f0e2760000e1008415a40313f712f000000003151500000046052212
72000000e2000500e200000000e100000000000000a20000000000000002520072000000e1008404a400e1004604660000e10000000000e100e2021252317323
72c1f00000e10000000000000051617100c200000000000000000000b1025200634172121111210000009415b400000073151500e20000000000000005052251
7200000000000500000000000000000000000000000000e20000e100000252007233000000008404a4000000460466000000000000e200009400041253732300
72c1f0e2000000000000e20000f200327191910000e200e100000094c1514200035232616171c1f0e28415a40000000000000000000000000000e20005052353
7221001515150505050500005600000000000000e1000000000000000002520072210000e2008404a400e2004604660000c200000000008415a4000313230001
72c1f000000000000000000000f200003271c1f000000000000000b40252000000536363417212111121b40000e1000000000000000000e10000000000011111
7222000111210001112100460466000000000000000000004690660001514200327121909090011121909090011121516161710004040400b400000000011112
32710000005161710000b10000f200000031800000000000000000b102520000000012915232616171c1f0e20000000000000000910000000000000001125161
72121112121211121212210076000151617100c20000040001112100025200000072121111111212121111111212125200007221000000011121000111125161
62f7000000f200721111c11111f200003173000000011111115171c1514200002100121253636341721211112100000000c20000910091919100910002514200
32616161616161616171121111111252007291919101112102122201514200000032616161616161616161616161614200007212111111121212111251614200
62f7111111f200326161616161420000731111111112516161423261420000001221000000031352326161711211516161617111911191919111911151420000
__label__
hhhhhhhhhhhhhhhhhhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhhhhhhhhhhhhhhhhhh
0h0000000h0000000hh1tddd0hhh11111h1111111h111hhh0h0000000h0000000h0000000h0000000hhh11111h1111111h111hhhdt21h0000h0000000h000000
0h0000000h0000000hh122td0hh111111hddddd11h1111hh0h0000000h0000000h0000000h0000000hh111111hddddd11h1111hhddt1h0000h0000000h000000
0h0000000h0000000h0h1112hh111111dhdddddddh11111hhh0000000h0000000h0000000h000000hh111111dhdddddddh11111h6dd1h0000h0000000h000000
hhhhhhhhhhhhhhhhhhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh8hhhhhhhhhhh2111hhhhhhhhhhhhhhhhhhhh
0000h0000000h000000h1tddh111h1ddddddhdddddd1h111hh00h0000000h0000000h0000000h00hh111h1ddddddhdddddd1h111dt221h000000h0000000h000
0000h0000000h000000h12tdh111hdddddddhdddddddh111hh00h0000000h0000000h0000000h00hh111hdddddddhdddddddh111dddt1h000000h0000000h000
0000h0000000h000000h11121111hdddddddhdddddddh1111hh0h0000000h0000000h0000000h0hh1111hdddddddhdddddddh1116ddd1h000000h0000000h000
hhhhhhhhhhhhhhhhhhhhh112hhhhhhhhhhh88hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh88hhhhhhhhhhh211hhhhhhhhhhhhhhhhhhhhh
0h0000000h0000000h0h12td1h11dddddhd898dddhddd1111hh000000h0000000h0000000h0000hh1h11dddddhd898dddhddd111dt21h0000h0000000h000000
0h0000000h0000000h0h1tdd1h11dddddh89a8dddhddd1111hh000000h0000000h0000000h0000hh1h11dddddh89a8dddhddd1116dt1h0000h0000000h000000
0h0000000h0000hhhhhh1dd61h11dddddh8a7a8ddhddd1111hh000000h0000000h0000000h0000hh1h11dddddh8a7a8ddhddd111211hhhhhhh0000000h000000
hhhhhhhhhhhhhh11h11h1112hhhhhhhhhh14441hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh14441hhhhhhhhhdt21111hhhhhhhhhhhhhhhhh
0000h0000000h1td12t122td1111hddddd14421dddddh1111hh0h0000000h0000000h0000000h0hh1111hddddd14421dddddh111ddt1dt21111hh0000000h000
0000h0000000h1dd1td1tdddh111hdddddd121ddddddh111hh00h0000000h0000000h0000000h00hh111hdddddd121ddddddh111ddt1ddt11dt1h0000000h000
0000h000000hh1112d62ddd6h111h1dddddd1dddddd1h111hh00h0000000h0000000h0000000h00hh111h1dddddd1dddddd1h1116dd26dd21dd1h0000000h000
hhhhhhhhhhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhhhhhhhhhh
0h0000000hh1tddd0h000000hh111111dhdddddddh11111hhh0000000h0000000h0000000h000000hh111111dhdddddddh11111hhh000000dt21h0000h000000
0h0000000hh122td0h0000000hh111111hddddd11h1111hh0h0000000h0000000h0000000h0000000hh111111hddddd11h1111hh0h000000ddt1h0000h000000
0h0000000h0h11120h0000000hhh11111h1111111h111hhh0h0000000h0000000h0000000h0000000hhh11111h1111111h111hhh0h0000006dd1h0000h000000
hhhhhhhhhhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhhhhhhhhhh
0000h000000h1tdd0000h000000hhhh11111h11111hhhh000000h0000000h0000000h0000000h000000hhhh11111h11111hhhh000000h000dt221h000000h000
0000h000000h12td0000h0000000hhhhh111h111hhhhh0000000h0000000h0000000h0000000h0000000hhhhh111h111hhhhh0000000h000dddt1h000000h000
0000h000000h11120000h0000000h0hhhhhhhhhhhhh0h0000000h0000000h0000000h0000000h0000000h0hhhhhhhhhhhhh0h0000000h0006ddd1h000000h000
hhhhhhhhhhhhh112hhhhhhhhhhhhhhhhhh2222222222hhhhhhhhhhhhhhhhhh2222hhhh2222hhhhhhhhhhhh22222222hhhhhhhhhhhhhhhhhh211hhhhhhhhhhhhh
0h0000000h0h12td0h0000000h0000000h222222222200000h0000000h00002222000022220000000h000022222222000h0000000h000000dt21h0000h000000
0h0000000h0h1tdd0h0000000h00000022777799888822000h0000000h002277992222779922002222222222779922000h0000000h0000006dt1h0000h000000
0h0000hhhhhh1dd60h0000000h00000022777799888822000h0000000h002277992222779922002222222222779922000h0000000h000000211hhhhhhh000000
hhhhhh11h11h1112hhhhhhhhhhhhhh227799888888882222222222222222229988222299882222227799882299882222hhhhhhhhhhhhhhhhdt21111hhhhhhhhh
0000h1td12t122td0000h0000000h02277998888888822222222222222222299882222998822222277998822998822220000h0000000h000ddt1dt21111hh000
0000h1dd1td1tddd0000h0000000h02288888822222222779922992288882222222299888888229988888822998888882200h0000000h000ddt1ddt11dt1h000
000hh1112d62ddd60000h0000000h02288888822222222779922992288882222222299888888229988888822998888882200h0000000h0006dd26dd21dd1h000
hhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhh22228888882222998822882288882299882288888888228888222222888888888822hhhhhhhhhhhhhhhhhhhh2111hhhh
0hh1tddd0h0000000h0000000h0000002222888888222299882288228888229988228888888822888822222288888888882200000h0000000h000000dt21h000
0hh122td0h0000000h0000000h0000227799228888882288888888888888228888222288882222888888882288882288882200000h0000000h000000ddt1h000
0h0h11120h0000000h0000000h0000227799228888882288888888888888228888222288882222888888882288882288882200000h0000000h0000006dd1h000
hhhh1dd6hhhhhhhhhhhhhhhhhhhhhh2288888888888822228888228888222288882222888822222288888822888822888822hhhhhhhhhhhhhhhhhhhh2111hhhh
000h1tdd0000h0hhhhhhhhhhhhh0h02288888888888822228888228888222288882222888822222288888822888822888822h0hhhhhhhhhhhhh0h000dt221h00
000h12td0000hhhhh111h111hhhhh000222222222222h022222222222222h0222200h0222200h02222222222222222222222hhhhh111h111hhhhh000dddt1h00
000h1112000hhhh11111h11111hhhh00222222222222h022222222222222h0222200h0222200h02222222222222222222222hhh11111h11111hhhh006ddd1h00
hhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
0hh1tddd0hhh11111h1111111h111hhh0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000hhh11111h1111111h111hhhdt21h000
0hh122td0hh111111hddddd11h1111hh0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000hh111111hddddd11h1111hhddt1h000
0h0h1112hh111111dhdddddddh11111hhh0000000h0000000h0000000h0000000h0000000h0000000h0000000h000000hh111111dhdddddddh11111h6dd1h000
hhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhsssssssssssshhhhsssshhhhhhhhhhhhhhhhhhhhsssssssshhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
000h1tddh111h1ddddddhdddddd1h111hh00h0ssssssssssss00h0ssss00h0000000h0000000h0ssssssss000000h00hh111h1ddddddhdddddd1h111dt221h00
000h12tdh111hdddddddhdddddddh111hh00h0ss7766ccccccssss7766ssh0000000h0ssssssssss7766ssssssssh00hh111hdddddddhdddddddh111dddt1h00
000h11121111hdddddddhdddddddh1111hh0h0ss7766ccccccssss7766ssh0000000h0ssssssssss7766ssssssssh0hh1111hddddddd8dddddddh1116ddd1h00
hhh1ddd6hhhhhhhhhhh88hhhhhhhhhhhhhhhhhss66ccccccccccss66ccssssssssssssss7766ccss66ccss66ccsshhhhhhhhhhhhhhh88hhhhhhhhhhh2111hhhh
0hh1tddd1h11dddddhd898dddhddd1111hh000ss66ccccccccccss66ccssssssssssssss7766ccss66ccss66ccss00hh1h11dddddhd898dddhddd111dt21h000
0hh122td1h11dddddh89a8dddhddd1111hh000ss66ccssssccccssccccss776666ccss66ccccccss66ccccccccss00hh1h11dddddh89a8dddhddd111ddt1h000
0h0h11121h11dddddh8a7a8ddhddd1111hh000ss66ccssssccccssccccss776666ccss66ccccccss66ccccccccss00hh1h11dddddh8a7a8ddhddd1116dd1h000
hhhh1dd6hhhhhhhhhh14441hhhhhhhhhhhhhhhssccccccccccssssccccss66ccccccssccccssssssccccccsssshhhhhhhhhhhhhhhh14441hhhhhhhhh2111hhhh
000h1tdd1111hddddd14421dddddh1111hh0h0ssccccccccccssssccccss66ccccccssccccssssssccccccssss00h0hh1111hddddd14421dddddh111dt221h00
000h12tdh111hdddddd121ddddddh111hh00h0ssccccssssccccssccccssccccssccssccccccccssccccccccccssh00hh111hdddddd121ddddddh111dddt1h00
000h1112h111h1dddddd1dddddd1h111hh00h0ssccccssssccccssccccssccccssccssccccccccssccccccccccssh00hh111h1dddddd1dddddd1h1116ddd1h00
hhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhssccccccccccccssccccssccccccccssssccccccssccccssccccsshhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
0hh1tdddhh111111dhdddddddh11111hhh0000ssccccccccccccssccccssccccccccssssccccccssccccssccccss0000hh111111dhdddddddh11111hdt21h000
0hh122td0hh111111hddddd11h1111hh0h0000ssssssssssssss00ssss00ssssssss00ssssssssssssss00ssssss00000hh111111hddddd11h1111hhddt1h000
0h0h11120hhh11111h1111111h111hhh0h0000ssssssssssssss00ssss00ssssssss00ssssssssssssss00ssssss00000hhh11111h1111111h111hhh6dd1h000
hhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
000h1tdd000hhhh11111h11111hhhh000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000000hhhh11111h11111hhhh00dt221h00
000h12td0000hhhhh111h111hhhhh0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000hhhhh111h111hhhhh000dddt1h00
000h11120000h0hhhhhhhhhhhhh0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0hhhhhhhhhhhhh0h0006ddd1h00
hhh1ddd6hhhhhh22222222222222hh222222222222hh222222hh2222hh222222222222hh222222222222hh222222222222hh222222hh2222hhhhhhhh2111hhhh
0hh1tddd0h00002222222222222200222222222222002222220022220h2222222222220022222222222200222222222222002222220022220h000000dt21h000
0hh122td0h0000227766dddddd222277662222dddd227766222266dd227766dddddddd227766dddddddd227766dddddddd227766222266dd22000000ddt1h000
0h0h11120h0000227766dddddd222277662222dddd227766222266dd227766dddddddd227766dddddddd227766dddddddd227766222266dd220000006dd1h000
hhhh1dd6hhhhhh2266dd2222dddd2266dd2222dddd2266dddd22dddd2266dd2222dddd2266dd222222222266dd2222dddd2266dddd22dddd22hhhhhh2111hhhh
000h1tdd0000h02266dd2222dddd2266dd2222dddd2266dddd22dddd2266dd2222dddd2266dd222222222266dd2222dddd2266dddd22dddd2200h000dt221h00
000h12td0000h02266dd222222dd2266dd2222dddd2266dddddddddd226622222222222266dddddd2200226622222222dd2266dddddddddd2200h000dddt1h00
000h11120000h02266dd222222dd2266dd2222dddd2266dddddddddd226622222222222266dddddd2200226622222222dd2266dddddddddd2200h0006ddd1h00
hhh1ddd6hhhhhh22dddd222222tt22dddd2222ddtt22dddddddddddd22dd2222dddddd22dddd2222222222dd22222222dd22ddddddddddtt22hhhhhh2111hhhh
0hh1tddd0h000022dddd222222tt22dddd2222ddtt22dddddddddddd22dd2222dddddd22dddd2222222222dd22222222dd22ddddddddddtt22000000dt21h000
0hh122td0h000022dddd2222ddtt22ddddddddddtt22dddd22ddddtt22dddd2222ddtt22ddddddddddtt22dddd2222ddtt22dddd22ddddtt22000000ddt1h000
0h0h11120h000022dddd2222ddtt22ddddddddddtt22dddd22ddddtt22dddd2222ddtt22ddddddddddtt22dddd2222ddtt22dddd22ddddtt220000006dd1h000
hhhh1dd6hhhhhh22ddddddddtt222222ttddtttt2222ddtt2222tttt22ddddddddtttt22ddddttddtttt22ddddddddtttt22ddtt2222tttt22hhhhhh2111hhhh
000h1tdd0000h022ddddddddtt222222ttddtttt2222ddtt2222tttt22ddddddddtttt22ddddttddtttt22ddddddddtttt22ddtt2222tttt2200h000dt221h00
000h12td0000h022222222222222h0222222222222002222002222220022222222222200222222222222h0222222222222002222002222220000h000dddt1h00
000h11120000h022222222222222h0222222222222002222002222220022222222222200222222222222h0222222222222002222002222220000h0006ddd1h00
hhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
0hh1tddd0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000000dt21h000
0hh122td0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000000ddt1h000
0h0h11120h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000006dd1h000
hhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhh
000h1tdd0000h0000000h0hhhhhhhhhhhhh0h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0hhhhhhhhhhhhh0h0000000h000dt221h00
000h12td0000h0000000hhhhh111h111hhhhh0000000h0000000h0000000h0000000h0000000h0000000h0000000hhhhh111h111hhhhh0000000h000dddt1h00
000h11120000h000000hhhh11111h11111hhhh000000h0000000h0000000h0000000h0000000h0000000h000000hhhh11111h11111hhhh000000h0006ddd1h00
hhhh1dd12dd62dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh6ddd26d2111hhhhh
0h0h1td11tdd1tdd0hhh11111h1111111h111hhh0h0000000h0000000h0000000h0000000h0000000h0000000hhh11111h1111111h111hhhdddt1dt1dd1h0000
0h00h11112td1tdd0hh111111hddddd11h1111hh0h0000000h0000000h0000000h0000000h0000000h0000000hh111111hddddd11h1111hhdt221t21dt1h0000
0h000hhhh11112tdhh111111dhdddddddh11111hhh0000000h0000000h0000000h0000000h0000000h000000hh111111dhdddddddh11111h2111h11h11h00000
hhhhhhhhhhhhh112hhhhhhhhhhhhhhhhhhhhhhhhhhh1111111hhhhhhhhhhhhhhhhhhhhhhhhhhhhh1111111hhhhhhhhhhhhhhhhhhhhhhhhhh6dd1hhhhhhhhhhhh
0000h000000h1td6h111h1ddddddhdddddd1h111hh1177777110h00111111111111111111110h0117777711hh111h1ddddddhdddddd1h111ddt1h0000000h000
0000h000000h12tdh111hdddddddhdddddddh111hh1771717710h01177177717771777177710h0177111771hh111hdddddddhdddddddh111dt21h0000000h000
0000h000000hh1121111hdddddddhdddddddh1111h1777177710h01711117117171717117110h0177171771h1111hdddddddhdddddddh111211hh0000000h000
hhhhhhhhhhh1ddd6hhhhhhhhhhh88hhhhhhhhhhhhh177171771hhh17771171177717711171hhhh177111771hhhhhhhhhhhh88hhhhhhhhhhh2111hhhhhhhhhhhh
0h0000000hh1tddd1h11dddddhd898dddhddd1111h117777711000111711711717171711710000117777711h1h11dddddhd898dddhddd111dt21h0000h000000
0h0000000hh122td1h11dddddh89a8dddhddd1111h111111111000177111711717171711710000111111111h1h11dddddh89a8dddhddd111ddt1h0000h000000
0h0000000h0h11121h11dddddh8a7a8ddhddd1111hh1111111000011110111111111111111000001111111hh1h11dddddh8a7a8ddhddd1116dd1h0000h000000
hhhhhhhhhhhh1dd6hhhhhhhhhh14441hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh14441hhhhhhhhh2111hhhhhhhhhhhh
0000h000000h1tdd1111hddddd14421dddddh1111hh0h0000000h0000000h0000000h0000000h0000000h0hh1111hddddd14421dddddh111dt221h000000h000
0000h000000h12tdh111hdddddd121ddddddh111hh00h0000000h0000000h0000000h0000000h0000000h00hh111hdddddd121ddddddh111dddt1h000000h000
0000h000000h1112h111h1dddddd1dddddd1h111hh00h0000000h0000000h0000000h0000000h0000000h00hh111h1dddddd1dddddd1h1116ddd1h000000h000
hhhhhhhhhhh1ddd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhhhhhhhhhh
0h0000000hh1tdddhh111111dhdddddddh11111hhh0000000h0000000h0000000h0000000h0000000h000000hh111111dhdddddddh11111hdt21h0000h000000
0h0000000hh122td0hh111111hddddd11h1111hh0h0000000h0000000h0000000h0000000h0000000h0000000hh111111hddddd11h1111hhddt1h0000h000000
0h0000000h0h11120hhh11111h1111111h111hhh0h0000000h0000000h0000000h0000000h0000000h0000000hhh11111h1111111h111hhh6dd1h0000h000000
hhhhhhhhhhhh1dd6hhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh2111hhhhhhhhhhhh
0000h000000h1tdd000hhhh11111h11111hhhh000000h0000000h0000000h0000000h0000000h0000000h000000hhhh11111h11111hhhh00dt221h000000h000
0000h000000h12td0000hhhhh1111111111111111110h01111111110001111111111111111111110001111111111111111111111hhhhh000dddt1h000000h000
0000h000000h11120000h0hhhh11dd1ddd1ddd1ddd10h01ddd1d1d11111ddd1ddd1ddd11dd1d1d10001ddd1ddd1ddd11dd1d1d1hhhh0h0006ddd1h000000h000
hhhhhhhhhhhh1dd12dd62dd6hh1d111d1d1ddd1d111hhh1d1d1d1d11d11ddd11d111d11d111d1d1hhh1ddd1d1d11d11d111d1d1h6ddd26d2111hhhhhhhhhhhhh
0h0000000h0h1td11tdd1tdd0h1d111ddd1d1d1dd100001dd11ddd11111d1d11d101d11d1h1ddd100h1d1d1ddd11d11d1h1ddd10dddt1dt1dd1h00000h000000
0h0000000h00h11112td1tdd0h1d1d1d1d1d1d1d1110001d1d111d11d11d1d11d111d11d111d1d11111d1d1d1d11d11d111d1d10dt221t21dt1h00000h000000
0h0000000h000hhhh11112td0h1ddd1d1d1d1d1ddd10001ddd1ddd11111d1d1ddd11d111dd1d1d1ddd1d1d1d1d11d111dd1d1d102111h11h11h000000h000000
hhhhhhhhhhhhhhhhhhhhh112hh11111111111111111hhh111111111hhh111111111111h11111111111111111111111h11111111h6dd1hhhhhhhhhhhhhhhhhhhh
0000h0000000h000000h1td60000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000ddt1h0000000h0000000h000
0000h0000000h000000h12td0000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000dt21h0000000h0000000h000
0000h0000000h000000hh1120000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h000211hh0000000h0000000h000
hhhhhhhhhhhhhhhhhhh1ddd6hhhhhhhhhh111111111111111111111hhh111111111hhhh111111111111111111111111hhhhhhhhh2111hh11111111hhhh11111h
0h0000000h0000000hh1tddd0h0000000h1ddd1d1d11dd1ddd11dd100h1ddd1d1d111111dd1ddd1d1d1ddd1ddd1ddd100h000000dt21h01d1d1dd1000h1ddd10
0h0000000h0000000hh122td0h0000000h1ddd1d1d1d1111d11d11100h1d1d1d1d11d11d111d1d1d1d1d1d1d111d1d100h000000ddt1h01d1d11d1000h1d1d10
0h0000000h0000000h0h11120h0000000h1d1d1d1d1ddd11d11d10000h1dd11ddd11111d111dd11d1d1dd11dd11dd1100h0000006dd1h01d1d11d1000h1d1d10
hhhhhhhhhhhhhhhhhhhh1dd6hhhhhhhhhh1d1d1d1d111d11d11d111hhh1d1d111d11d11d1d1d1d1d1d1d1d1d111d1d1hhhhhhhhh2111hh1ddd11d111111d1d1h
0000h0000000h000000h1tdd0000h000001d1d11dd1dd11ddd11dd10001ddd1ddd11111ddd1d1d11dd1ddd1ddd1d1d100000h000dt221h11d11ddd11d11ddd10
0000h0000000h000000h12td0000h000001111111111111111111110001111111110h0111111111111111111111111100000h000dddt1h011111111111111110
0000h0000000h000000h11120000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0000000h0006ddd1h000000h0000000h000

__gff__
0000000000000303030703030300070004040403030303030303010003000000040304030303070303000000000000030404040000030303030000070008000007030303000700000404040400000000070700000303000000000000000000000000000004040404000000000000000000000000000000000000000000000003
0000000000000000030303000303000004000000000000000300030303030000000000000000000003030300000000000000000000000000030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3200000030213536372131313131313536363636140037320000000000303514000000133700000000000000353614000000270000000000000000000025000000001336363636363721542154213536363721545421212154542135363614000000133636363637542121543537000000003054353636361400000000000000
000000000000002a00101100000000000000003035373200000000000000303536140027290000000000000030213514001337001e0000000000001e003514000013372900000000003d733d723d000000003d737300000072723d00003435140000271933000000720000730000000000000072000030543536363614001336
00494949000000000020510000000000000000000000000000001e2e001100003035363700002e001e000000003021250027000000000000000000000000250000270000001e0000003d733d723d000000003d737300000072723d000000002500002722510000007200007300001e0000000072000000720000305435363721
484b4b484a001e00002051002e001e00001e00000000000000000000483c00000000002a0000000000002e3b3b002035133700000000000000000000000035141337000000000000003d733d723d000000003d737300000072723d000000002500002722512e001e72002e73000000000000007200000072000000720000003d
484a00484a00000000303100000000000000002e001e00002e001100483c000000000000005151120000003b3b003031270000000000000000000000000000252755626252151617193d733d723d0000002c3d73732e1e2e72723d000000002500133732510000007200007300000000002c0072001e0072000000720000003d
484a49494a000000003b120000002c00000000000000000000643b00483c0000001e00005051513200002e5050002021270000000000000000000000000000252317002e00250023173d713d723d1516161721737300000072722118002e0035002722500000000072000073001516161616087000000072000000720000003d
004b4b4b00111200003b220010151616161617000000000000643b00003100000000005050303200000000505000202127001e000000000000000000001e00250027000000351400273d003d703d250000231771730000007270185563636355002722502e00001054121054122500000027101149000072001e00720000003d
00000000005022000051223320250000133637004949490000643b000000000000001517123c00001e002e3b3b0010112700000000000000000000000000002500275363635525002700003d000025000000270071000000700025170000001513373250000000305432305432250000002720504a000070000000720000003d
00000000005022000051320030351400272132483c3c3c4a000031002c00000000152427223c2e000000003b3b0020152700000000000000000000000000002500270000001524002733000000332500000027000000000000002537002e003527225100000000007300007200351400133720504a2e101149000072001e003d
00001e00005022000000000000002500373200004b4b4b00000000000616161616241337223c00000000101111112125270000000000000000000000000000251337002e002500133700001e00003514000027000010111200002855626262552722512e001e00007300007200303514270020504a0020504a0000700000003d
00000000003132002e00000000002500223b2e0000000000001e00000025000000002721323b0000000020151607072427000000000000000000000000000025275562625235363700000000001011250000271011211821111225170000001527325100000000007300007200003435370030314b0020504a3310114900003d
000000000000000000001e0011123514223b33000000332e000000000035140000002722003b2e0000003035372121252317000000000000000000000000152423170000002a00000000000000302125000027211507360717212537002e00352719330000000000732e0072001e002121111111120020504a0020504a000000
0020512200002050502200003c220025223b2e0000005151000000000000353600002732003b00001e000000003d3d250027001e00000000000000001e00250000270000000000000000000000003d250000231637290034350737556363635523161616171c0000730000720000003d16161617220030314b0020504a2e0000
0030313200003031313200003c2200251712000000101111120000000010112100133700000000000000002c003d3d250027000000000000000000000000250000271900000000001e00000000003d25000000272900000048514a0000000015000000002317000073000072002c003d3614002721111111120020504a000000
0000000000002e332e000000313200252721111111211517211111111121151600270000004851514a151616173d3d25002317000000000000000000001524000023161617000000000000002c003d250000002700001e0048514a00000000250000000000271111541111541516173d3325002316161617220030314b000000
12000000102115161721111111111135272115161721252721151616172125000027111111124b4b10353614273d3d250000272626262626262626262625000000000000271250660048511015173d25000000231700000015161616161616240000000000231616161616162400273d21250026262626272111111112101112
1711111135363637212121353636363636363721006500000000004900213536363731313132212120212125273d3d251336370000002121212100000035361400000013373200000000003035373d25133636370000000025133721353636141336363721545454545454542135373d13361400000000133636363732000000
2316161732002a003d3d3d000000000000000050643b66001e00483c4a512a00002a00000000000030313135373d3d252700000000007f00002f00000000002513363637000000000000000000003d2527000000000000002527003d00002a35370000003d727273737372723d00003d27292500133636371c0f0f2e00000000
0000133700000000003d000000001e0000000050643b662e002e483c4a5100000000000050000000003b3b00003d3d252700000000007f00002f0000000000252729002a000000001e002e0000003d2527000000000000151337003d00000000000000003d727271737172723d00003d27123536371c0f0f3300000000000000
3636373200001e000000000000000000002c0050643b66000000483c4a51000000001e0050000000003b3b0000003d252700000000007f00002f00000000002537000000000000000000000000003d2527001e002c0015243729003d001e000000001e003d727000730070723d001e3d27211c0f0f2e00000000000000000000
31313200000000003b3b3b001516161616161617006700003c00004b0015161617002c0050001e00003b3b001e003d352700000000007f00002f0000000000251c00001e00002e00000065505018212527000021211524272200003d00000000000000003d720000730000723d00003d273d0000000000000000001e00000000
171200002e000000004900003514000000001337101200003c000010123536142316080050000000003b3b0000003d1c2700000000007f00002f0000000000251700000000000000005050500614162437002e00351413373200003d0000000000002c003d722e0073002e723d00003d273d000000001e000000000000000000
2722003c3c3c000000514a000035361400133732303210123310123032003035133700005000000048515100001021152700000000007f00002f0000000000252700000000000049515100000035361455625200002527224900003d0006161616161617217200007300007221151721273d0000000010111111120010111200
37320000000000002e514a00002a303536370000000030320030320000000000372a0000000000004851512e002021252700330033007f00002f003300330025271900000000515151000000000021251721210000252722504a0000002025000000133608700000730000700636141627215151511021313131211121312111
111112000065001e00514a00000000002a00000000000000003c3c00001e00000000000000000000004b4b00003021352700001e00007f00002f00001e000025231616161700000000001e0000003d252729002e00352722504a0000003035140000272251660000710000645120250027324b4b4b2132003300302132003021
1617220064500000004b00001e000000000000003b3b001e003c3c0000000000000000001e0000000000000000003d1c272e0000002e7f00002f2e0000002e250013361337002e00002e00002e003d252700005363552822504a001e00652025000027225166000049000064512025002765002e00650000000000650000003d
0027220064502e000000000000000000001e00003b3b0000003c3c002c00000000002e00000000000000000000003d1527002e2e2e007f00002f002e2e2e002513372138000054000054000054003d2527000021211537324b000000645120250000272251660048504a00645120250027506600645000001e000050661e003d
00272200645000000000000000000000000000003b3b002e00515115161700000000000000002e000000001e00003d252700000000007f00002f00000000002527003d00000072000073000072003d2537002e003537320000000000645120250000231767000048504a0000671524002750661b64502e001b002e506600003d
002721111267000000000000002c000000002e005050000000515125002719151617003c3c0000000000000000003d252700000000007f00002f00000000002527003d001e0072000073000072003d25556252000000000000000000645120250000133712000048504a0000103514002750661c6450001b1c1b0050662c003d
002317212200003b3b003c3c00151616172100005050000000515125002316240027000000003b3b000000002c003d252700000000007f00002f00000000002527003d00000072000073000072003d25172121000000001e000000000067303500133731211112004b001011213135143721151617211b1c311c1b211919193d
000023172112001011111112002500002722000050500010111111250000000013371011111200000015161616173d252316161617007f00002f00151616162427003d002c0070000071000070003d2523161719000000000000151700000030133721003021211111112121320021353421353637211c3200301c211516173d
000000231617112115161721112500002721111111111121151616240000000037102115172111111225000000273d250000000023177f00002f15240000000023173d151617111517111517111821250000231616161617111225271011111137293d33003031313131313200333d343321000000210000330000213536373d
__sfx__
000100000d0400d0300f020100201203015040190501e060240702b0001a0001a00008000080000800008000080002f0002f0002f0002f0002f0000d0000d0000d0000d0000e0003b0003b0003b0003b00000000
000100001c070190701607014070100700e0700c0700a07007070110700f0700d0700b0700807006070050700407003070090700707006070040700307002070211001e100000001c1001a1001a1001a1001c100
000300001a6211e621216211f621196211462113621166211b621216211f62118621126210e6210e6210f621116211562115621106210a62108621086210a6210a62106621036210162102621036210162100601
000100000f0400f030100201202014030190401e05022060270702b0001a0001a00008000080000800008000080002f0002f0002f0002f0002f0000d0000d0000d0000d0000e0003b0003b0003b0003b00000000
040300001d6710d601126011160100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601006010060100601
100200002b7432b7432b74324743247431f7431f7431f7431874318743187431374313743137430f7430f7430f7430a7430a7430a743057430574305743057430550305503055030550300503005030050300503
12020000115721157216572165721f5721f5720050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
100300001855018550225502255027550275501f5501f55024550245502e5502e5503755037550335503355024500245001b5001b50013500135000a5000a5000550005500055000550000500005000050000500
000a00001b05516055180551b0551d055220551f0551b0551b0553300535005330050000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500005
0002000030652306022d60239602396023960238602346022e6020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
000100001667316173165731660300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003
910100001766314663126631460300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603006030060300603
a20200001d6761a6761c6761d6761d676006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600006000060000600
0002000016257182571b2571f257222571324716247182371b2371f2370a2270c2270f22713200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e2501e2501c2501b2501825015250112500c250042500d20009200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000625007250092500b2500e25011250162501b250222500d20009200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
020100001276215162155621600200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002000020000200002
11030000181111d1211f13122131221211d111181111611116111161111b1211f13122131221311f1311b12116111161111b1111f12122131221311f1311b1211711112111091010810107101071010710106101
92030000182511d2511f25122251222511f2511a2411724116241172411b2411f23122231222311f2211b22117221162111b2011f20122201222011f2011b2010b2010a201092010820107201072010720106201
900e00000962112631196311f64124641276412764125641216311c63116631106210d6210a621086210661105611046110361103611026110161101611016110061100611006110061100611006110061100611
d00a00002005024050270402e040270302e030270202e020270102e010270002e0002100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
d00d00002053024530275302e530275302e530275302e520275202e510275102f5002150000500005000050000500005000050000500005000050000500005000050000500005000050000500005000050000500
10140000155521a5521d5521a55215552195521d55219552155521a5521d5521a55216550185001b5001d500155021d5021d5021d5021d502195021950219502195021b502115020f50211502155021e50222502
000d00000c033004350023510425376150043510225004350c033004250022510435376150043510225104250c033004350023510425376150043510225004350c03310425102250043537615004351022500435
000d00000c033024350223512425376150243512225024350c033124251222502435376150243502235124250c033024350223512425376150243512225024350c03302425122250243537615124350222512425
000d00000c033044350423513425376150443513225044350c033134251322504435376150443513225134250c033044350423513425376150443513225044350c03313425132250443537615044351322513425
000d00002b5352a4252821523535214251f2151e5351c4252b215235352a425232152d5352b4252a2152b535284252a215285352642523215215351f4251c2151a535174251e2151a5351c4251e2151f53523215
000d000028535234252d2152b5352a4252b2152f53532225395103723536520374153b2303952537410342353652034215325352f2202d5152b2302a4252b510284352622623510214351f22023515284102a225
000d00002b5352a43528235235352b5252a42528525235252b5252a02528525235252b0252a02528725237252b0252a01528715237151f7151e7151c715177151f7151e7151c715177151371512715107150b715
000c00200c0530c235004303a324004453c3253c3240c0533c6150c0530044000440002353e5253e5250c1530c0530f244034451b323034453702437522370253c6153e5250334003440032351b3230c0531b323
101400001f0001f0001f0000000000000000000000000000000000000000000135000f50011500135001650000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00200c04312225064203a314064353c3153c3140c0433c6150c0430643006430062253e5153e5150c1430c04311234054351b313054353a0142e5123a0153c6153e51503335054351322605426033351b313
000c00202201524215244102431422415243152431422315223152401522410242142221524415245152421522315222142441524316224152401424512220152451524514223152441522217244162431522315
000c0000224002b4102e41030410304103041033410304103041030212294102b2102e410302102b410272102a4102a4122a41227410274102741025411274112741027410274102721027412272122741227212
000c00002a4102a4122a412274102741027412272122741527400254102a2102e4102b2102a416252102a4102741027412274122441024212244122241124411244102441024410244102421024412182110c411
0014000020734200351c7341c0351973419535157343952520734200351c7341c0351953219035147341503121734210351c7341c0261973419035237341703521734395251c7341c03519734195351773717035
001400000c043090552072409055246151972315555090550c053090651972309565207242461509065155650c053060652072406065246151672306065125650c05306065167230656520724246150606515555
001400000c053021651e7240206524615197450e7650c05302165020651e7341e7350256524615020650e56501165010651e7240c05324615167230b0450d0650c05301165197440b56520724246150106515555
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242a74228742287451c7341e7421e7421e735237241702521724395251c7341c03519734195351773617035
0014000020724200251c7241c02525742287421572439525207242a7422c7412c7322c72219025147242f7422d7422d7452d734217422174221735237241702521724395251c7341c03519734195351773617035
001000201905000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000360413504134041320412f0312b03125031200311c021170210f021070210001106000030010200102001000010000100001000010000100001000010000100001000010000100001000010000100001
000d00003c0513905135051320512e0512904124041200411c03118031140310e0310702101021040010200101001000010000100001000010000100001000010000100001000010000100001000010000100001
a60100001c030190301603014030100300e0300c0300a03007030110200f0200d0200b0200802006020050200402003020090100701006010040100301002010211001e100000001c1001a1001a1001a1001c100
000100000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1203000018552185521d5521d55222552225522755227552005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
12020000115721157216572165721f5721f5720050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502005020050200502
__music__
00 17424344
00 18424344
00 19424344
00 191a4344
00 171a4344
00 181b4344
02 191c4344
00 1d424344
00 1f424344
01 1d204344
00 1f204344
00 1d204344
00 1f204344
00 1d214344
00 1f224344
00 1d214344
02 1f224344
01 23244344
00 23254344
00 26244344
00 27254344
00 26244344
02 27254344

