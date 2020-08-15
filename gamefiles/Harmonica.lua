Harmonica = class("Harmonica", Entity)

function Harmonica:initialize(x, y, uniqueId)
    Entity.initialize(self, x, y)
    self.uniqueId = uniqueId
    self.types = {"harmonica"}
    self.graphic = Sprite:new("harmonica.png")
    self.mask = Hitbox:new(self, 24, 24)
end

