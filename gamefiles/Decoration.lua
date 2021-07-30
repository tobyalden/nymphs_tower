Decoration = class("Decoration", Entity)

function Decoration:initialize(x, y, path, layer)
    Entity.initialize(self, x, y)
    self.layer = layer
    self.types = {"decoration"}
    self.graphic = Sprite:new(path .. ".png")
    self.mask = Hitbox:new(
        self, self.graphic.frameWidth, self.graphic.frameHeight
    )
end
