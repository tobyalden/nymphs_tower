Pig = class("Pig", Entity)

Pig.static.MAX_SPEED = 100
Pig.static.ACCEL = 100

function Pig:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"enemy"}
    self.graphic = Sprite:new("pig.png")
    self.mask = Hitbox:new(self, 64, 64)
    self.layer = -2
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)
end

function Pig:update(dt)
    if self.x < self.world.player.x then
        self.accel.x = Pig.ACCEL
    elseif self.x > self.world.player.x then
        self.accel.x = -Pig.ACCEL
    end
    self.velocity.x = self.velocity.x + self.accel.x * dt
    self.velocity.x = math.clamp(self.velocity.x, -Pig.MAX_SPEED, Pig.MAX_SPEED)
    self:moveBy(
        self.velocity.x * dt,
        self.velocity.y * dt,
        {"walls"}
    )
    Entity.update(self, dt)
end
