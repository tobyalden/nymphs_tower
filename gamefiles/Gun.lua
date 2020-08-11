Gun = class("Gun", Entity)

function Gun:initialize(x, y)
    Entity.initialize(self, x, y)
    self.types = {"gun"}
    self.graphic = Sprite:new("gun.png")
    self.mask = Hitbox:new(self, 24, 24)
end
