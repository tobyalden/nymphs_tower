Acid = class("Acid", Entity)

function Acid:initialize(x, y, width, height)
    Entity.initialize(self, x, y)
    self.graphic = TiledSprite:new("acid.png", 8, 8, width, height)
    --self.graphic = Sprite:new("acid.png", 16, 16)
    self.layer = -1
end

