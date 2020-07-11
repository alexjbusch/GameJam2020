pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
--game loops

objects = {}
plants = {}
enemies = {}
function _init()

end
function _update()
 player:update()
 for b in all(plants) do
  b:update()
 end
 for b in all(enemies) do
  b:update()
 end
end
function _draw()
 cls()
 map(0,0)
 for b in all(plants) do
  b:draw()
 end
 for b in all(enemies) do
  b:draw()
 end
 player:draw()
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
-->8
--player
player = {
x=64,
y=64,
w=8,
h=8,
hp=10,
speed=1,
sprite=0,
direction="right",
tool="sword",
update=function(self)
 if btn(➡️) then
  self.x+=self.speed
  self.direction="right"
 end
 if btn(⬅️) then
  self.x-=self.speed
  self.direction="left"
 end 
 if btn(⬆️) then
  self.y-=self.speed
  self.direction="up"
 end
 if btn(⬇️) then
  self.y+=self.speed
  self.direction="down"
 end
 if btn(❎) then
  self:plant_seed()
 end
 --collision logic here
 for b in all(enemies) do
  if collision(self,b) then
   --do collision stuff
  end
 end
end,
draw=function(self)
 self:animate()
 spr(self.sprite,self.x,self.y)
end,
animate=function(self)
 --sprite change logic here
end,
use_tool=function(self)
 if self.tool=="sword" then
  --swing code here
 elseif self.tool=="watering_pail" then

 elseif self.tool=="shotgun" then
 end
  
end,
plant_seed=function(self)
 local offset_x=0
 local offset_y=0
 if self.direction=="up" then
  offset_y=-self.h
 elseif self.direction=="down" then
  offset_y=self.h
 elseif self.direction=="right" then
  offset_x=self.w
 elseif self.direction=="left" then
  offset_x=-self.w
 end
 create_plant(self.x+offset_x,self.y+offset_y,
 "tomato")
end


}
-->8
--plants
function create_plant(xin,yin,class_in)
plant={
x=xin,
y=yin,
class=class_in,
sprite=12,
level=0,
update=function(self)
end,
draw = function(self)
 spr(self.sprite,self.x,self.y)
end
}
if plant.class == "tomato" then
 plant.sprite = 12
elseif plant.class == "corn" then
 plant.sprite = 28
end
add(plants,plant)
end
-->8
--enemies
function create_enemy(xin,yin,class_in)
enemy = {
x=xin,
y=yin,
class=class_in,
w=8,
h=8,
hp=10,
dead=false,
target=nil,
update=function(self)
end,
draw=function(self)
 spr(self.x,self.y,11)
end,
animate=function(self)
 --sprite change code here
end,
move_toward_target=function(self)
 if self.target != nil then
 
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
  if xd<xs and 
     yd<ys then 
    hit=true 
  end
  
  return hit
end

__gfx__
0499994000000000099999900000000000999900000000000499994009999990000000000000000044444444444444440030000000300000444444444444dd44
041ff1400499994009999990099999900091f10000999900041ff1400999999000000000000000004444444444444444000300000003000041144114444dd334
04ffff40041ff14004f99f400999999000ffff000091f10004ffff4004f99f40000a0000000a000044499444444444440083b800002332001491149144d1d133
0288882004ffff400288882004f99f400028880000ffff000f8888200288882000a9a000000a0000449999444b4bb4b40833bb8002133120444444444dd1d1dd
028888200288882002888820028888200026880000288800008888200288880000a9a000000a00004449944444bbbb440883be8002122120444444444d133d1d
0fccccf0028888200fccccf00288882000fccc000028880000ccccf00fcccc00000a0000000a000044444444444bb44408888e8002222220441144113dddd1d1
0cccccc00fccccf00ccccc000fccccf000cccc0000fccc000cccccc00cccccc000000000000000004444444444444444088888800221122011941194333ddd33
0c4cc4c00c4cc4c00c4cc4000c4cc4c000400400004004000c4cc4c00c4cc4c00000000000000000444444444444444400888800001221003333333333333333
04999940049999400999999009999990009999000099990000999900000000000000000000000000444444444444444400000000000000003333333333333333
041ff140041ff14009999990099999900091f1000091f1000091f1000000000000000000000000004444444444444444000990000009900033b3333333333333
04ffff4004ffff4004f99f4004f99f4000ffff0000ffff0000ffff00000000000000000000000000444444444444444400999a00088998803b33333333333333
02888820028888200288882002888820022888f00028880000222f0000000000000000000000000044433444444dd4443099aa0b301881033b33333b33333333
028888f00f8888200f888820028888f00f888820002f8800008888000000000000000000000000004433334444dddd44039aaabb03199133333b33b333333333
0fcccc0000ccccf000ccccf00fcccc0000cccc0000cccc0000cccc00000000000000000000000000434334344d4dd4d4039aaab00339933033b3333333333333
0cccccc00cccccc00cccc4c00c4cccc004cccc0000cc4c0000cccc000000000000000000000000004444444444444444039aabb00311113033b3333333333333
0c4cc0c00c0cc4c00c4cc0c00c0cc4c0000cc40000400c00004004000000000000000000000000004444444444444444003bbb00003333003333333333333333
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600000000000060060000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000600000000000060060000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000000000605150000000000565515000000000056500000000000000000000000000000000000000000000000000000000000000000000000000000000
01000000000000605150000000000555515000000000055500000000000000000000000000000000000000000000000000000000000000000000000000000000
51500000000005650c000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
555000000000055500000000000000000c000000000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000060000000000000006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0060000000c6cc000606000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
060610000c6061c00655100000000000065510000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
065501000c655c100055010000000000005501000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0055000000c55c00000000c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1e1e0e1e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e0f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e0e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e0e1e0e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e0f1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e0f1e1e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1e1e1e1e1e1e1e1e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2828000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
