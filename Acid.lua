Acid = class("Acid", Entity)

--Acid.static.DAMAGE_RATE = 12.5
Acid.static.DAMAGE_RATE = 126

function Acid:initialize(x, y, width, height)
    Entity.initialize(self, x, y)
    self.types = {"acid"}
    self.graphic = TiledSprite:new("acid.png", 8, 8, width, height)
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
end

