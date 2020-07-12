Pig = class("Pig", Entity)

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
end

function Pig:update(dt)
    if self.world:hasFlag(self.flag .. '_defeated') then
        self.world:remove(self)
    elseif self.world:hasFlag(self.flag) then
        self.world.currentBoss = self
        self:movement(dt)
        self:collisions()
    end
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
    local collidedBullets = self:collide(self.x, self.y, {"player_bullet"})
    if #collidedBullets > 0 then
        self:takeHit(Player.GUN_POWER)
        for _, collidedBullet in pairs(collidedBullets) do
            self.world:remove(collidedBullet)
        end
    end
end

function Pig:takeHit(damage)
    self.health = self.health - damage
    if self.health <= 0 then
        self:die()
    end
end

function Pig:die()
    self.world:remove(self)
    self.world:removeFlag(self.flag)
    self.world:addFlag(self.flag .. '_defeated')
    self.world.currentBoss = nil
end
