Background = class("Background", Entity)

function Background:initialize()
    Entity.initialize(self, 80, 73)
    self.graphic = Backdrop:new("background.png")
    self.layer = 2
end

function Background:update(dt)
    self.x = self.x - dt * 10
    self.y = self.y + dt * 10
    Entity.update(self, dt)
end
