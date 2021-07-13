Map = class("Map", Entity)

function Map:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"map"}
    self.graphic = Sprite:new("map.png")
    self.mask = Hitbox:new(self, 24, 24)
end
