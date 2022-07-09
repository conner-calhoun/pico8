pico-8 cartridge // http://www.pico-8.com
version 29
__lua__

-- constants
size = 128
left,right,up,down,use1,use2=0,1,2,3,4,5
black,dark_blue,dark_purple,dark_green,brown,dark_gray,light_gray,white,red,orange,yellow,green,blue,indigo,pink,peach=0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15

-- sample screen shaker obj
screen_shaker = {
    shake = false,
    shake_time = 0,
    shake_duration = 0
}
screen_shaker.run = function(self, duration)
    self.shake = true
    self.shake_time = time()
    self.shake_duration = duration
end
screen_shaker.update = function(self) -- must call this in an update loop somewhere
    if self.shake and (time() - self.shake_time) < self.shake_duration then
        local cx = flr(rnd(2)) - 1
        local cy = flr(rnd(2)) - 1
        camera(cx, cy)
    else
        camera(0, 0)
        self.shake = false
        self.shake_time = 0
        self.shake_duration = 0
    end
end

-- helpers for playing animations
function new_anim(s, e, d)
    local a = {}

    a.start_frame = s -- start frame
    a.end_frame = e -- end frame
    a.delay = d -- delay
    a.timer = 0 -- timer

    return a
end
function new_anim_player()
    local p = {}

    p.sprite = nil
    p.current = nil
    p.anim_list = {}

    p.add = function(self, name, anim)
        self.anim_list[name] = anim
    end

    p.set = function(self, name)
        self.current = name
    end

    p.update = function(self)
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

    return p
end

player = {}
player.init = function(self)
    self.anim_player = new_anim_player()
    self.anim_player:add("default", new_anim(1, 2, 0.1))
    self.anim_player:set("default")
end
player.draw = function(self)
    mid = (size / 2) - 4
    spr(self.anim_player.sprite, mid, mid)
end
player.update = function(self)
    self.anim_player:update()
end

-- main loops
function _init()
    player:init()
end

function _draw()
    cls()
    player:draw()
end

function _update()
    player:update()
    screen_shaker:update()

    if btn(use1) or btn(use2) then
        screen_shaker:run(0.5)
    end
end



__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700009009000990099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700009009000990099000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000990000009900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
