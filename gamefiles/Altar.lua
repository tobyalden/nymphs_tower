Altar = class("Altar", Entity)

function Altar:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"altar"}
    self.graphic = Sprite:new("altar.png")
    self.mask = Hitbox:new(self, 32, 16)
end

