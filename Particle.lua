Particle = class("Particle", Entity)

function Particle:initialize(x, y, heading, speed, scale, fps)
    Entity.initialize(self, x, y)
    self.graphic = Sprite:new("particle.png", 12, 12)
    self.graphic.scaleX = scale
    self.graphic.scaleY = scale
    self.graphic:add("dissipate", {1, 2, 3, 4}, fps, false, function()
        self.world:remove(self)
        self.visible = false
    end)
    self.graphic:play("dissipate")
    self.velocity = heading
    self.velocity:normalize(speed)
    self.mask = Hitbox:new(self, 12, 12)
end

function Particle:update(dt)
    self:moveBy(self.velocity.x * dt, self.velocity.y * dt)
    Entity.update(self, dt)
end
