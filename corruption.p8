pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- globals
world_size = 128 -- pixels
left,right,up,down,use1,use2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

-- start engine code
function min(l, r)
	if l < r then
		return l
	else
		return r
	end
end
function max(l, r)
	if l > r then
		return l
	else
		return r
	end
end
-- dirty constant lerp
function lerp (from, to, step)
	if abs(from - to) < step then
		return to
	end

	if from > to then
		return max(to, from-step)
	elseif from < to then
		return min(to, from+step)
	else
		return to
	end
end

-- helper for playing animations
anim = {}
function anim:new(s, e, d)
	this = {}
	setmetatable(this, self)
	self.__index=self

	this.start_frame = s -- start frame
	this.end_frame = e -- end frame
	this.delay = d -- delay
	this.timer = 0 -- timer

	return this
end
anim_player = {}
function anim_player:new()
    this = {}
    setmetatable(this, self)
    self.__index=self

    this.sprite = nil
	this.anim_list = {}

    this.add_anim = function(self, name, anim)
        self.anim_list[name] = anim
    end

    this.set_anim = function(self, name)
        self.anim = name
    end

    this.update = function(self)
        local anim = self.anim_list[self.anim]
        if not self.sprite then
            self.sprite = anim.start_frame
        end
        if time() - anim.timer > anim.delay then
            self.sprite += 1
            if self.sprite > anim.end_frame or self.sprite < anim.start_frame then
                self.sprite = anim.start_frame
            end
            anim.timer = time()
        end
    end

    return this
end

function fire_bullet(x, y, dir)
    bullet = {}
    bullet.draw = function(self)

    end
    bullet.update = function(self)

    end
end

function new_player()
    local player = {
        x = 0, y = 0,
        dir = -1,

        -- movement
        accel = 0.6,
        deccel = 0.15,
        max_speed = 1.05,
        dx = 0,
        dy = 0,

        -- bullet stuff
        last_bullet = 0,
        bullet_cool = 0.5, --seconds

        anims = anim_player:new(),

        draw_debug = function(self)
            print("bullet timer: " .. time() - self.last_bullet, 0, world_size - 8)
        end,

        init = function(self)
            self.anims:add_anim("idle", anim:new(4,5,0.5))
            self.anims:set_anim("idle")
        end,

        draw = function(self)
            local s = self.anims.sprite
            spr(s, self.x, self.y)
        end,

        update = function(self)
            -- ***move***
            local move_v = false
            local move_h = false
            if btn(up) then
                self.dy = max(self.dy-self.accel, -self.max_speed)
                self.dir = up
                move_v = true
            end
            if btn(down) then
                self.dy = min(self.dy+self.accel, self.max_speed)
                self.dir = down
                move_v = true
            end
            if btn(left) then
                self.dx = max(self.dx-self.accel, -self.max_speed)
                self.dir = left
                move_h = true
            end
            if btn(right) then
                self.dx = min(self.dx+self.accel, self.max_speed)
                self.dir = right
                move_h = true
            end

            -- decelerate
            if not move_h then
                self.dx = lerp(self.dx, 0, self.deccel)
            end
            if not move_v then
                self.dy = lerp(self.dy, 0, self.deccel)
            end

            self.x += self.dx
            self.y += self.dy

            -- ***shoot***
            if btn(use1) then
                if (time() - self.last_bullet) > self.bullet_cool then
                    self.last_bullet = time()
                    fire_bullet(self.x, self.y, self.dir)
                end
            end

            -- ***anims***
            self.anims:update()
        end
    }
    return player
end

player = {}
bullets = {}

-- main loops
function _init()
    player = new_player()
    player:init()
end

function _draw()
    -- todo move this to the world
    map(0, 0, 0, 0, 16, 16)
    player:draw()
	for bullet in all(bullets) do
		bullet:draw()
	end
end

function _update()
    player:update()
	for bullet in all(bullets) do
		bullet:update()
	end
end

__gfx__
00000000333336333333333333333333000ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000033363933333333333555555300edde00000ee00000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333b35555559b333355555530ededde00eeddee000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333b3555555333333939393b0ededde0eddeddde00000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333b35555559b3333b3b3b3b00edde000ededde000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000333b3555555333333b3b3b3b000ee00000edde0000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000533b35555559b33333bbbbb300e00e0000eeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000005bbb355555533333333b3b330ee00ee00ee00ee000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333533333b3b333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333335bbbb3b3b336363600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333335333b3b3b333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
333333335bb3b3b3bbb6333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333353b3b3b33333333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b3b3bbbbbbb63300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b363333b33333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b333333b33333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33633333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b333b3b33339330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33633696933335330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3555363633bb55530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3555333333b355530000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
35556bbbbbb335330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33633333333339330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33b33333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbb60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3bbbbbbbbbbbbb60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010031010101010101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010101010101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010101010010210101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010100310102021111201021010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010103031010211121010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101001202110111210101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010010211303110101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010111210010210031010010210101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010111210101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101001022021101010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010103031101010102021101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010101010100102103031101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
1010101010101010101112101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2021101010101020211010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
3031101010101030311010101010101010000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0006060600000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000060600000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
