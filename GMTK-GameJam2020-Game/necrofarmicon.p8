pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--scene control variable
--current acceptable values of scene:
--title
--game
--kill
--shop

function _init()
--game loops
objects = {}
plants = {}
enemies = {}
items = {}
runes={}
explosions={}
bullets={}

enemy_count =0
plant_grow_time=1--15 --seconds
plant_death_time=5--seconds
delta_time = 1/60 --time since last frame
--note that delta_time is 1/30
--unless _update60, then 1/60
corr_seed_pos={x=15*8,y=15*8}
-- the position in pixels of the
-- corruption seed on the map
corruption_range=2--tiles
corruption_timer=0
random_corruption_timer=0
time_till_next_corruption = 20

boundary_x =256
boundary_y =256

 --test code
 --mset(corr_seed_pos.x/8,corr_seed_pos.y/8,132)
 scene="title"
 player.hp=10
 --create_enemy(75,55,"pumpkin",player)
 for b in all(enemies) do
  b:init()
 end
 -- ui layer
 ui_layer = make_ui()
 --title screen globals
 title = {
  str="start",
  x=54,
  y=83,
  c=6,
  timer=0,
  t=0,
  f=1,
  s=3,
  sp={6,7}
 }
 begin=false
  --end screen globals
 try_again=false
 exploded=false
 endscreen={
  timer=0,
 }
end

function _update60()
 if scene == "title" then
  if begin==false then
   title.y = title.y+0.1*sin(title.timer)
   title.timer+=0.0125
   if (btnp(4)) then
    begin=true
    title.timer=0
   end
  else
   title.y=83
   title.t=(title.t+1)%title.s
   if (title.t==0) title.f=title.f%#title.sp+1
   title.timer+=1
   if (title.timer > 20) scene="game"
  end
 end
 if scene == "game" then
  player:update()
  for b in all(plants) do
   b:update()
  end
  for b in all(runes) do
   b:update()
  end
  if scene == "game" then
   player:update()
   cam_offset=set_camera_offset()
   ui_layer:update()
   for b in all(plants) do
    b:update()
   end
   enemy_count =0
   for b in all(enemies) do
    b:update()
    enemy_count +=1
   end
   for b in all(items) do
    b:update()
   end
   for b in all(explosions) do
    b:update()
   end
   for b in all(bullets) do
    b:update()
   end
  end
 end
 corrupt_dirt()
 if scene=="over" then
  player.sprite = 192
  endscreen.timer+=1
  if try_again and (btnp(5)) then
   try_again=false
   exploded=false
   _init()
  end
  if (endscreen.timer > 60) exploded=true
  if (endscreen.timer > 240) try_again=true
 end

end

function _draw()
 if scene == "title" then
  cls()
  -- print("harvest",8,8,7)
  -- print("v0.2 placeholder title screen",8,16,7)
  -- print("press z to start",40,60,7)
  sspr(64,96,32,32,0,0,128,128)
  print(title.str,title.x,title.y,title.sp[title.f])
  --?sin(title.timer),64,40,7
 end
 if scene=="game" then
  cls()
  map(0,0)
  camera(cam_offset.x,cam_offset.y)
  for b in all(plants) do
   b:draw()
  end
  for b in all(runes) do
   b:draw()
  end
  for b in all(items) do
   b:draw()
  end
  for b in all(enemies) do
   b:draw()
  end
  for b in all(explosions) do
   b:draw()
  end
  for b in all(bullets) do
   b:draw()
  end
  player:draw()
  ui_layer:draw()
  --?player.shotgun_cooldown,player.x,player.y-8,0
 end
 if scene == "over" then
  if exploded then
   if try_again then
    cls()
    print("❎ try again?",64-18,60,7)
   else
    cls()
    camera(0,0)
    sspr(96,96,32,32,0,0,128,128)
   end
  else
   for b in all(explosions) do
    b:draw()
   end
  end
 end
end

function corrupt_dirt()
 corruption_timer+=delta_time
 --seconds till next corruption
 if corruption_timer>time_till_next_corruption then
  local x = corr_seed_pos.x/8
  local y = corr_seed_pos.y/8
  local offset_x=-corruption_range
  local offset_y=-corruption_range
  while offset_x < corruption_range+1 do
   while offset_y < corruption_range+1 do
    if mget(x+offset_x,y+offset_y) == 70 then
     mset(x+offset_x,y+offset_y,76)
    elseif mget(x+offset_x,y+offset_y) == 71 then
     mset(x+offset_x,y+offset_y,77)
    end
	   offset_y+=1
	  end

	  offset_y=-corruption_range
	  offset_x+=1
  end
  corruption_timer=0
  corruption_range+=1

  randomly_corrupt_dirt()

 end
end

function randomly_corrupt_dirt()
  local x = 0
  local y = 0
  while x < 31 do
   while y < 31 do
    if rnd(40) >38  then
	    if mget(x,y) == 70 then
	     mset(x,y,76)
	    elseif mget(x,y) == 71 then
	     mset(x,y,77)
	    end
	   end
    y+=1
   end
    y=0
    x+=1
  end
end
--utility functions start here

--returns distance between 2 coords
function distance(x1, y1, x2, y2)
  return sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

--takes a copy of an object
--and a table
--returns the original's index
--in the table
function get_index(table,value)
   local inverted_table={}
   for k,v in pairs(table) do
     inverted_table[v]=k
   end
   return inverted_table[value]
end

--end utility functions

function make_rune(xin,yin,plant_in)
 rune = {
  x=xin,
  y=yin,
  plant=plant_in,
  sprites = {164,165,166,167,180,181,182,183},
  sprite=164,
  sprite_change_timer=0,
  update=function(self)
   if self.sprite_change_timer < 1 then
    self.sprite_change_timer+=delta_time
   else
    self.sprite = self.sprites[flr(rnd(7))+1]
    self.sprite_change_timer=0
   end
   if self.plant == nil then
    del(runes,self)
   end
  end,
  draw=function(self)
   spr(self.sprite,self.x,self.y)
  end
 }
 add(runes,rune)
 return rune
end

--explosion code
function generate_explosion_particles(xin,yin)
 explosion = {
 x=63,
 y=63,
 speed = .5,
 dx=(rnd(2)-1),
 dy=(rnd(2)-1),
 lifespan =rnd(40)-5,
 draw=function(self)
		pset(self.x,self.y,11)
	end,
	update=function(self)
	 self.x+=self.dx*self.speed
	 self.y+=self.dy*self.speed
	 self.lifespan-=1
	 if self.lifespan<0 then
	  del(explosions,self)
	 end
	end
 }
 explosion.x = xin
 explosion.y = yin
 add(explosions,explosion)
end

function create_explosion(xin,yin)
 particle_count = 0
	while particle_count<100 do
		  generate_explosion_particles(xin,yin)
		  particle_count += 1
	end
end
--bullet code
function make_shot(xin,yin,xspd,yspd,dir)
 make_bullet(xin,yin,xspd,yspd)
 if dir == "right" or dir == "left" then
  make_bullet(xin,yin,xspd,yspd+0.5)
  make_bullet(xin,yin,xspd,yspd-0.5)
 end
 if dir == "up" or dir == "down" then
  make_bullet(xin,yin,xspd+0.5,yspd)
  make_bullet(xin,yin,xspd-0.5,yspd)
 end
end

function make_bullet(xin,yin,xspd,yspd)
 local b = {}
 b.x=xin
 b.y=yin
 b.start={x=xin,y=yin}
 b.xspd=xspd
 b.yspd=yspd
 b.rnge=30
 b.enemy=nil

 function b:draw()
  circfill(self.x,self.y,1,9)
 end

 function b:update()
  self.x+=self.xspd
  self.y+=self.yspd
  self.enemy = hitbox_collision(self.x,self.y,8,8)
  if self.enemy != nil then
   create_explosion(self.enemy.x,self.enemy.y)
   del(enemies,self.enemy)
   del(bullets,self)
  end
  if distance(self.x,self.y,self.start.x,self.start.y)>self.rnge then
   del(bullets,self)
  end
 end
 add(bullets,b)
end

