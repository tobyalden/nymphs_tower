Background = class("Background", Entity)

function Background:initialize(path, layer, scroll, speed)
    Entity.initialize(self, 0, 0)
    self.graphic = Backdrop:new(path)
    self.graphic.scroll = scroll
    self.speed = speed
    self.layer = layer
end

function Background:update(dt)
    self.x = self.x + dt * self.speed
    --self.y = self.y + dt * 60
    Entity.update(self, dt)
end
