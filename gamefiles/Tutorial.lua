Tutorial = class("Tutorial", Entity)

function Tutorial:initialize(x, y, text, requireFlag)
    Entity.initialize(self, x, y)
    self.layer = -98
    self.types = {"tutorial"}
    self.graphic = Text:new(text, 10)
    self.requireFlag = requireFlag
    self.glowTimerBackward = false
    self.glowTimer = self:addTween(Alarm:new(
        3,
        function()
            self.glowTimerBackward = not self.glowTimerBackward
        end,
        "looping"
    ), true)
end

function Tutorial:update(dt)
    if self.requireFlag and self.requireFlag ~= "" and not self.world:hasFlag(self.requireFlag) then
        self.graphic.alpha = 0
    elseif self.glowTimerBackward then
        self.graphic.alpha = 0.5 + (1 - self.glowTimer:getPercentComplete()) / 3
    else
        self.graphic.alpha = 0.5 + (self.glowTimer:getPercentComplete() / 3)
    end
    Entity.update(self, dt)
end
