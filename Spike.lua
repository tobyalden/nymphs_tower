Spike = class("Spike", Entity)

function Spike:initialize(x, y, width, height, facing)
    Entity.initialize(self, x, y)
    self.facing = facing
    self.types = {"spike"}
    self.graphic = TiledSprite:new(
        "spike_" .. self.facing .. ".png", 16, 16, width, height
    )
    self.mask = Hitbox:new(self, width, height)
    self.layer = -2
end


