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
    self.mask = Hitbox:new(self, 32, 59)
    if GameWorld.isSecondTower then
        self.graphic:add("idle", {4})
        self.graphic:add("run", {4, 5, 6, 5}, 6)
    else
        self.graphic:add("idle", {1})
        self.graphic:add("run", {1, 2, 3, 2}, 6)
    end
    self.graphic:play("idle")
    self.layer = 0
    self.velocity = Vector:new(0, 0)
    self.accel = Vector:new(0, 0)
    self:loadSfx({"bosshit.wav", "bossdeath.wav", "bosspredeath.wav"})
end

function Pig:update(dt)
    self:bossUpdate(dt)
    if self.world.currentBoss == self then
        self.graphic:play("run")
        local oldFlipX = self.graphic.flipX
        if self.velocity.x > 0.1 then
            self.graphic.flipX = true
        elseif self.velocity.x < 0.1 then
            self.graphic.flipX = false
        end
        if oldFlipX ~= self.graphic.flipX then
            print('updating offset')
            if self.graphic.flipX then
                self.mask:updateOffset(32, 0)
            else
                self.mask:updateOffset(0, 0)
            end
        end
    end
    Entity.update(self, dt)
end

function Pig:movement(dt)
    local accel = Pig.ACCEL
    if self.world.isHardMode then
        accel = accel * 2
    end
    if self.x < self.world.player.x then
        self.accel.x = accel
    elseif self.x > self.world.player.x then
        self.accel.x = -accel
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
