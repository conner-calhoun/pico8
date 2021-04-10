pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- constants
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

active_world = nil

world = {}
function world:new()
	this = {}
	setmetatable(this, self)
	self.__index=self

	this.entities = {}

	this.add_entity = function(ent)
		add(this.entities, ent)
	end

	this.update = function()
		for entity in all(this.entities) do
			entity:update()
		end
	end

	this.draw = function()
		for entity in all(this.entities) do
			entity:draw()
		end
	end

	return this
end

entity = {}
function entity:new(x, y, sprt)
	this = {}
	setmetatable(this, self)
	self.__index=self

	this.x = x
	this.y = y
	this.i_spr = sprt -- initial sprite
	this.spr = this.i_spr -- active sprite
	this.anm_tmr = 0 -- animation timer
	this.flip = false

	this.draw = function()
	end

	this.update = function()
	end

	return this
end

player = entity:new(30, 30, 1)
function player:update()
	if btn(left) then
		self.x -= 1
	end

	if btn(right) then
		self.x += 1
	end
end
function player:draw()
	spr(self.spr, self.x, self.y)
end


world_1 = world:new()
world_1.add_entity(player)

active_world = world_1

function _draw()
	cls()
	active_world:draw()
end

function _update()
	active_world:update()
end
__gfx__
00000000088eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000002888888e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700288888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000288088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000288888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700228888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000022222200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000008200008e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
