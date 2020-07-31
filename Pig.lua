Pig = class("Pig", Entity)
Pig:include(Boss)

Pig.static.MAX_SPEED = 100
Pig.static.ACCEL = 100

function Pig:initialize(x, y)
    Entity.initialize(self, x, y)
    self.displayName = "PIG"
    self.flag = "pig"
    self.types = {"enemy"}
    --self.startingHealth = 12
    self.startingHealth = 1
    self.health = self.startingHealth
    self.graphic = Sprite:new("pig.png")
    self.mask = Hitbox:new(self, 64, 64)
    self.layer = 0
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)
    self:loadSfx({"bosshit.wav", "bossdeath.wav", "bosspredeath.wav"})
end

function Pig:update(dt)
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function Pig:movement(dt)
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
end

function Pig:collisions(dt)
    self:bossCollisions(dt)
end

function Pig:takeHit(damage)
    self:bossTakeHit(damage)
end

function Pig:die()
    self:bossDie()
end
