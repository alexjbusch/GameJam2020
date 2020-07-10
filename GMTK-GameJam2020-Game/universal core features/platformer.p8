pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
function _init()
  player={
    sp=1,
    x=59,
    y=59,
    saved_x=59,
    saved_y=59,
    w=8,
    h=8,
    flp=false,
    dx=0,
    dy=0,
    max_dx=2,
    max_dy=3,
    acc=0.5,
    boost=4,
    anim=0,
    running=false,
    jumping=false,
    falling=false,
    sliding=false,
    landed=false,
    dead=false
  }

  gravity=0.3
  friction=0.85

  --simple camera
  cam_x=0

  --map limits
  map_start=0
  map_end=1024
end

-->8
--update and draw

function _update()
  player_update()
  player_animate()

  --simple camera
  cam_x=player.x-64+(player.w/2)
  if cam_x<map_start then
     cam_x=map_start
  end
  if cam_x>map_end-128 then
     cam_x=map_end-128
  end
  camera(cam_x,0)
end

function _draw()
  cls()
  map(0,0)
  spr(player.sp,player.x,player.y,1,1,player.flp)
end

-->8
--collisions

--[[
flags
 0=down
 1=right
 2=left
 3=up
 4=damage
 5=interact
 6=save
]]--
saved = false
ready_to_save = true

function collide_map(obj,aim,flag,self)
 --obj = table needs x,y,w,h
 --aim = left,right,up,down

 --mset(rnd(8),obj.y,85)

 local x=obj.x  local y=obj.y
 local w=obj.w  local h=obj.h

 local x1=0	 local y1=0
 local x2=0  local y2=0

 if aim=="left" then
   x1=x-1  y1=y
   x2=x    y2=y+h-1

 elseif aim=="right" then
   x1=x+w-1    y1=y
   x2=x+w  y2=y+h-1

 elseif aim=="up" then
   x1=x+2    y1=y-1
   x2=x+w-3  y2=y

 elseif aim=="down" then
   x1=x+2      y1=y+h
   x2=x+w-3    y2=y+h
 elseif aim=="any" then
  if self(obj,"left",flag)
  		 or
     self(obj,"right",flag)
     or
 				self(obj,"up",flag)
 			 or
					self(obj,"down",flag)
				 then
					return true
		else
			return false
		end
 end

 --pixels to tiles
 x1/=8    y1/=8
 x2/=8    y2/=8


	collision_point = {}
 if fget(mget(x1,y1), flag) then
 	collision_point = {x1*8,y1*8}
 elseif fget(mget(x1,y2), flag) then
  collision_point = {x1*8,y2*8}
 elseif fget(mget(x2,y1), flag) then
  collision_point = {x2*8,y1*8}
 elseif fget(mget(x2,y2), flag) then
  collision_point = {x2*8,y2*8}
 else
   return false
 end
 -- flag logic here
 --todo: figure out why mset doesn't work
 if flag==5 then
  mset(collision_point,85)
 end
 if flag==6 then
  save_game()
 elseif abs(player.x-player.saved_x)+abs(player.y-player.saved_y)
        > 8 then
  ready_to_save = true
 end
 return true

end

function save_game()
 if ready_to_save then
	 cstore(0x2000, 0x2000, 0x1000, 'save_file.p8')
		player.saved_x=player.x
		player.saved_y=player.y
		saved = true			
		ready_to_save = false
	end
end
-->8
--player

