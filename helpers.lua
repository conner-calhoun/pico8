-- see tester.p8 for usage :)


-- helper for screen shake
screen_shaker = {}
screen_shaker.shake = function(self, duration)
    self.active = true
    self.shake_time = time()
    self.shake_duration = duration
end
-- must call this in an update loop, probably the main '_update' function
-- since this can be a global object
screen_shaker.update = function(self)
    if self.active and (time() - self.shake_time) < self.shake_duration then
        local cx = flr(rnd(4)) - 2
        local cy = flr(rnd(4)) - 2
        camera(cx, cy)
    else
        camera(0, 0)
        self.active = false
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