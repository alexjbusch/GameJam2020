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
-->8
--player
player = {
x=64,
y=64,
hp=10,
speed=1,
sprite=0,
tool="sword",
update=function(self)
 if btn(➡️) then
  self.x+=self.speed
 end
 if btn(⬅️) then
  self.x-=self.speed
 end 
 if btn(⬆️) then
  self.y-=self.speed
 end
 if btn(⬇️) then
  self.y+=self.speed
 end
 if btn(❎) then
  
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
hp=10,
update=function(self)
end,
draw=function(self)
 spr(self.x,self.y,11)
end,
animate=function(self)
 --sprite change code here
end
}
