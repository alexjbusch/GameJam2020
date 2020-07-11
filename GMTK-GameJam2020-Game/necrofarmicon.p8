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
 spr(self.x,self.y,0)
 --rect(self.x,self.y,20,20)
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


}
-->8
--plants
plant={
x=0,
y=0,
level=0,
update=function(self)
end,
draw = function(self)
 spr(self.x,self.y,10)
end

}
-->8
--enemies
enemy = {
x=0,
y=0,
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

