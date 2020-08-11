Alarm = class("Alarm")

function Alarm:initialize(duration, complete, tweenType)
    self.active = false
    self.time = 0
    self.defaultDuration = duration
    self.duration = self.defaultDuration
    self.complete = complete
    --self.completeArgs = { ... }
    self.tweenType = tweenType or "oneshot"
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
            --self.complete(unpack(self.completeArgs))
            self.complete()
        end
        self.time = 0
        if self.tweenType == "looping" then
            -- stay active
        else
            self.active = false
        end
    end
end
