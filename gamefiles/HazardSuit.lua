HazardSuit = class("HazardSuit", Entity)

function HazardSuit:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"hazard_suit"}
    self.graphic = Sprite:new("hazardsuit.png")
    self.mask = Hitbox:new(self, 24, 24)
end
