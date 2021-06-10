Background = class("Background", Entity)

function Background:initialize(path, layer, scroll, speed, isInside)
    Entity.initialize(self, 0, 0)
    self.isInside = isInside
    self.graphic = Backdrop:new(path)
    self.graphic.scroll = scroll
    self.graphic.alpha = 1
    self.speed = speed
    self.layer = layer
end

function Background:update(dt)
    self.x = self.x + dt * self.speed
    --self.y = self.y + dt * 60
    local collidedInsides = self.world.player:collide(
        self.world.player.x, self.world.player.y, {"inside"}
    )
    local playerIsInside = #collidedInsides > 0
    if self.isInside and playerIsInside or not self.isInside and not playerIsInside then
        self.graphic.alpha = math.approach(self.graphic.alpha, 1, dt)
    else
        self.graphic.alpha = math.approach(self.graphic.alpha, 0, dt)
    end
    Entity.update(self, dt)
end