-->8
--player
--animations
function make_anim(s,sp)
 local anim = {}
 anim.t=0
 anim.f=1
 anim.s=s
 anim.sp=sp
 anim.done=false

 function anim:anim_update()
  self.done = false
  self.t=(self.t+1)%self.s
  if (self.t==0) self.f=self.f%#self.sp+1
  if self.f==#self.sp and self.t==self.s-1 then
   self.done = true
  end
  return self.sp[self.f]
 end

 return anim
end

player_idle_lr = make_anim(60,{4,5})
player_idle_up = make_anim(60,{2,3})
player_idle_dn = make_anim(60,{0,1})
player_run_lr = make_anim(12,{20,21})
player_run_up = make_anim(12,{18,19})
player_run_dn = make_anim(12,{16,17})
player_swing_lr = make_anim(10,{14,30,30})
player_swing_up = make_anim(10,{29,28,28})
player_swing_dn = make_anim(10,{10,11,11})
swing_smear_lr = make_anim(10,{196,15,196})
swing_smear_up = make_anim(10,{196,12,196})
swing_smear_dn = make_anim(10,{196,26,196})
player_water_lr = make_anim(10,{34,50})
player_water_up = make_anim(10,{48,49})
player_water_dn = make_anim(10,{32,33})
player_shoot_lr = make_anim(15,{46,46,47})
player_shoot_up = make_anim(15,{60,60,61})
player_shoot_dn = make_anim(15,{44,44,45})
player_dash_lr = make_anim(2,{40,41})
player_dash_up = make_anim(2,{54,55})
player_dash_dn = make_anim(2,{38,39})

player = {
x=64,
y=64,
w=8,
h=8,
fx=false,
fy=false,
width=1,
hp=1,
speed=0.6,
sprite=0,
direction="right",
item="shotgun",
seed="lettuce",
harvested={lettuce=0,carrot=0,tomato=0,corn=0,melon=0,pumpkin=0,lemon=0},
running=false,
dashing=false,
dash_tick=0,
dash_cooldown=0,
register={0,0,0,0},
cur_moveanim=player_idle_lr,
attack={sprite=196,anim=nil,x=nil,y=nil,w=1,h=1},
anim_locked=false,
pail_left_flag=false,
shotgun_cooldown=0,
is_dead=false,
dead_timer=0,
update=function(self)
 if not(self.is_dead) then
  self.shotgun_cooldown-=1
  self.shotgun_cooldown=max(0,self.shotgun_cooldown)
  if self.cur_moveanim.done then
   self.anim_locked = false
   self.attack.anim = nil
   self.attack.w=1
   self.attack.h=1
   self.width=1
   if (self.pail_left_flag) then
    self.pail_left_flag=false
   end
   self:idle_check()
  end
  if btn(❎) then
   if (self.dash_cooldown<=0) then
    self.dashing=true
    self:plant_seed()
   end
  end
  if btn(🅾️) then
   self:use_item()
   if self.item=="sword" then
    if self.direction=="right" then
     self.cur_moveanim = player_swing_lr
     self.attack.anim = swing_smear_lr
     self.attack.x=self.x+8
     self.attack.y=self.y-4
     self.attack.h=2
     self.anim_locked=true
    end
    if self.direction=="left" then
     self.cur_moveanim = player_swing_lr
     self.attack.anim=swing_smear_lr
     self.attack.x=self.x-8
     self.attack.y=self.y-4
     self.attack.h = 2
     self.anim_locked=true
    end
    if self.direction=="up" then
     self.cur_moveanim = player_swing_up
     self.attack.anim=swing_smear_up
     self.attack.x=self.x-4
     self.attack.y=self.y-8
     self.attack.w = 2
     self.anim_locked=true
    end
    if self.direction=="down" then
      self.cur_moveanim = player_swing_dn
      self.attack.anim=swing_smear_dn
      self.attack.x=self.x-4
      self.attack.y=self.y+8
      self.attack.w = 2
      self.width=1
      self.anim_locked=true
    end
   end
   if self.item=="shotgun" then
    if self.direction=="right" or self.direction=="left" then
     self.cur_moveanim = player_shoot_lr
     self.anim_locked=true
    end
    if self.direction=="up" then
     self.cur_moveanim = player_shoot_up
     self.anim_locked=true
    end
    if self.direction=="down" then
     self.cur_moveanim = player_shoot_dn
     self.anim_locked=true
    end
   end
   if self.item=="watering_pail" then
    if self.direction=="right" then
     self.cur_moveanim = player_water_lr
     self.width=2
     self.anim_locked=true
    end
    if self.direction=="left" then
     self.cur_moveanim = player_water_lr
     self.width=2
     self.pail_left_flag=true
     self.anim_locked=true
    end
    if self.direction=="up" then
     self.cur_moveanim = player_water_up
     self.anim_locked=true
    end
    if self.direction=="down" then
     self.cur_moveanim = player_water_dn
     self.anim_locked=true
    end
   end
  end
  --collision logic here
  for b in all(enemies) do
   if collision(self,b) then
    --do collision stuff
   end
  end
  self:handle_movement()
  self.sprite=self.cur_moveanim:anim_update()
  if (self.attack.anim~=nil) self.attack.sprite=self.attack.anim:anim_update()
  self:check_die()
 else
  self.dead_timer+=1
  if self.dead_timer > 120 then
   self.dead_timer=0
   self.is_dead = false
   scene="over"
  end
 end
end,

draw=function(self)
 if self.pail_left_flag then
  spr(self.sprite,self.x-8,self.y,self.width,1,self.fx,self.fy)
 else
  spr(self.sprite,self.x,self.y,self.width,1,self.fx,self.fy)
 end
 if self.attack.anim~=nil then
  spr(self.attack.sprite,self.attack.x,self.attack.y,self.attack.w,self.attack.h,self.fx,self.fy)
 end
end,

handle_movement=function(self)
  --move keys
 self.running=false
 if not(self.dashing) then
  if btn(➡️) then
 	 if self.x < boundary_x-8 then
 		  self.x+=self.speed
 		  self.direction="right"
 		  self.running=true
    if (self.anim_locked==false) then
     self.cur_moveanim=player_run_lr
    end
    self.fx=false
   end
  end
  if btn(⬅️) then
   if self.x > 0 then
 	  self.x-=self.speed
 	  self.direction="left"
 	  self.running=true
    if (self.anim_locked==false) then
     self.cur_moveanim=player_run_lr
    end
    self.fx = true
   end
  end
  if btn(⬆️) then
   if self.y > 4 then
 	  self.y-=self.speed
 	  self.direction="up"
 	  self.running=true
    if (self.anim_locked==false) then
     self.cur_moveanim=player_run_up
    end
   end
  end
  if btn(⬇️) then
 	 if self.y < boundary_y-8 then
 	  self.y+=self.speed
 	  self.direction="down"
 	  self.running=true
    if (self.anim_locked==false) then
     self.cur_moveanim=player_run_dn
    end
   end
  end
  self:idle_check()
  self.dash_cooldown-=1
 else
  self.speed+=1
  self.dash_tick+=1
  if self.direction=="right" then
   self.x+=self.speed
   self.cur_moveanim=player_dash_lr
  end
  if self.direction=="left" then
   self.x-=self.speed
   self.cur_moveanim=player_dash_lr
  end
  if self.direction=="up" then
   self.y-=self.speed
   self.cur_moveanim=player_dash_up
  end
  if self.direction=="down" then
   self.y+=self.speed
   self.cur_moveanim=player_dash_dn
  end
  if self.dash_tick>3 then
   self.speed=0.6
   self.dash_tick=0
   self.dashing=false
   self.dash_cooldown=90
  end
 end
end,

idle_check=function(self)
 if self.direction=="down" and self.running~=true and self.dashing~=true then
  if (self.anim_locked==false) self.cur_moveanim = player_idle_dn
 end
 if self.direction=="up" and self.running~=true and self.dashing~=true then
  if (self.anim_locked==false) self.cur_moveanim = player_idle_up
 end
 if self.direction=="right" and self.running~=true and self.dashing~=true then
  if (self.anim_locked==false) self.cur_moveanim = player_idle_lr
 end
 if self.direction=="left" and self.running~=true and self.dashing~=true then
  if (self.anim_locked==false) self.cur_moveanim = player_idle_lr
 end
end,
use_item=function(self)
 if self.item=="sword" then
  self:swing_sword()
 elseif self.item=="watering_pail" then
  self:water_ground()
 elseif self.item == "hoe" then
  self:till_ground()
 elseif self.item == "pickaxe" then
  self:mine_rock()
 elseif self.item=="shotgun" then
  self:fire()
 end

end,

fire=function(self)
 if self.shotgun_cooldown == 0 then
  if self.direction == "right" then
   make_shot(self.x+8,self.y+4,2,0,self.direction)
   self.x-=4
  end
  if self.direction == "left" then
   make_shot(self.x,self.y+4,-2,0,self.direction)
   self.x+=4
  end
  if self.direction == "up" then
   make_shot(self.x,self.y+4,0,-2,self.direction)
   self.y+=4
  end
  if self.direction == "down" then
   make_shot(self.x,self.y+4,0,2,self.direction)
   self.y-=4
  end
  self.shotgun_cooldown = 45
 end
end,

swing_sword=function(self)
 local enemy
 if self.direction == "right" then
  enemy = hitbox_collision(self.x+8,self.y,8,8)
 elseif self.direction == "left" then
  enemy = hitbox_collision(self.x-8,self.y,8,8)
 elseif self.direction == "left" then
  enemy = hitbox_collision(self.x,self.y+8,8,8)
 elseif self.direction == "left" then
  enemy = hitbox_collision(self.x,self.y-8,8,8)
 end
 if enemy != nil then
  del(enemies,enemy)
  create_explosion(enemy.x,enemy.y)
 end
end,


plant_seed=function(self)
 local offset_x,offset_y = get_player_offset()

 if not(check_for_plant(self.x+offset_x,self.y+offset_y)) then
   if mget((self.x+offset_x)/8,(self.y+offset_y)/8)
    ==70 --if dry soil
   or mget((self.x+offset_x)/8,(self.y+offset_y)/8)
    ==71 --if wet soil
   or mget((self.x+offset_x)/8,(self.y+offset_y)/8)
    ==76 --if dry corrupted soil
   or mget((self.x+offset_x)/8,(self.y+offset_y)/8)
    ==77 --if wet corrupted soil
    then
   create_plant(self.x+offset_x,self.y+offset_y,self.seed)
  end
 end
end,

water_ground=function(self)

 local offset_x,offset_y = get_player_offset()

 if mget((self.x+offset_x)/8,(self.y+offset_y)/8,70)
  ==71  --if dry soil
  then --set to wet soil
 mset((self.x+offset_x)/8,(self.y+offset_y)/8,70)
 elseif mget((self.x+offset_x)/8,(self.y+offset_y)/8,70)
  ==77
 then
  mset((self.x+offset_x)/8,(self.y+offset_y)/8,76)
 end
end,

till_ground=function(self)
 local offset_x,offset_y = get_player_offset()
 local plant = get_plant(self.x+offset_x,self.y+offset_y)
 if plant != nil then
  if plant.dead then
   del(plants,plant)
  end
 end
 if mget((self.x+offset_x)/8,(self.y+offset_y)/8)
   ==86 --if patchy grass
   or mget((self.x+offset_x)/8,(self.y+offset_y)/8)
   ==87 --if plaiin grass
  then --set to dry soil
   mset((self.x+offset_x)/8,(self.y+offset_y)/8,71)
 end
end,

mine_rock=function(self)
 local offset_x,offset_y = get_player_offset()
 if mget((self.x+offset_x)/8,(self.y+offset_y)/8,70)
  ==72  --rock
  then --set to grass
 mset((self.x+offset_x)/8,(self.y+offset_y)/8,87)
 end
end,

check_die=function(self)
 if self.hp <= 0 then
  self.sprite=196
  create_explosion(self.x,self.y)
  self.is_dead=true
 end
end
}

