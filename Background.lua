Background = class("Background", Entity)

function Background:initialize()
    Entity.initialize(self, 0, 0)
    self.graphic = Backdrop:new("background.png")
    self.layer = 2
end

function Background:update(dt)
    self.x = self.x + dt * 30
    self.y = self.y + dt * 30
    Entity.update(self, dt)
end
