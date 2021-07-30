Crown = class("Crown", Entity)

function Crown:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.layer = -11
    self.uniqueId = uniqueId
    self.types = {"crown"}
    self.graphic = Sprite:new("crown.png")
    self.mask = Hitbox:new(self, 24, 24)
end