function player_update()
  if player.dead then
   handle_player_death()
  end
  --physics
  player.dy+=gravity
  player.dx*=friction

  --controls
  if btn(⬅️) then
    player.dx-=player.acc
    player.running=true
    player.flp=true
  end
  if btn(➡️) then
    player.dx+=player.acc
    player.running=true
    player.flp=false
  end

  --slide
  if player.running
  and not btn(⬅️)
  and not btn(➡️)
  and not player.falling
  and not player.jumping then
    player.running=false
    player.sliding=true
  end

  --jump
  if btnp(❎)
  and player.landed then
    player.dy-=player.boost
    player.landed=false
  end

  --check collision up and down
  if player.dy>0 then
    player.falling=true
    player.landed=false
    player.jumping=false

    player.dy=limit_speed(player.dy,player.max_dy)

    if collide_map(player,"down",0) then
      player.landed=true
      player.falling=false
      player.dy=0
      player.y-=((player.y+player.h+1)%8)-1
    end
  elseif player.dy<0 then
    player.jumping=true
    if collide_map(player,"up",3) then
      player.dy=0
    end
  end

  --check collision left and right
  if player.dx<0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"left",2) then
      player.dx=0
    end
  elseif player.dx>0 then

    player.dx=limit_speed(player.dx,player.max_dx)

    if collide_map(player,"right",1) then
      player.dx=0
    end
  end
  -- damage collision
  if collide_map(player,"any",4,collide_map) then
   player.dead=true
  end
  --check for flags 5,6
  collide_map(player,"any",5,collide_map)
  collide_map(player,"any",6,collide_map)
  --stop sliding
  if player.sliding then
    if abs(player.dx)<.2
    or player.running then
      player.dx=0
      player.sliding=false
    end
  end

  player.x+=player.dx
  player.y+=player.dy

  --limit player to map
  if player.x<map_start then
    player.x=map_start
  end
  if player.x>map_end-player.w then
    player.x=map_end-player.w
  end
end

function player_animate()
		if player.dead then
		 --player.sp = 45
	 	--return
		end

  if player.jumping then
    player.sp=0
  elseif player.falling then
    player.sp=0
  elseif player.sliding then
    player.sp=1
  elseif player.running then
    if time()-player.anim>.1 then
      player.anim=time()
					 if player.sp ==16 then
					  player.sp = 17
					 elseif player.sp == 17 then
						 player.sp = 16
						else
						 player.sp=16
						end
    end
  else --player idle
    player.sp=0
    if time()-player.anim>.3 then
     --[[
      player.anim=time()
      player.sp+=1
      if player.sp>2 then
        player.sp=1
      end
      ]]--
    end
  end
end

function limit_speed(num,maximum)
  return mid(-maximum,num,maximum)
end

function handle_player_death()
 player.dead = false
 player.y = player.saved_y
 if not saved then
  reload(0x2000, 0x2000, 0x1000,".")
  return
 else
	 reload(0x2000, 0x2000, 0x1000,'save_file')		 player.x = player.saved_x
	 
		
	end
end

