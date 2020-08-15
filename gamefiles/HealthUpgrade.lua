HealthUpgrade = class("HealthUpgrade", Entity)

HealthUpgrade.static.HEALTH_AMOUNT = 25

function HealthUpgrade:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"health_upgrade"}
    self.graphic = Sprite:new("healthupgrade.png")
    self.mask = Hitbox:new(self, 24, 24)
end

