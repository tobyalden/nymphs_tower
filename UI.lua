UI = class("UI", Entity)

function UI:initialize()
    Entity.initialize(self)
    local healthBar = Sprite:new("healthbar.png")
    healthBar.offsetX = 5
    healthBar.offsetY = 5
    local fuelBar = Sprite:new("fuelbar.png")
    fuelBar.offsetX = 5
    fuelBar.offsetY = 20
    self.graphic = Graphiclist:new({healthBar, fuelBar})
    --self.graphic = Text:new("Hello world", 32)
    self.layer = -99
    self.graphic.scroll = 0
end

function UI:update(dt)
    Entity.update(self, dt)
end

