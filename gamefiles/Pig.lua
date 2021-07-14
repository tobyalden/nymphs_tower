Pig = class("Pig", Entity)
Pig:include(Boss)

Pig.static.MAX_SPEED = 100
Pig.static.ACCEL = 100

function Pig:initialize(x, y)
    Entity.initialize(self, x, y)
    self.displayName = "PIG"
    self.flag = "pig"
    self.types = {"enemy"}
    self.startingHealth = 12
    self.health = self.startingHealth
    self.graphic = Sprite:new("larva.png", 64, 64)
    self.graphic.offsetY = -5
    self.mask = Hitbox:new(self, 64, 59)
    self.graphic:add("idle", {1})
    self.graphic:add("run", {1, 2, 3, 2}, 6)
    self.graphic:play("idle")
    self.layer = 0
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)
    self:loadSfx({"bosshit.wav", "bossdeath.wav", "bosspredeath.wav"})
end

function Pig:update(dt)
    if self.world.currentBoss == self then
        self.graphic:play("run")
        if self.velocity.x > 0 then
            self.graphic.flipX = true
        elseif self.velocity.x < 0 then
            self.graphic.flipX = false
        end
    end
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
