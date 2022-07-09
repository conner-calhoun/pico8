-- sample screen shaker obj
screen_shaker = {}
screen_shaker.shake = function(self, duration)
    self.shake_time = time()
    self.shake = true
    self.shake_duration = duration
end
screen_shaker.update = function(self) -- must call this in an update loop somewhere
    if self.shake and (time() - self.shake_time) < self.shake_duration then
        local cx = flr(rnd(4)) - 2
        local cy = flr(rnd(4)) - 2
        camera(cx, cy)
    else
        camera(0, 0)
        self.shake = false
        self.shake_time = 0
        self.shake_duration = 0
    end
end