function get_player_offset()
  local offset_x=0
 local offset_y=0
 if player.direction=="up" then
  offset_y=-player.h
 elseif player.direction=="down" then
  offset_y=player.h
 elseif player.direction=="right" then
  offset_x=player.w
 elseif player.direction=="left" then
  offset_x=-player.w
 end
 return offset_x,offset_y
end

function set_camera_offset()
 local offset={}
 offset.x = nil
 offset.y = nil
 offset.basex=nil
 offset.basey=nil
 offset.offx=64
 offset.offy=64
 if (player.x<64 or player.x>128+64) then
   if (player.x<64) offset.basex = 64
   if (player.x>128+64) offset.basex = 128+64
 else
  offset.basex=player.x
 end
 if (player.y<56 or player.y>128+64+16) then
  if (player.y<56) offset.basey = 56
  if (player.y>128+64+16) offset.basey = 128+64+16
 else
  offset.basey = player.y
 end
 offset.x=offset.basex-offset.offx
 offset.y=offset.basey-offset.offy
 return {x=offset.x,y=offset.y}
end


-->8
--plants
function check_for_plant(xin,yin)
--returns true if a plant is present at the grid-corrected position supplied
--in the arguments
--returns false if no plant yet present
 for p in all(plants) do
  if (p.x == xin-xin%8 and p.y == yin-yin%8) return true
 end
 return false
end

function get_plant(xin,yin)
--returns index of a plant
--at the given coords in
--the plants table
 for p in all(plants) do
  if (p.x == xin-xin%8 and p.y == yin-yin%8) then

   return p
  end
 end
 return nil
end

function create_plant(xin,yin,class_in)
local plant={
 x=xin-xin%8, --aligns seeds to 8x8 grid
 y=yin-yin%8, --aligns seeds to 8x8 grid
 class=class_in,
 h=8,
 w=8,
 sprite=74,--seed sprite
 level=0, --0:seed
 									--1:sprout
 									--2:fruit/mature plant
 growth_timer=0,
 death_timer=0,
 corrupted=false,
 corruption_timer=0,
 rune=nil,
update=function(self)
 if not self.dead then
  if self.level < 2 then
   self:handle_growth()
  else
   self:handle_harvest()
   self:handle_corruption()
  end
 end
end,

draw = function(self)
 if self.level == 1 then
  self.sprite=75 --sprout sprite
 elseif self.level == 2 then
	 if self.class == "tomato" then
	  self.sprite=78
	 elseif self.class == "corn" then
	  self.sprite=94
	 elseif self.class == "carrot" then
	  self.sprite=97
	 elseif self.class == "pumpkin" then
	  self.sprite=95
	 elseif self.class == "melon" then
	  self.sprite=79
	 elseif self.class == "lettuce" then
	  self.sprite=96
	 elseif self.class == "lemon" then
	  self.sprite=112
	 end
	end
 spr(self.sprite,self.x,self.y)
end,
handle_growth=function(self)
 --if on wet soil
 if mget(self.x/8,self.y/8)
  == 70 or mget(self.x/8,self.y/8)
  == 76 then --corrupted wet soil
	 self.growth_timer+=delta_time
	 if self.growth_timer >= plant_grow_time then
	  self.level += 1
	  self.growth_timer=0
	 end
	else --if on dry soil
		 self.death_timer+=delta_time
	 if self.death_timer >= plant_death_time then

	  --todo: allow dying plants
	  --						to recover with time penalty
	  if not self.dying then
		  self.dying = true
		  self.death_timer=0
		  self.sprite=90
		  return
	  else
	   self.dying=false
	   self.dead=true
	   self.sprite=91
	  end
	 end
	end
end,

handle_harvest=function(self)
	if collision(player,self) then
  player.harvested[self.class]+=1
  del(plants,self)
 end
end,

handle_corruption=function(self)
 if mget(self.x/8,self.y/8)
  == 76 or mget(self.x/8,self.y/8)
  == 77then --corrupted dirt
   if not self.corrupted then
    self.corrupted=true
    --self.rune = make_rune(self.x,self.y,self)
   end
 end
 if self.corrupted then
  if corruption_timer < 10 then
   corruption_timer+=delta_time
  else
   create_enemy(self.x,self.y,self.class)
   del(plants,self)
  end
 end
end
}

add(plants,plant)
end
-->8
--enemies

