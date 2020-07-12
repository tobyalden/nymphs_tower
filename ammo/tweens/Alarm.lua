Alarm = class("Alarm")

function Alarm:initialize(duration, complete, ...)
    self.active = false
    self.time = 0
    self.defaultDuration = duration
    self.duration = self.defaultDuration
    self.complete = complete
    self.completeArgs = { ... }
end

function Alarm:start(newDuration)
    self.duration = newDuration or self.defaultDuration
    self.active = true
    self.time = 0
end

function Alarm:getPercentComplete()
    return math.min(self.time / self.duration, 1)
end

function Alarm:update(dt)
    if self.active then
        self.time = self.time + dt
    end

    if self.time >= self.duration then
        if self.complete then
            self.complete(unpack(self.completeArgs))
        end
        self.active = false
        self.time = 0
    end
end
