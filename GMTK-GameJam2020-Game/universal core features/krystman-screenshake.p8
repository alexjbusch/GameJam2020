pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- **************************
-- ***    screenshake     ***
-- **************************

-- this sample code shows
-- how to add screenshake

-- it also show how to fade
-- an image to black using the
-- palette function

function _init()
 -- shake tells how much to
 -- shake the screen
 shake=0
 
 -- develop says how much
 -- the polaroid has developed
 -- at 100 it's fully
 -- developed
 develop=0
 
 -- devspeed is how much the
 -- polaroid is developing per
 -- frame
 devspeed=0
end

function _update60()
 if btnp(4) then
  -- if a button is pressed
  -- add some shake
  -- start developing picture
  -- note that we add to the
  -- shake variable so shaking
  -- is cumulative. mashing
  -- the button will shake
  -- screen a lot.
  shake+=1
  devspeed+=0.04
 end
 
 --develop the picture here
 develop+=devspeed
 
 --make sure it never goes
 --above 100
 develop=min(100,develop)
end

function _draw()
 -- clear the screen
 cls()
 
 -- reset the palette
 pal()
 
 --do the shaking
 doshake()
 
 -- fill the screen with a
 -- color
 rectfill(0,0,128,128,1)

 -- draw the polaroid frame 
 spr(1,48,48,4,4)
 
 -- print a help text if
 -- polaroid undeveloped
 if develop<5 then
  print("press ❎ to shake it",24,92,7)
 end
 
 -- this function is to actually
 -- fade the polaroid picture
 -- to black.
 -- it accepts a number from
 -- 0 to 1
 -- 0 means normal
 -- 1 is completely black
 -- so we do some math to
 -- match our numbers
 fadepal((100-develop)/100)
 
 -- the fade function changes
 -- the palette. we can now
 -- just draw the polaroid
 -- image 
 spr(5,48,48,4,4)
end

function doshake()
 -- this function does the
 -- shaking
 -- first we generate two
 -- random numbers between
 -- -16 and +16
 local shakex=16-rnd(32)
 local shakey=16-rnd(32)

 -- then we apply the shake
 -- strength
 shakex*=shake
 shakey*=shake
 
 -- then we move the camera
 -- this means that everything
 -- you draw on the screen
 -- afterwards will be shifted
 -- by that many pixels
 camera(shakex,shakey)
 
 -- finally, fade out the shake
 -- reset to 0 when very low
 shake = shake*0.95
 if (shake<0.05) shake=0
end

function fadepal(_perc)
 -- this function sets the
 -- color palette so everything
 -- you draw afterwards will
 -- appear darker
 -- it accepts a number from
 -- 0 means normal
 -- 1 is completely black
 -- this function has been
 -- adapted from the jelpi.p8
 -- demo
 
 -- first we take our argument
 -- and turn it into a 
 -- percentage number (0-100)
 -- also making sure its not
 -- out of bounds  
 local p=flr(mid(0,_perc,1)*100)
 
 -- these are helper variables
 local kmax,col,dpal,j,k
 
 -- this is a table to do the
 -- palette shifiting. it tells
 -- what number changes into
 -- what when it gets darker
 -- so number 
 -- 15 becomes 14
 -- 14 becomes 13
 -- 13 becomes 1
 -- 12 becomes 3
 -- etc...
 dpal={0,1,1, 2,1,13,6,
          4,4,9,3, 13,1,13,14}
 
 -- now we go trough all colors
 for j=1,15 do
  --grab the current color
  col = j
  
  --now calculate how many
  --times we want to fade the
  --color.
  --this is a messy formula
  --and not exact science.
  --but basically when kmax
  --reaches 5 every color gets 
  --turns black.
  kmax=(p+(j*1.46))/22
  
  --now we send the color 
  --through our table kmax
  --times to derive the final
  --color
  for k=1,kmax do
   col=dpal[col]
  end
  
  --finally, we change the
  --palette
  pal(j,col)
 end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000077000000000000000000000000007700001111111111111113333333333300000000000011111112222222333333000000000000000000000000000
00077000077000000000000000000000000007700001111111111111133333333333300000000000011111112222222333333000000000000000000000000000
0070070007700000000000000000000000000770000c11999911c11c113333333333300000000000011111112222222333333000000000000000000000000000
00000000077000000000000000000000000007700001199aa9911111111333333833300000000000011111112222222333333000000000000000000000000000
00000000077000000000000000000000000007700001c9a77a91c1c1c1c338333333300000000000011111112222222333333000000000000000000000000000
0000000007700000000000000000000000000770000c19a77a9c1c1c1c1333333333300000044444455555556666666777777000000000000000000000000000
0000000007700000000000000000000000000770000cc99aa99cccccccccc3333383300000044444455555556666666777777000000000000000000000000000
00000000077000000000000000000000000007700001cc9999cc1cc1cc1cc3333333c00000044444455555556666666777777000000000000000000000000000
0000000007700000000000000000000000000770000cccccccccccccccccccc4444cc00000044444455555556666666777777000000000000000000000000000
0000000007700000000000000000000000000770000cccccccccccccccccccc4444cc00000044444455555556666666777777000000000000000000000000000
0000000007700000000000000000000000000770000cccccccccccccccccccc4444cc00000044444455555556666666777777000000000000000000000000000
0000000007700000000000000000000000000770000c7c7c7c7c7c7c7c7c7c74444c70000008888889999999aaaaaaabbbbbb000000000000000000000000000
0000000007700000000000000000000000000770000777777777777777777744444770000008888889999999aaaaaaabbbbbb000000000000000000000000000
0000000007700000000000000000000000000770000bbbbbbbbbbbbbbbbbbb44444440000008888889999999aaaaaaabbbbbb000000000000000000000000000
0000000007700000000000000000000000000770000bbbbbbbbbbbbbbbbbb4444444b0000008888889999999aaaaaaabbbbbb000000000000000000000000000
0000000007700000000000000000000000000770000bbbbbbbbbbbbbbbbbbbbbbbbbb0000008888889999999aaaaaaabbbbbb000000000000000000000000000
00000000077000000000000000000000000007700003b3b3b3b3b3b3b3b3b3b3b3b3b000000ccccccdddddddeeeeeeeffffff000000000000000000000000000
0000000007700000000000000000000000000770000b3b3b3b3b3b3b3b3b3b3b3b3b3000000ccccccdddddddeeeeeeeffffff000000000000000000000000000
000000000770000000000000000000000000077000033333333333333333333333333000000ccccccdddddddeeeeeeeffffff000000000000000000000000000
00000000077000000000000000000000000007700003b33b33b33b33b33b33b33b33b000000ccccccdddddddeeeeeeeffffff000000000000000000000000000
000000000770000000000000000000000000077000033333333333333333333333333000000ccccccdddddddeeeeeeeffffff000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000077777777777777777777777777777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000066666666666666666666666666666600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117700000000000000000000000000771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111117777777777777777777777777777771111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111116666666666666666666666666666661111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111177717771777117711771111117777711111177711771111117717171777171717771111177717771111111111111111111111111
11111111111111111111111171717171711171117111111177171771111117117171111171117171717171717111111117111711111111111111111111111111
11111111111111111111111177717711771177717771111177717771111117117171111177717771777177117711111117111711111111111111111111111111
11111111111111111111111171117171711111711171111177171771111117117171111111717171717171717111111117111711111111111111111111111111
11111111111111111111111171117171777177117711111117777711111117117711111177117171717171717771111177711711111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111