melon_idle = make_anim(60,{108,109})
tomato_idle = make_anim(60,{102,103})
carrot_idle = make_anim(60,{104,104})
lettuce_idle = make_anim(60,{106,107})
lettuce_attack = make_anim(10,{122,123})
corn_idle = make_anim(60,{110,111})
pumpkin_idle = make_anim(60,{130,131})
pumpkin_attack = make_anim(30,{120,121})
lemon_explode = make_anim(60,{132,133,148,149})


function create_enemy(xin,yin,class_in,target_in)
enemy = {
x=xin,
y=yin,
class=class_in,
target=target_in,
sprite=13,
w=8,
h=8,
dx=0,
dy=0,
hp=10,
speed=.4,
dead=false,
cur_moveanim=carrot_idle,
state="idle",
attack_cooldown_timer = 0,
init=function(self)
 if self.class == "tomato" then
  self.sprite=76
 elseif self.class == "corn" then
  self.sprite=128
 elseif self.class == "carrot" then
  self.sprite=130
 elseif self.class == "pumpkin" then
  self.sprite=104
 elseif self.class == "melon" then
  self.sprite=108
 elseif self.class == "lettuce" then
  self.sprite=106
 elseif self.class == "lemon" then
  self.sprite=132
 end
end,
update=function(self)
 if self.class == "pumpkin" then
  if self.state == "idle" then
   self.cur_moveanim = pumpkin_idle
  end
  if self.state == "idle" then
   if distance(player.x+4,player.y+4,self.x+4,self.y+4)
    >= 9 then
   self:move_toward_target()

   else
    self.state ="attacking"
    self.cur_moveanim = pumpkin_attack
   end
  elseif self.state == "attacking" then
   if self.attack_cooldown_timer < 1 then
    self.attack_cooldown_timer+=delta_time
   else
    self.attack_cooldown_timer=0
    if distance(player.x+4,player.y+4,self.x+4,self.y+4)
    <= 9 then
     player.hp-=1
    end
    self.cur_moveanim = pumpkin_idle
    self.state = "idle"
   end
  end
 elseif self.class == "lettuce" then
  if self.state == "idle" then
   self.cur_moveanim = lettuce_idle
  end
  self:stab_outwards()
 elseif self.class == "tomato" then
  if self.state == "idle" then
   self.cur_moveanim = tomato_idle
  end
 elseif self.class == "corn" then
  if self.state == "idle" then
   self.cur_moveanim = corn_idle
  end
 elseif self.class == "carrot" then
  if self.state == "idle" then
   self.cur_moveanim = carrot_idle
  end
 elseif self.class == "melon" then
  if self.state == "idle" then
   self.cur_moveanim = melon_idle
  end
 elseif self.class == "lemon" then
  if self.state == "idle" then
   self.cur_moveanim = nil
  end
  -- lemon explode logic here
 end
 if self.cur_moveanim != nil then
  self.sprite=self.cur_moveanim:anim_update()
 end
end,
draw=function(self)

 spr(self.sprite,self.x,self.y)
end,
animate=function(self)
 --animation code
end,
move_toward_target=function(self)
 if self.target != nil then
 	angle=atan2(self.x-self.target.x-4,self.y-self.target.y-4)
  self.dx = -cos(angle)
  self.dy = -sin(angle)

	 self.x+=self.dx*self.speed
	 self.y+=self.dy*self.speed
 end
end,
stab_outwards=function(self)
 if self.state == "attacking" then
  self.cur_moveanim = lettuce_attack
  if self.attack_cooldown_timer < 1 then
   self.attack_cooldown_timer+=delta_time
  else
    if distance(player.x+4,player.y+4,self.x+4,self.y+4)
    <= 15 then
     player.hp-=1
    end
    self.state="idle"
    self.attack_cooldown_timer=0
  end
 end
 if distance(player.x+4,player.y+4,self.x+4,self.y+4)
 <= 15 then
  self.state = "attacking"
 end
end
}

add(enemies,enemy)
end
-->8
--collision

function collision(obj1,obj2)
  x1 = obj1.x
  y1 = obj1.y
  w1 = obj1.w
  h1 = obj1.h
  x2 = obj2.x
  y2 = obj2.y
  w2 = obj2.w
  h2 = obj2.h

  hit=false
  local xd=abs((x1+(w1/2))-(x2+(w2/2)))
  local xs=w1*0.5+w2*0.5
  local yd=abs((y1+(h1/2))-(y2+(h2/2)))
  local ys=h1/2+h2/2

  --test code

  --end test code
  if xd<xs and
     yd<ys then
    hit=true
  end

  return hit
end

function hitbox_collision(px,py,hitbox_w,hitbox_h)
 hitbox = {
  x=px,
  y=py,
  h=hitbox_h,
  w=hitbox_w
 }
 local colour = 1
 for e in all(enemies) do
  if collision(hitbox,e) then
   --colour = 7
   return e
  end
 end
--rect(px,py,px+hitbox_w,py+hitbox_h,colour)
 return nil
end


-->8
--ui layer tab
function make_ui()
 local u = {}
 u.x = nil
 u.y = nil
 u.harvest = make_harvestUI()

 function u:update()
  self.x=cam_offset.x or nil
  self.y=cam_offset.y or nil
  self.harvest:update(self.x+127-116,self.y+120)
 end

 function u:draw()
  if u.x ~= nil then
   line(self.x+0,self.y+9,self.x+127,self.y+9,9) --black bars
   rectfill(self.x+0,self.y+0,self.x+127,self.y+8,0)
   rectfill(self.x+0,self.y+119,self.x+127,self.y+127,1)
   line(self.x+0,self.y+119,self.x+127,self.y+119,9)

   spr(68,self.x+106,self.y)  --gold
   print("999",self.x+114,self.y+1,10)

   self.harvest:draw() -- crop icons
   print(player.hp.."/10",self.x+9,self.y+1,8) --health
   spr(23,self.x,self.y)

   rect(self.x+1,self.y+12,self.x+12,self.y+23,9) -- current tool
   rectfill(self.x+2,self.y+13,self.x+11,self.y+22,0)
   if (player.item == "sword") spr(25,self.x+3,self.y+14)
   if (player.item == "watering_pail") spr(8,self.x+3,self.y+14)
   if (player.item == "shotgun") spr(24,self.x+3,self.y+14)
  end
 end
 return u
end

function make_harvestUI(x,y)
 local h = {}
 h.x=x or nil
 h.y=y or nil
 function h:update(x,y)
  self.x=x
  self.y=y
 end
 function h:draw()
  spr(96,self.x+0,self.y)
  print(player.harvested.lettuce,self.x+9,self.y+2,7)
  spr(97,self.x+16,self.y)
  print(player.harvested.carrot,self.x+25,self.y+2,7)
  spr(78,self.x+32,self.y)
  print(player.harvested.tomato,self.x+41,self.y+2,7)
  spr(94,self.x+48,self.y)
  print(player.harvested.corn,self.x+57,self.y+2,7)
  spr(95,self.x+64,self.y)
  print(player.harvested.pumpkin,self.x+72,self.y+2,7)
  spr(79,self.x+80,self.y)
  print(player.harvested.melon,self.x+89,self.y+2,7)
  spr(112,self.x+96,self.y)
  print(player.harvested.lemon,self.x+105,self.y+2,7)
 end
 return h
end

-- abandoned for now
function make_bar()
end
-->8
-- animations tab
--[[
function make_anim(s,sp)
 local anim = {}
 anim.t=0
 anim.f=1
 anim.s=s
 anim.sp=sp
 add(animations,anim)

 function anim:anim_update()
  self.t=(self.t+1)%self.s
  if (self.t==0) self.f=self.f%#self.sp+1
  return self.sp[self.f]
 end

 return anim
end
]]

