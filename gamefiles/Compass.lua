Compass = class("Compass", Entity)

function Compass:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"compass"}
    self.graphic = Sprite:new("compass.png")
    self.mask = Hitbox:new(self, 24, 24)
end

