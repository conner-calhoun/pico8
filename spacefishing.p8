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

-- base world class
world = {}
function world:new(init, draw, update)
	o = {}
	setmetatable(o, self)
	self.__index=self

	o.initialized = false
	o.game_objects = {}

	-- methods
	o.init = init
	o.draw = draw
	o.update = update

	return o
end

-- create the title world
title_world = world:new(
	function(self) --init
		self.initialized = true
	end,
	function(self) --draw
		foreach(self.game_objects, function(obj) obj:draw() end)
	end,
	function(self) --update
		if (self.initialized == false) then
			self:init()
		end
		print(title)
		print('press ❎ to start')
		if (btn(controls.reel) or btn(controls.grab)) then
			-- change worlds
			active_world=test_world
		end

		foreach(self.game_objects, function(obj) obj:update() end)
	end
)

-- create the title world
test_world = world:new(
	function (self) --init
		self.initialized = true
		add(self.game_objects, player:new())
	end,
	function(self) --draw
		foreach(self.game_objects, function(obj) obj:draw() end)
	end,
	function(self) --update
		if (self.initialized == false) then
			self:init()
		end
		print(title)
		foreach(self.game_objects, function(obj) obj:update() end)
	end
)

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

function player:draw()
	print("harpoon_fired: "..tostring(self.harpoon_fired))
end

function player:update()
	-- do player stuff
	self:handle_keys()
	self:harpoon_ctrl()
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

-- item base
item = { name="",x=0,y=0,sprite=0 }
function item:new()
	o = {}
	setmetatable(o, self)
	self.__index=self

	return o
end
function item:update()
	print(self.name..', x: '..self.x..' y: '..self.y)
end
function item:draw() end

function _init()
	cls()
	active_world = title_world
	active_world:init()
end

function _update()
	cls()
	active_world:update()
end

function _draw()
	active_world:draw()
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

