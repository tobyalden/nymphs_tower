Background = class("Background", Entity)

function Background:initialize()
    Entity.initialize(self, 0, 0)
    self.graphic = Backdrop:new("background.png")
    self.graphic.scroll = 0.5
    self.layer = 2
end

function Background:update(dt)
    self.x = self.x + dt * 60
    self.y = self.y + dt * 60
    Entity.update(self, dt)
end