__gfx__
00111100000000000011110000000000001111000000000000000000000000000000000000111100000111100000000000111100001111000011110000111100
00144400001111000044440000111100001111000011110000006000000000000011110000444400000144400000000000444400004444000044440000444400
00414100001444000014410000444400004444000011110000066600000000000044440000144100000414100000000000414100004141000014410000144100
00444400004141000044440000144100004444000044440000067600000060000014410000444400000444406666660000445550004456660544440006644400
002888000024440002888820024444200288882002444420000676000006660000444400028c8820000222cc7777766000222800002555500288882055558820
002888000028880002888820028888200288882002888820000676000006760002888820022c8820000888806666660000888800008225500088882005588820
0021110000288800021111200288882002111120028888200006760000067600002c882000676120000111100000000000111100001111000011112000111120
0010010000100100001001000010010000100100001001000011110000067600001c112000676100000000100000000000100100001001000010010000100100
00111100001111000011110000111100001111000011110000111100001111000067610000676000001111000000000000111100001111000011110000111100
00444400004444000044440000444400001111000011110000444400001111000067600000676000001444000000000000444550004444000544440000444400
00414100004141000014410000144100004444000044440000444400004444000067600000676000004141000000000000415100004156660514410006644100
00444400004444000044440000444400004444000044440002888820004444000067600000666000004444666666000000442400004555500244440055554400
002888000228880002888820028888200288882002888820028888000288882000676000000600000022cc777776600000228800002225500288882005588820
00228800028888200288822002288820008888200288880002111100028888200066600000000000008888666666000000888800008888000088882000888820
00111100001111000011110000111100001111000011110000100000021111000006000000000000001111000000000000111100001111000011112000111120
00000100001000000010000000000100001000000000010000000000001001000000000000000000001001000000000000100100001001000010010000100100
0011110000111100166666611666606166666666666600000000666666666666cc222222222222cc111111111111111110111100000000000022220000000000
00111100001111006dddddd66dddd0d666666666666600000000666666666666c20000022000002c111111111111111101888811000000000211112000222200
00444400004444006dddddd66ddd0dd6666666666666000000006666114411442000000220000002111111111111111111188110000000000281812002111120
00444450004444506d00ddd66dd0ddd6666666666666000000006666114411442000000220000002111111111111111101888811000030000211112002818120
02888820028888256ddd0dd66dddddd6666666666666000000006666514411442000000220000002111111111111111111111110003333300022220002111120
02888800028888506dddddd66dddddd6666666666666000000006666154411442000000220010111177177777771777700811801033838330022250000222200
02111100021111006dddddd66dddddd6666666666666000000006666114411442000002aa2001002667166116671661100011000033333330222222002222520
0010010000100100166666611666666166666666666600000000666611441144222222aaaa222222666166166661666600100100003333302222222222222222
0011110000111100777777777777777766666666666600000000666666666666222222aaaa222222111111111111111110111101000000000002222002222000
00111150001111006666666766666667666666666661000000001666666666662000002aa2000002177777771717777701888810000000000021111221111200
00444450004444506666665756666667114411441141000000001411441001442000000220000002166116671661116711188111000030000028181228181200
00444420004444256665666565566667114411441141000000001411410000142000100220000002166666661666166601888810003333300021111221111200
02888820028888506656666766656667114411551141000000001411410000142001000220000002111111111111111110811801033838330002225002222000
02888800028888006666666766666667114415441141000000001411400000042001000220000002777777177777771700011000033333330002225055222000
0211110002111100666666676666665711441144114100000000141110000001c200000220000021666167166666671600100100033333330222222002222220
0010010000100100666666676666665711441144114000000000041110000001cc222222222222cc661666166666661600000000003333302222222222222222
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000111111001111110000000000000000000000000000000000000000000000000
110000011000000000000000000000000c0000c00002200000000001110000001969969119699691000000000000000000000000000000000000000000000000
001001111110011106660aa000660aa000cc0c0000288200000000155511000014d44d4114d44d41000000000000000000000000000000000000000000000000
10011888888110000000099a0000099a0ccccccc002882000000015551551000111aa11111188111000000000000000000000000000000000000000000000000
011111888811111100660aa006600aa0c000c0c000022000000015551555510014d99d4114d88d41000000000000000000000000000000000000000000000000
00111118811111000000000000000000000c000000000000000013355555510014d44d4114d44d41000000000000000000000000000000000000000000000000
11111118811111100000000000000000000000000000000000013355555551001111111111111111000000000000000000000000000000000000000000000000
00111188881111010600000006000000000000000000000000015555515531000111111001111110000000000000000000000000000000000000000000000000
0101188888811001006000000060000000c000000009009000015555153355101969969119699691000000000000000000000000000000000000000000000000
10000111111001006000000060060000000c0c000009909000151535515555101464464114644641000000000000000000000000000000000000000000000000
00000011110000100609a0000009a000c0c0ccc0090989890155153351155511111aa11111188111000000000000000000000000000000000000000000000000
0000011111100010000a9a00000a9a000c0cc0cc0999888901551155555553311111111111111111000000000000000000000000000000000000000000000000
00000181181000000000aa000000aa00000c00c009898899135555155555335114d99d4114d88d41000000000000000000000000000000000000000000000000
000000111100000000000000000000000000000009988890333355555553355314d44d4114d44d41000000000000000000000000000000000000000000000000
00000010010000000000000000000000000000000099990033333333333333331111111111111111000000000000000000000000000000000000000000000000
__gff__
000000000000001f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007070000000000000000004000002020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003a003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000450000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000005c5c5c5c5c00003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000005c5c005c5c003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000003b3b00003b003a3a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000004b4b4b3b3b3b3b3b3b003b00003a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b00003a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000003a3a3a3a3a3a003b003a3a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
450000480049000000070000003b3a3a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3a3a3a3a3a3a3a3a3a3a3a3a3a3b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000003b003a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
