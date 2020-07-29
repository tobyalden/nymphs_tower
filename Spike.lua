Spike = class("Spike", Entity)

function Spike:initialize(x, y, width, height, facing)
    Entity.initialize(self, x, y)
    self.facing = facing
    self.types = {"spike"}
    self.graphic = TiledSprite:new(
        "spike_" .. self.facing .. ".png", 16, 16, width, height
    )
    local safetyBuffer = 2
    self.mask = Hitbox:new(self, width - safetyBuffer * 2, height - safetyBuffer * 2)
    self.x = self.x + safetyBuffer
    self.y = self.y + safetyBuffer
    self.graphic.offsetX = -safetyBuffer
    self.graphic.offsetY = -safetyBuffer
    self.layer = -safetyBuffer
end


