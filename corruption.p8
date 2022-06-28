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
    this.current = nil
	this.anim_list = {}

    this.add = function(self, name, anim)
        self.anim_list[name] = anim
    end

    this.set = function(self, name)
        self.current = name
    end

    this.update = function(self)
        local anim = self.anim_list[self.current]
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

bullets = {}
function fire_bullet(sx, sy, info)
    local bullet = {}
    bullet.anims = anim_player:new()

    bullet.x = sx
    bullet.y = sy

    bullet.info = info

    bullet.anims:add("default", anim:new(8, 10, 0.1))
    bullet.anims:set("default")

    bullet.draw = function(self)
        local s = self.anims.sprite
        spr(s, self.x, self.y)
    end

    bullet.update = function(self)
        self.anims:update()

        dir = self.info.dir
        speed = self.info.speed
        if dir == left then
            self.x -= speed
        end
        if dir == right then
            self.x += speed
        end
        if dir == up then
            self.y -= speed
        end
        if dir == down then
            self.y += speed
        end

        local oob_min = 0 - 16
        local oob_max = world_size + 16
        if self.x > oob_max or self.x < oob_min
            or self.y > oob_max or self.y < oob_min then
            del(bullets, self)
        end
    end
    add(bullets, bullet)
end

-- glitch is the enemy
glitches = {}
function new_glitch(sx, sy)
    local g = {}
    g.anims = anim_player:new()

    g.anims:add("idle", anim:new(20,22,0.1))
    g.anims:set("idle")

    g.x = sx
    g.y = sy

    g.draw = function(self)
        local s = self.anims.sprite
        spr(s, self.x, self.y)
    end

    g.update = function(self)
        self.anims:update() -- must update anims
    end
    add(glitches, g)
end

function new_player()
    local player = {
        x = 0, y = 0,
        dir = right, -- todo 8 dir shooting

        -- movement
        accel = 0.6,
        decel = 0.15,
        max_speed = 1.05,
        dx = 0,
        dy = 0,

        -- bullet stuff
        last_bullet = 0,
        bullet_cool = 0.5, --seconds

        -- anims & sprite stuff
        anims = anim_player:new(),
        flip = false,

        draw_debug = function(self)
            print("bullet timer: " .. time() - self.last_bullet, 0, world_size - 8)
        end,

        init = function(self)
            self.anims:add("idle", anim:new(4,5,0.5))
            self.anims:add("run", anim:new(6,7,0.25))
            self.anims:set("idle")
        end,

        draw = function(self)
            local s = self.anims.sprite
            spr(s, self.x, self.y, 1, 1, self.flip)
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
                self.flip = true
            end
            if btn(right) then
                self.dx = min(self.dx+self.accel, self.max_speed)
                self.dir = right
                move_h = true
                self.flip = false
            end

            -- decelerate
            if not move_h then
                self.dx = lerp(self.dx, 0, self.decel)
            end
            if not move_v then
                self.dy = lerp(self.dy, 0, self.decel)
            end

            if move_h or move_v then
                self.anims:set("run")
            else
                self.anims:set("idle")
            end

            self.x += self.dx
            self.y += self.dy

            -- ***shoot***
            if btn(use1) or btn(use2) then
                if (time() - self.last_bullet) > self.bullet_cool then
                    self.last_bullet = time()

                    info = {}
                    info.dir = self.dir
                    info.speed = 2.5
                    fire_bullet(self.x, self.y, info)
                end
            end

            -- ***anims***
            self.anims:update()
        end
    }
    return player
end

function draw_frame()
    map(0, 0, 0, 0, 13, 16)
end

function draw_ui()
    print("atk: " .. 1, 102, 8, white)
    print("spd: " .. 1, 102, 16, white)
end

-- main loops
function _init()
    player = new_player()
    player:init()

    new_glitch(5, 5)
end

function _draw()
    -- todo move this to the world
    cls(black)

    draw_frame()
    draw_ui()

    player:draw()
	for bullet in all(bullets) do
		bullet:draw()
	end
    for glitch in all(glitches) do
		glitch:draw()
	end
end

function _update()
    player:update()
	for bullet in all(bullets) do
		bullet:update()
	end
    for glitch in all(glitches) do
      glitch:update()
	end
end

__gfx__
000000003333363333333333333333330eeeeee0000000000000eeee0000eeee0000000000000000000000000000000000000000000000000000000000000000
00000000333639333333333335555553e111111e0eeeeee00eee11e00eee11e00000000000000000000000000000000000000000000000000000000000000000
00000000333b35555559b333355555530e1e11e0e111111eee1e11e0ee1e11e00000000000000000000090000000000000000000000000000000000000000000
00000000333b3555555333333939393b0e1e11e00e1e11e00e1e11e00e1e11e00000900000099000000999000000000000000000000000000000000000000000
00000000333b35555559b3333b3b3b3b00e11e000e1e11e000e11e0000e11e000009990000099000000090000000000000000000000000000000000000000000
00000000333b3555555333333b3b3b3b000ee00000e11e00000eee0000eee0000000900000000000000000000000000000000000000000000000000000000000
00000000533b35555559b33333bbbbb300e00e0000eeee0000e00ee00ee00e000000000000000000000000000000000000000000000000000000000000000000
000000005bbb355555533333333b3b330ee00ee00ee00ee00ee0000000000ee00000000000000000000000000000000000000000000000000000000000000000
33333333533333b3b3333333333333330a00d0000000d0c000a0d00d000000000000000000000000000000000000000000000000000000000000000000000000
333333335bbbb3b3b336363695555559ddadded40dcccdd000aeeed4000000000000000000000000000000000000000000000000000000000000000000000000
333333335333b3b3b3333333355555530edccccccedeedaaaeddddcc000000000000000000000000000000000000000000000000000000000000000000000000
333333335bb3b3b3bbb63333955555594c444a444caaac444ccccc44000000000000000000000000000000000000000000000000000000000000000000000000
3333333353b3b3b33333333335555553daacaaaa0a4ceeeedaaca444000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b3b3bbbbbbb63395555559eeeceeeeaaccaaaaeeeceeee000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b363333b333333355555530aa4aca0d4c04ca0c4ceaca4000000000000000000000000000000000000000000000000000000000000000000000000
3333333333b333333b333333333333330a0a0d000a000d000aea0d04000000000000000000000000000000000000000000000000000000000000000000000000
33633333333333330000000099999999955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
33b333b3b33339330000000055555555955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
33633696933335330000000055555555955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
3555363633bb55530000000000000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
3555333333b355530000000000000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
35556bbbbbb335335555555500000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
33633333333339335555555500000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
33b33333333333339999999900000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
33bbbbbbbbbbbbb60000059999500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333330000055995500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb60000005555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3333333333333330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3bbbbbbbbbbbbb60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000550000000000005500000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000955000000000055900000000000000000000000000000000000000000000000000000000000000000000000000000000
b3b33333333333330000000000000000995000000000059900000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
3522222222222222222222223400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
2510101010101010101010102400000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
3223232323232323232323233300000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303030303
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
