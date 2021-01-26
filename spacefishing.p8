pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
title='spacefishing'

-- controls
controls = {
	left=0,
	right=1,
	up=2,
	down=3,
	grab=4,
	reel=5
}

-- flags
loaded=false
started=false

-- game objects
game_objects={}
player = {
	name="player",
	health=3,
	x=0,
	y=0,
	active_sprite=0,
	sprites={
		idle=001
	}
}

function player:new()
	o = {}
	setmetatable(o, self)
	self.__index=self

	return o
end

function player:update()
	-- do player stuff
	print(self.name..', x: '..self.x..' y: '..self.y)
end

-- stardine, a space fish
stardine = {
	name="stardine",
	x=0,
	y=0
}
function stardine:new()
	o = {}
	setmetatable(o, self)
	self.__index=self

	return o
end
function stardine:update()
	print(self.name..', x: '..self.x..' y: '..self.y)
end

function _init()
	cls()
	show_title()
end

function _update()
	-- initial load
	if (loaded!=true) then
		return
	end

	-- start game logic
	cls()

	if (started!=true) then
		start_game()
	end

	print(title)

	-- iterate over gameobjects
	-- and update them all
	foreach(game_objects, function(obj) obj:update() end)
end

function show_title()
	-- for now, just print. make it fancy later
	print(title)
	print('press ❎ to start')
	while true do
		if (btn(controls.reel) or btn(controls.grab)) then
			loaded=true
			break
		end
	end
end

function start_game()
	-- set some values or whatever
	add(game_objects, player:new())
	started=true
end

__gfx__
00000000dddddddd1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd6666dd1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700d6cccc6d1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000d55cc55d1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dddddddd1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000dddd001111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000dddddd01111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dddddddd1111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