__gfx__
00999900000000000099990000000000009999000000000000999900009999000000000000000000007000000000000000000777000000000000007000000000
001ff1000099990000999900009999000091f10000999900001ff10000999900000cc000000ccc00006999900099990000077666770000000099996000000000
00ffff00001ff10000f99f000099990000ffff000091f10000ffff0000f99f0000c6cc0000c666c00061ff10001ff10000776666667000000091f16000000000
0288882000ffff000288882000f99f000028880000ffff0000888820028888000c6c6dc00c6c5c6c006ffff000ffff00007666666667000000ffff6077700000
0f8888f0028888200288882002888820002f88000028880000f88820028888000c655cdc00cc5cc00ddd888200888820076666666767000000828ddd07777000
00cccc000f8888f000cccc000288882000cccc00002f880000ccccf00fcccc0000c55cc0000c5c00001888820028882007666667707770000088221000766700
00c00c0000cccc0000c00c0000cccc0000c00c0000cccc0000c00c0000c00c00000cc000000c5c00000ccccf001d0cf0006666770007700000cccc0000076670
00c00c0000c00c0000c00c0000c00c0000c00c0000c00c0000c00c0000c00c00000000000000c000000c00c000d60c0000066d000000700000c00c0000766670
0099990000999900009999000099990000999900009999000099990000000000000c0000000c000000070000007660000000d100000000700000000007766667
001ff100001ff10000999900009999000091f1000091f1000091f1000220c20000c5c00000c7c000000770007766660000099990009999600009999007666667
00ffff0000ffff0000f99f0000f99f0000ffff0000ffff0000ffff002c828cc000c5c00000c6c0000007770776666670000999900099996000091f1076666667
02888820028888200288882002888820022888f00028880000222f0028c8882000c5c00000c6c0000000767666666670000f99f000f99f60000ffff066666670
028888f00f88882002888820028888200f888820002f88000088880002c8820000c54c0000c6c000000076666666670000288880028888dd0008288d66666770
0fcccc0000ccccf000ccccf00fcccc0000cccc0000cccc0000cccc0000c8200000c5c0000cdddc00000007666666770000288880028888100008821d76667700
00c00c0000c00c0000c00c0000c00c000cc00c0000c0cc0000c00c000002000000c54c0000c1c000000000776667700000fcccc00fcccc00000ccccd07770000
00c0000000000c0000c0000000000c0000000c0000c0000000c00c0000000000000c4c00000c00000000000077700000000c00c000c00c00000c00c000000000
00999900009999000099990000000000444444444444444400999900009999000000000000000000000000000000000000999900000000000099990000000000
001ff100001ff1000091f100000000004444433443344444009999000099990000000000009999900000000000000000001ff100009999000091f10009999000
06ffff0006ffff0000ffff6000000000444333333333344400999900001ff1000099999900991f100dddd000000dd00000ffff00055ff10000ffff00091f5550
068888200688882000222606000000004433333333333344001ff10000ffff00009991f100fffff0000000000000000005588820044fff000055555505554000
5d5888205d58882000888655d000000044333333333333440f8888200f888820002222f800222f800000ddd000000dd004488820044888200448480004488000
5d5cccf05d5cccf000cccc550d000000433333333333333400888820008888200088888800888880000000000000000000ccccf00088882000cccc0008888000
01c00c0000c00c0000c00c0000100000433333333333333400c000f000c00cf004cc000c04cc00c000dddd000000dd0000c00c0000ccccf000c00c000cccc000
00c00c0001c00c0000c00c0000000000443333333333334400400000004000000000000400000040000000000000000000c00c0000c00c0000c00c000c00c000
009999000099990000999900000000004433333333333344009999000099990000000000000000000d00000000000000009999000000000000eeee0000eeee00
00999900009999000091f100000000004333333333333334009999000099990000000000000000000d000d00000000000099990000999900022111e0022111e0
00f99f6000f99f6000ffff60000000004333333333333334009999000099990000600000000000000d0d0d000d00000000f99f0000999950022c1c20022c1c20
02888860028888600022260600000000443333333333334400f99f0000f99f00060600000000d0000d0d0d000d000d000288885000f99f500221112002211120
028888650288886500888655d00000004433333333333344028888200288882000600600000d0d00000d0d00000d0d0002888840028888400022220000222200
0fcccc550fcccc5500cccc550d00000044433333333334440288880002888800000060600000d000000d0000000d00000fcccc000288880000f22200002222f0
00c00c1000c00c0000c00c000000000044444334433444440f000c000fc00c000000060000000000000000000000000000c00c000fcccc0000cccc0000cccc00
00c00c0000c00c1000c00c0000100000444444444444444400000400000004000000000000000000000000000000000000c00c0000c00c000222222002222220
4cc2c2c2ccc2ccc44cc2c2c2ccc2ccc4000000000000000044544444555155553333333344444444000000000000000045444c44515552550030000000000000
4c22c2c2c2c2c2c44c22c2c2c2c2c2c400000000002c2000454444545515551533b333334334433400000000000000004454c444551525550003000000000000
4cc2ccc2c2c2ccc44cc2ccc2c2c2ccc4000a0000020c0200444444545555551533b333b333333333000aa0000b0bb0b044444455555555110023b80000000000
42c2c2c2c2c2c22442c2c2c2c2c2c22400a9a0000ccccc00444444445555555533333b333333333300aaaa0000bbbb0044444544555551550233bb803288818b
4cc2c2c2ccc2c2244cc2c2c2ccc2c22400a9a000020c0200454444445155555533333b3333b33333000aa000000bb0004444444455555555022bbe803218888b
44444444444444444444444444444444000a0000002c20005454445415155515333333333b333333000000000000000044c4444c552555520288ee80332818bb
441111eeee1111444411111111111144000000000000000044444544555551554334433433333333000000000000000045c444445125555508888880032888b0
4411122111e11144441111eeee11114400000000000000004444444455555555444444443333333300000000000000004445444455515555008888000033bb00
4411122c1c2111444411122111e11144000000000000000033333333333333334433333333333344000000000000000044444454555555150000000000330000
44111221112111444411122c1c211144000000000000000033b33333333333334333b33333333334000000000000000044544444551555550009a00000933a00
441111222211114444111221112111440000000000c200003b33333333333333433b333b333b333400000000000000004544cc44515522550099aa000933bba0
4455555555555544445555555555554400c2000002cc20003b33333b33333333443b333b33b3334400033000000dd000444c444455525555309aaa0b0493b4a0
49999999999999944999999999999994022cc0000222c000333b33b3333333334433333333b333440033330000dddd004444444455555555039aaabb04949490
49444449944444944944444994444494002200000022000033b3333333333333433333b333333b34030330300d0dd0d04444454455555155039aaab005949490
49444449944444944944444994444494000000000000000033b333333333333343333b333333b334000000000000000045554c4451115255039aabb005949490
499999999999999449999999999999940000000000000000333333333333333344333b33333333440000000000000000544444c415555525003bbb0000594900
00000000000000004444444455555555444444445555555500000000000000000339330000000000000c30000000000000bbb00000000000000cc00000000000
00033000000000004544544451551555454454445155155500000000000c800009333c0003393300033bc330000c300000c8830000bbb00000c9aa00000cc000
033bb3300339bb0045444544515551554c444c4452555255000c80000028c8000299cc0009333c0032b3cb23033bc3300088c23000c883000299a20000c9aa00
3bb33bb30933b900444444445555555544444444555555550028c8000028c8000029c0000299cc00322cb22332b3cb23008222300088c2303229220b0299a200
333bb3330499990044445444555515554444544455551555033c83000328c800002990000029c000bb3333bb322cb22300cc2300008222303399aabb3229220b
bb3333bb0044900044444444555555554444444455555555c00300c0300c8330033430000029900003bbbbc0bb3333bb0033300000cc230003922bb03399aabb
0bbbbbb000449000455544455111555145cc444c5122555230cc03033003003c030cc30003393000223cc3c203bbbbc00c0c02200c3332200033bb0003922bb0
00b44b00000400005444444415555555c444444425555555030c030000c30300030c03000c0cc300203cc30222bccbc23300c0223300c022000cc000003ccb00
00000000000000004544445451555515454444545155551500000000000333000033933033933000000c3000000c3000000bbb000bbb0000000cc00000000000
00000bb000000000544444441555555554444444155555550000000000003c30009333c09333c000033bc330033bc330000c88300c88300000c9aa00000cc000
00aaaabb000000005444544415551555c444c4442555255500c00000000c333c00299cc0499cc00032b3c2b332b3c2b300088c23088c23000299a20000c9aa00
0aaaaaa000000000444445445555515544444c4455555255033300000003333000029c00029c0000322c2233322c2233000822230cc22300022922000299a200
99aaaaaa00000000444444445555555544444444555555553c33c03300333c000002990002990000bb3333bbbb3333bb000cc2300cc230000399aab002292200
099aaaa0000000004445445455515515444544c455515525333333c300c33000003343003343000003222bc003222bc0000333000333300033922bbb0399aab0
0099aa0000000000454445445155515545444c445155525530c333330033c3000030c30030cc300022bccbc222222bc200cc02200c0c02203033bb0b33922bbb
0000000000000000444445445555515544444c445555525500003c3000033300030c0c00030c0300203cc302203cc3023300c0223300c022000cc000303ccb0b
000cc0000000bb0000000000003300000000000000000bb00000000000c33c000000000000000000555555555555555555555555555555555555555555555555
00c9aa00ca2aab000033000000933c0000000bb000aaaabb000000000003c0000000000000000000515511555155551552552cc252555525551551555c255255
0299a200caa2ab00009339000c434c4000aaaabb02caaac00000000c000330000000000000000000551552ccc5515515552522ccc552552cccc555152cc55525
02292200c992abb00943494002ccc2400acaaac022ccacca0000c333000c00000000000000000000555555cc2c55555c555555cc2c1111cc2c225555cc225555
0399aab0092992b0024942400229224099ccacca022aa2a0000003c300000000000000000000000055555555cc1111cc55555555cc222211c551555515525c55
03922bbb02292cc00229224009494940099aaaa00329aa200000000c000000000000000000000000155115511122221125c225511122222215555c252155cc25
0333bb0b0033300009494940034349300329aa20300222030000000000000000000000000000000055cc55111c22222c5ccc5511cc22222c21cc2c15221c2cc5
030cc00000033300034349300303003030022003300222030000000000000000000000000000000055c2c1112222222255c2c11122222222c21cc555c22cc555
000bb00000000bb0003300000033000000000bb000000bb000000000000330000000000000000000555cc11c22222222555cc11c2222c2222215555522215555
0000bb0000000bb000933c0000933c000022aabb002222bb0000000000c33c0000000000000000005555511c222c22225555111c222c22222c1551552c215255
0a22abb000022abb0c434c400c434c4002c2aac002c222c0000000c000033000000000000000000011551111c22c222222511111c22c22222221515522c21255
caa2a22c00ca2a2c02ccc24002ccc24022cc2cca22cc2cc2000333330003c0000000000000000000555511112222c222555111112222c2222221555522221555
c999922c00c9992c0229224002292240022222a0022222200c33c333000330000000000000000000555511112222c222555111112222c2222221551522221525
0c92993000c92993094949400949494003222a2003222220000000c0000030000000000000000000555511112222c222555111112222c2222221555522221555
002233000002233003434930034349303002220330022203000000000000c00000000000000000005115c11c1222222c5225111c1222222cc2155555c2215555
00330000000033000300303030030003300222033002220300000000000000000000000000000000555cc1c1c2222222555cc1c1c22222222215551122215522
55c2c111c1222222c21c2555c2212555000000000000000002000020002222000000000000000000000000000000000000000000000000000000000000000000
55cc5511111222c221cc2c55221c2c55000000000000000002222222020000200000000000000000000000000000000000000000000000000000000000000000
5c2c555111112211155ccc55215ccc55222222222222222202000020200c00020000000000000000000000000000000000000000000000000000000000000000
55c5555cc51111555552c5551552c5550200002002000020000cc0200000c0020000000000000000000000000000000000000000000000000000000000000000
5555155c2c55555522cc555522ccc555020cc02002cccc20000cc02000000c020000000000000000000000000000000000000000000000000000000000000000
55555155ccc551525cc555155ccc5525002002000020020000000020000c00020000000000000000000000000000000000000000000000000000000000000000
5115155cc2c251555555515555555255002002000020020000222222000000200000000000000000000000000000000000000000000000000000000000000000
155555555c5515555115555552255555000220000002200000022020000002000000000000000000000000000000000000000000000000000000000000000000
55c2c111c12222220000000000000000000000000000000020cc222c020cc0200000000000000000000000000000000000000000000000000000000000000000
55cc551111122cc2000000000000000022222222222222222020000c020000200000000000000000000000000000000000000000000000000000000000000000
5c2c555111112222000000000000000002000020020000202020c202022222200000000000000000000000000000000000000000000000000000000000000000
55c5555cc511221100000000000000000cccccc0cccccccc20200202000220000000000000000000000000000000000000000000000000000000000000000000
55c5255c2c1111550000000000000000002002000020020020c00c02000220000000000000000000000000000000000000000000000000000000000000000000
5555525cccc552520000000000000000002002000020020020c22c02022222200000000000000000000000000000000000000000000000000000000000000000
5225255cc2c2525500000000000000000002200000022000c0000002020000200000000000000000000000000000000000000000000000000000000000000000
25555555cc55255500000000000000000000000000000000c22222cc020cc0200000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c20222020200020202c22022202200
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002c20202020200020202020020202000
00000000000000000000000000000000000000000000000000000000000000002020022200222002020022002220022200200202020200020202022022202200
00000000000000000000000000000000000000000000000000000000000000002020020200202002020020002000002c0c200202020200020202020c22002000
000000000000000000000000000000000000000000000000000000000000000020200202002020020200200020000c200c200222022200002020022c20202200
00000000000000000000000000000000000000000000000000000000000000002220022200220002020022002220c0200c000000000000000000000c00000000
00000000000000000000000000000000000000000000000000000000000000002020020200220002020020000020c0200c002220222022002220202c22200033
00000000000000000000000000000000000000000000000000000000000000002020020200202000200020000020c020c00002002020202020202c2020000093
00000000000000000000000000000000000000000000000000000000000000002020020200202000200022002220c020c0000200202020202220020022200c43
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000c000c0002002020202020200200002002cc
0000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000000000000c000c000200222022002020020022200229
0000000000000000000000000000000000000000000000000000000000000000000ccc00000000000000000000000c0000c000000000000000000cc000000949
0000000000000000000000000000000000000000000000000000000000000000000000c000000000000000000000c00000cc1222222222222222222222210c4c
0000000000000000000000000000000000000000000000000000000000000000000012222222222222222222222c00000cc0c112222222222222222221100300
000000000000000000000000000000000000000000000000000000000000000009a00112222222222222222221100000c0000001222111111111122210000000
000000000000000000000000000000000000000000000000000000000000000099aa000122211111111112221000000000000000122200000000222100000eee
00000000000000000000000000000000000000000000000000000000000000009aaa0b00122200000000222100328881a9c00000cccccccccccccccc00002c1c
00000000000000000000000000000000000000000000000000000000000000009aaabb0cccccccccccccccccc0321888a9920000001220000002210000002111
00000000000000000000000000000000000000000000000000000000000000009aaab000cccccccccccccccc0033281829223000001220000002210000000222
00000000000000000000000000000000000000000000000000000000000000009aabb000001220000002210000032888a9933000000122000022100000000222
00000000000000000000000000000000000000000000000000000000000000003bbb00000012200000022100000033bb229300000000220000221cc000000ccc
00000000000000000000000000000000000000000000000000000000000000000000000000012200002210cc00000000b3300000000c12222221000ccc002222
000000000000000000000000000000000000000000000000000000000000000000000000ccc1220000221000ccc00000cc0000000cc001222210000000cc0000
0000000000000000000000000000000000000000000000000000000000000000000000cc0000122222210330000ccc0000000000c0000011110000000000cc00
00000000000000000000000000000000000000000000000000000000000000000ccccc000000012222100933a00000cc20200222c02220020200220022200222
0000000000000000000000000000000000000000000000000000000000000000c00000023b8000122100933bba00000020200202c02020020200200020000020
0000000000000000000000000000000000000000000000000000000000000000000000233bb800011000493b4a0000002020c2c2c02020020200200020000020
000000000000000000000000000000000000000000000000000000000000000000000022bbe800000000494949000000222c02220c2200020200220022200020
0000000000000000000000000000000000000000000000000000000000000000000000288ee800000000594949000000202c02020c2200020200200000200020
00000000000000000000000000000000000000000000000000000000000000000000008888880000000059494900000020200202002020002000200000200020
0000000000000000000000000000000000000000000000000000000000000000000000088880000000000594900000002c200202002c20002000220022200020
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0220c2000888000808800888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000aaa0aaa0aaa000
2c828cc000080080008008080000000000000000000000000000000000000000000000000000000000000000000000000000000000000a0000a0a0a0a0a0a000
28c888200008008000800808000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9a000aaa0aaa0aaa000
02c882000008008000800808000000000000000000000000000000000000000000000000000000000000000000000000000000000000a9a00000a000a000a000
00c8200000080800088808880000000000000000000000000000000000000000000000000000000000000000000000000000000000000a000000a000a000a000
00020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
4444444544444445444444454444444554444445444444454444444543b3333333b3333333333333344444455444444544444445444444454444444544444445
4444444444444444444444444444445444444444444444444444444443b33333b3b33333b3333333344444544444444444444444444444444444444444444454
499999999999944444544444444444444454444444544444445444444333b33b3333b33b33333333344444444454444444544444445444444454444444444444
490000000000944545454445444c4444c54544454545444545454445433b3333333b333333333333344c4444c5454445454544454545444545454445444c4444
490000c00000945444444454445c4444444444544444445444444454433b3333333b333333333333345c444444444454444444544444445444444454445c4444
49000c7c000094444444444444445444444444444444444444444444433333333333333333333333344454444444444444444444444444444444444444445444
49000c6c0000944444454444445444c4445444c444454444445444c44333333333333333333333333445444444454444444544444445444444454444445444c4
49000c6c000094454454444544454c4444454c444454444544454c4443333333333b333333333333345444454454444544544445445444454454444544454c44
49000c6c0000944544444445444444455444444554444445444444455333333333b3333333333333344444454444444544444445444444454444444544444445
4900cdddc000944444444444444444544444445444444444444444544333333333b33333b3333333344444444444444444444444444444444444444444444454
49000c1c000094444454444444444444444444444454444444444444433333333333b33b33333333345444444454444444544444445444444454444444444444
490000c00000944545454445444c4444c44c4444c5454445444c4444c3333333333b3333333333333545444545454445454544454545444545454445444c4444
490000000000945444444454445c4444445c444444444454445c444443333333333b3333333333333444445444444454444444544444445444444454445c4444
49999999999994444444444444445444444454444444444444445444433333333333333333333333344444444444444444444444444444444444444444445444
444544444445444444454444445444c4444544444445444444454444433333333333333333333333345444c44445444444454444444544444445444444454444
44544445445444454454444544454c4444544445445444454454444543333333333b33333333333334454c444454444544544445445444454454444544544445
544444454444444544444445444444455444444544444445444444454333333333b3333333333333344444455444444544444445444444454444444544444445
444444444444444444444444444444544444444444444444444444444333333333b33333b3333333344444544444444444444444444444444444444444444444
44544444445444444454444444444444445444444454444444544444433333333333b33b33333333344444444454444444544444445444444454444444544444
c54544454545444545454445444c4444c5454445454544454545444543333333333b333333333333344c4444c545444545454445454544454545444545454445
444444544444445444444454445c444444444454444444544444445443333333333b333333333333345c44444444445444444454444444544444445444444454
44444444444444444444444444445444444444444444444444444444433333333333333333333333344454444444444444444444444444444444444444444444
44454444444544444445444444454444445444c4445444c4445444c4433333333333333333333333345444c4445444c4445444c4444544444445444444454444
4454444544544445445444454454444544454c4444454c4444454c4443333333333b3333333b333334454c4444454c4444454c44445444454454444544544445
444444454444444544444445444444454444444554444445544444455333333333b3333333b33333344444455444444554444445544444454444444544444445
444444444444444444444444444444444444445444444454444444544333333333b33333b3b33333b44444544444445444444454444444444444444444444444
44544444445444444454444444544444444444444444444444444444433333333333b33b3333b33b344444444444444444444444445444444454444444544444
45454445454544454545444545454445444c4444c44c4444c44c4444c3333333333b3333333b3333344c4444c44c4444c44c4444c54544454545444545454445
44444454444444544444445444444454445c4444445c4444445c444443333333333b3333333b3333345c4444445c4444445c4444444444544444445444444454
44444444444444444444444444444444444454444444544444445444433333333333333333333333344454444444544444445444444444444444444444444444
44454444444544444445444444454444445444c4445444c4445444c4433333333333333333333333345444c4445444c4445444c4444544444445444444454444
4454444544544445445444454454444544454c4444454c4444454c4443333333333b33333333333334454c4444454c4444454c44445444454454444544544445
444444454444444544444445444444454444444554b4bb4b544444455333333333b3333333333333344444455444444554444445544444454444444544444445
4444444444444444444444444444444444444454444bbbb4444444544333333333b33333b3333333344444544444445444444454444444444444444444444444
44544444445444444454444444544444444444444444bb4444444444433333333333b33b33333333344444444444444444444444445444444454444444544444
45454445454544454545444545454445444c4444c44c4444c44c4444c3333333333b333333333333344c4444c44c4444c44c4444c54544454545444545454445
44444454444444544444445444444454445c4444445c4444445c444443333333333b333333333333345c4444445c4444445c4444444444544444445444444454
44444444444444444444444444444444444454444444544444445444433333333333333333333333344454444444544444445444444444444444444444444444
44454444444544444445444444454444445444c4445444c4445444c4445444c443333333345444c4445444c4445444c4445444c4444544444445444444454444
4454444544544445445444454454444544454c4444454c4444454c4444454c444333333334454c4444454c4444454c4444454c44445444454454444544544445
444444454444444544444445444444454444444554b4bb4b5444444554444445533333333444aa4554b4bb4b5444444554444445544444454444444544444445
4444444444444444444444444444444444444454444bbbb4444444544444445443333333344aaaa4444bbbb44444445444444454444444444444444444444444
44544444445444444454444444544444444444444444bb444444444444444444433333333444aa444444bb444444444444444444445444444454444444544444
45454445454544454545444545454445444c4444c44c4444c44c4444c44c4444c3333333344c4444c44c4444c44c4444c44c4444c54544454545444545454445
44444454444444544444445444444454445c4444445c4444445c4444445c444443333333345c4444445c4444445c4444445c4444444444544444445444444454
44444444444444444444444444444444444454444444544444445444444454444333333334445444444454444444544444445444444444444444444444444444
333333333333333333333333333333333333333333333333345444c4433333333333333333333333345444c44333333333333333333333333333333333333333
3333333333333333333b33333333333333333333333b333334454c44433b3333333333333333333334454c4443333333333b33333333333333333333333b3333
333333333333333333b33333333333333333333333b3333334b4bb4b53b333333333333333333333344444455333333333b33333333333333333333333b33333
333333333333333333b33333b33333333333333333b33333b44bbbb443b33333b333333333333333344444544333333333b33333b33333333333333333b33333
33333333333333333333b33b33333333333333333333b33b3444bb444333b33b333333333333333334444444433333333333b33b33333333333333333333b33b
3333333333333333333b33333333333333333333333b3333344c4444c33b33333333333333333333344c4444c3333333333b33333333333333333333333b3333
3333333333333333333b33333333333333333333333b3333345c4444433b33333333333333333333345c444443333333333b33333333333333333333333b3333
33333333333333333333333333333333333333333333333334445444433333333333333333333333344454444333333333333333333333333333333333333333
3333333333333333333333333333333333333333333333333333333333333333345444c443333333333333333333333333333333333333333333333333333333
333b3333333b3333333b3333333b33333333333333333333333b3333333b33333499994443333333333b3333333b3333333b333333333333333b333333333333
33b3333333b3333333b3333333b33333333333333333333333b3333333b33333341f19455333333333b3333333b3333333b333333333333333b3333333333333
33b33333b3b33333b3b33333b3b33333b33333333333333333b33333b3b33333b4ffffa44333333333b33333b3b33333b3b33333b333333333b33333b3333333
3333b33b3333b33b3333b33b3333b33b33333333333333333333b33b3333b33b34888244433333333333b33b3333b33b3333b33b333333333333b33b33333333
333b3333333b3333333b3333333b33333333333333333333333b3333333b33333488f244c3333333333b3333333b3333333b333333333333333b333333333333
333b3333333b3333333b3333333b33333333333333333333333b3333333b333334cccc4443333333333b3333333b3333333b333333333333333b333333333333
333333333333333333333333333333333333333333333333333333333333333334c45c4443333333333333333333333333333333333333333333333333333333
333333333333333333333333333333333333333333333333345444c4433333333333339333333333345444c44333333333333333333333333333333333333333
3333333333333333333b3333333b3333333b33333333333334454c444333333333339333c333333334454c444333333333333333333b3333333b333333333333
333333333333333333b3333333b3333333b333333333333334444445533333333333499cc333333334444445533333333333333333b3333333b3333333333333
333333333333333333b33333b3b33333b3b33333b333333334444454433333333333329c3333333334444454433333333333333333b33333b3b33333b3333333
33333333333333333333b33b3333b33b3333b33b33333333344444444333333333333299333333333444444443333333333333333333b33b3333b33b33333333
3333333333333333333b3333333b3333333b333333333333344c4444c33333333333334333333333344c4444c333333333333333333b3333333b333333333333
3333333333333333333b3333333b3333333b333333333333345c444443333333333333cc33333333345c44444333333333333333333b3333333b333333333333
33333333333333333333333333333333333333333333333334445444433333333333333c33333333344454444333333333333333333333333333333333333333
44454444444544444445444444454444445444c4445444c4445444c4445444c443333333345444c4445444c4445444c4445444c4444544444445444444454444
4454444544544445445444454454444544454c4444454c4444454c4444454c44433b333334454c4444454c4444454c4444454c44445444454454444544544445
544444454444444544444445444444454444444554b4bb4b5444aa455444444553b333333444aa45544444455444444554444445544444454444444544444445
4444444444444444444444444444444444444454444bbbb4444aaaa44444445443b33333b44aaaa4444444544444445444444454444444444444444444444444
44544444445444444454444444544444444444444444bb444444aa44444444444333b33b3444aa44444444444444444444444444445444444454444444544444
c5454445454544454545444545454445444c4444c44c4444c44c4444c44c4444c33b3333344c4444c44c4444c44c4444c44c4444c54544454545444545454445
44444454444444544444445444444454445c4444445c4444445c4444445c4444433b3333345c4444445c4444445c4444445c4444444444544444445444444454
44444444444444444444444444444444444454444444544444445444444454444333333334445444444454444444544444445444444444444444444444444444
445444c4444544444445444444454444445444c4445444c4445444c4433333333333333333333333345444c4445444c4445444c4445444c4445444c444454444
44454c4444544445445444454454444544454c4444454c4444454c4443333333333b33333333333334454c4444454c4444454c4444454c4444454c4444544445
444444455444444544444445444444454444444554444445544444455333333333b3333333333333344444455444444554444445544444455444444554444445
444444544444444444444444444444444444445444444454444444544333333333b33333b3333333344444544444445444444454444444544444445444444444
44444444445444444454444444544444444444444444444444444444433333333333b33b33333333344444444444444444444444444444444444444444544444
444c4444c54544454545444545454445444c4444c44c4444c44c4444c3333333333b333333333333344c4444c44c4444c44c4444c44c4444c44c4444c5454445
445c4444444444544444445444444454445c4444445c4444445c444443333333333b333333333333345c4444445c4444445c4444445c4444445c444444444454
44445444444444444444444444444444444454444444544444445444433333333333333333333333344454444444544444445444444454444444544444444444
44454444444544444445444444454444445444c4445444c4445444c4433333333333333333333333345444c4445444c4445444c4444544444445444444454444
4454444544544445445444454454444544454c4444454c4444454c4443333333333b33333333333334454c4444454c4444454c44445444454454444544544445
444444454444444544444445444444454444444554444445544444455333333333b3333333333333344444455444444554444445544444454444444544444445
444444444444444444444444444444444444445444444454444444544333333333b33333b3333333344444544444445444444454444444444444444444444444
44544444445444444454444444544444444444444444444444444444433333333333b33b33333333344444444444444444444444445444444454444444544444
45454445454544454545444545454445444c4444c44c4444c44c4444c3333333333b333333333333344c4444c44c4444c44c4444c54544454545444545454445
44444454444444544444445444444454445c4444445c4444445c444443333333333b333333333333345c4444445c4444445c4444444444544444445444444454
44444444444444444444444444444444444454444444544444445444433333333333333333333333344454444444544444445444444444444444444444444444
44454444444544444445444444454444444544444445444444454444433333333333333333333333344544444445444444454444444544444445444444454444
44544445445444454454444544544445445444454454444544544445433b3333333b333333333333345444454454444544544445445444454454444544544445
4444444544444445444444454444444544444445444444454444444543b3333333b3333333333333344444454444444544444445444444454444444544444445
4444444444444444444444444444444444444444444444444444444443b33333b3b33333b3333333344444444444444444444444444444444444444444444444
445444444454444444544444445444444454444444544444445444444333b33b3333b33b33333333345444444454444444544444445444444454444444544444
45454445454544454545444545454445454544454545444545454445433b3333333b333333333333354544454545444545454445454544454545444545454445
44444454444444544444445444444454444444544444445444444454433b3333333b333333333333344444544444445444444454444444544444445444444454
44444444444444444444444444444444444444444444444444444444433333333333333333333333344444444444444444444444444444444444444444444444
4445444444454444444544444445444444454444445444c44445444443333333333333333333333334454444445444c444454444444544444445444444454444
445444454454444544544445445444454454444544454c4444544445433b333333333333333333333454444544454c4444544445445444454454444544544445
4444444544444445444444454444444544444445444444455444444543b333333333333333333333344444454444444554444445444444454444444544444445
4444444444444444444444444444444444444444444444544444444443b33333b333333333333333344444444444445444444444444444444444444444444444
445444444454444444544444445444444454444444444444445444444333b33b3333333333333333345444444444444444544444445444444454444444544444
4545444545454445454544454545444545454445444c4444c5454445433b3333333333333333333335454445444c4444c5454445454544454545444545454445
4444445444444454444444544444445444444454445c444444444454433b3333333333333333333334444454445c444444444454444444544444445444444454
99999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999
11111111111111111111111111111111111111111111131111111111111111111111111111111331111111111111111111111111111111111111111111111111
111111111111113311111111111111111111111111111131111111111111119a1111111111111933a1111111111111111111111111111111bb11111111111111
11111111111133bb331177711111339bb11177711111123b811177711111199aa11177711111933bba177711111111111111777111111aaaabb1777111111111
111111111113bb33bb3171711111933b911171711111233bb8117171111319aaa1b171711111493b4a1717111113288818b171711111aaaaaa11717111111111
11111111111333bb333171711111499991117171111122bbe8117171111139aaabb1717111114949491717111113218888b1717111199aaaaaa1717111111111
11111111111bb3333bb1717111111449111171711111288ee8117171111139aaab1171711111594949171711111332818bb17171111199aaaa11717111111111
111111111111bbbbbb11777111111449111177711111888888117771111139aabb1177711111594949177711111132888b1177711111199aa111777111111111
1111111111111b44b111111111111141111111111111188881111111111113bbb111111111111594911111111111133bb1111111111111111111111111111111

__map__
5657565757575657575657575657575657575756575657575657575657565757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575657464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646565656464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646565757464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575757464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646404157464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646505156464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646565657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575657464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575656464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646465746464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5656565757565757575657575646565757465756575756565657575756575756000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5757565656575756565656575756564657565656575657575656565656575757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5757575656575757575656565746575757465757565657575756575756565757000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646465646464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575657464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646565657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646565757464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646565657464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575757464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575657464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575656464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646565656464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646565756464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646565756464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5646464646464646464646464646575656464646464646464646464646464656000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5746464646464646464646464646575656464646464646464646464646464657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5756565656575756565657565756575757575657575657575656565757575657000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
