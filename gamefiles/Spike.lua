Spike = class("Spike", Entity)

function Spike:initialize(x, y, width, height, facing)
    Entity.initialize(self, x, y)
    self.facing = facing
    self.types = {"spike"}
    if facing == "floor" then
        self.graphic = TiledSprite:new(
            "spike_" .. self.facing .. ".png", 48, 16, width, height
        )
    elseif facing == "ceiling" then
        self.graphic = TiledSprite:new(
            "spike_" .. self.facing .. ".png", 48, 16, width, height
        )
    elseif facing == "left" then
        self.graphic = TiledSprite:new(
            "spike_" .. self.facing .. ".png", 16, 48, width, height
        )
    elseif facing == "right" then
        self.graphic = TiledSprite:new(
            "spike_" .. self.facing .. ".png", 16, 48, width, height
        )
    end
    local safetyBuffer = 2
    self.mask = Hitbox:new(self, width - safetyBuffer * 2, height - safetyBuffer * 2)
    self.x = self.x + safetyBuffer
    self.y = self.y + safetyBuffer
    self.graphic.offsetX = -safetyBuffer
    self.graphic.offsetY = -safetyBuffer
    self.layer = -safetyBuffer
end


