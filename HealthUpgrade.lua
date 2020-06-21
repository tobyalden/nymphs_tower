HealthUpgrade = class("HealthUpgrade", Entity)

HealthUpgrade.static.HEALTH_AMOUNT = 50

function HealthUpgrade:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"health_upgrade"}
    self.graphic = Sprite:new("healthupgrade.png")
    self.mask = Hitbox:new(self, 24, 24)
end

