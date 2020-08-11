Harmonica = class("Harmonica", Entity)

function Harmonica:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"harmonica"}
    self.graphic = Sprite:new("harmonica.png")
    self.mask = Hitbox:new(self, 24, 24)
end

