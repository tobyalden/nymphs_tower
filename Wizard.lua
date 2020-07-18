Wizard = class("Wizard", Entity)
Wizard:include(Boss)

Wizard.static.MAX_SPEED = 100
Wizard.static.ACCEL = 100

function Wizard:initialize(x, y)
    Entity.initialize(self, x, y)
    self.displayName = "WIZARD"
    self.flag = "wizard"
    self.types = {"enemy"}
    self.startingHealth = 12
    self.health = self.startingHealth
    self.graphic = Sprite:new("wizard.png")
    self.mask = Hitbox:new(self, 64, 64)
    self.layer = 0
end

function Wizard:update(dt)
    self:bossUpdate(dt)
    Entity.update(self, dt)
end

function Wizard:movement(dt)
    --self:moveBy(
        --self.velocity.x * dt,
        --self.velocity.y * dt,
        --{"walls"}
    --)
end

function Wizard:collisions(dt)
    self:bossCollisions(dt)
end

function Wizard:takeHit(damage)
    self:bossTakeHit(damage)
end

function Wizard:die()
    self:bossDie()
end
