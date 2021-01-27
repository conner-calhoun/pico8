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
	harpoon_fired=false,
	harpoon_tick=0,
	harpoon_cooldown=20,
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
	self:handle_keys()
	self:harpoon_ctrl()
end

function player:draw()
	print("harpoon_fired: "..tostring(self.harpoon_fired))
end

function player:handle_keys()
	--harpoon fire controls
	if (btnp(controls.left)) then
		--fire left
		self.harpoon_fired=true
	elseif (btnp(controls.right)) then
		--fire right
		self.harpoon_fired=true
	elseif (btnp(controls.up)) then
		--fire up
		self.harpoon_fired=true
	elseif (btnp(controls.down)) then
		--fire down
		self.harpoon_fired=true
	end
end

function player:harpoon_ctrl()
	if (self.harpoon_fired==true) then
		if (self.harpoon_tick == self.harpoon_cooldown) then
			self.harpoon_fired=false
			self.harpoon_tick=0
		else
			self.harpoon_tick+=1
		end
	end
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
function stardine:draw() end
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

function _draw()
	foreach(game_objects, function(obj) obj:draw() end)
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
__sfx__
000100002b7502f7502f7502b7501e75015750117500e7500c7500c7500d75012750247502e75022750167500f750097500875006750057500475003750027500175003750007500075003750027500275001750
0001000025700257002270021700207001c7000f7000e7000d7000c7000d7000e7001170014700177001c700207002370026700287002a7002a7002b7002b7002a7502a7502a7502975027750267502375000000
__music__
00 00424344

