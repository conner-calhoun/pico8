pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- constants
left,right,up,down,fire1,fire2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

-- class definitions

world = {}
function world:new()
	this = {}
	setmetatable(this, self)
	self.__index=self

	this.entities = {}

	return this
end
function world:add_entity(ent)
	ent:init()
	add(self.entities, ent)
end
function world:update()
	for entity in all(self.entities) do
		entity:update()
	end
end
function world:draw()
	cls()
	for entity in all(self.entities) do
		entity:draw()
	end
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

	this.anim = nil -- active animation
	this.anims = {} -- list of anims

	this.init = function() end
	this.draw = function() end
	this.update = function() end

	return this
end
function entity:add_anim(name, anim)
	self.anims[name] = anim
end
function entity:handle_animation()
	-- based on the active animation, get the animation and run through the sprites
	if self.anim then
		local anim = self.anims[self.anim]
		if not anim.playing then
			self.spr = anim.start_f
			anim.playing = true
		end
		if time() - anim.tmr > anim.delay then
			self.spr += 1
			if self.spr > anim.end_f then
				if anim.loop then
					self.spr = anim.start_f
				else
					self.spr = self.i_spr
				end
			end
			anim.tmr = time()
		end
	end
end

animation = {}
function animation:new(s, e, d, l)
	this = {}
	setmetatable(this, self)
	self.__index=self

	this.start_f = s -- start frame
	this.end_f = e   -- end frame
	this.loop = l or false -- loop animation
	this.playing = false
	this.tmr = 0 -- timer
	this.delay = d

	return this
end

-- end class definitions

active_world = nil

player = entity:new(30, 30, 0)
function player:init()
	idle_anim = animation:new(0,1, 0.5, true)
	self:add_anim("idle", idle_anim)
	self.anim = "idle"
end
function player:update()
	if btn(left) then
		self.x -= 1
		self.flip = true
	end

	if btn(right) then
		self.x += 1
		self.flip = false
	end

	self:handle_animation()
end
function player:draw()
	spr(self.spr, self.x, self.y, 1, 1, self.flip)
end

world_1 = world:new()
world_1:add_entity(player)

active_world = world_1

function _draw()
	active_world:draw()
end

function _update()
	active_world:update()
end
__gfx__
088eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2888888e088eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
288888882888888e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28808880288888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
28888888288088800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22888882288888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02222220288888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
8200008e8222222e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
