UI = class("UI", Entity)

function UI:initialize()
    Entity.initialize(self)
    local allGraphics = {
        healthBar = Sprite:new("healthbar.png"),
        fuelBar = Sprite:new("fuelbar.png"),
    }
    allGraphics.healthBar.offsetX = 5
    allGraphics.healthBar.offsetY = 5
    allGraphics.fuelBar.offsetX = 5
    allGraphics.fuelBar.offsetY = 20
    self.graphic = Graphiclist:new(allGraphics)
    --self.graphic = Text:new("Hello world", 32)
    self.layer = -99
    self.graphic.scroll = 0
end

function UI:update(dt)
    self.graphic.allGraphics.fuelBar.scaleX = self.world.player.fuel / Player.STARTING_FUEL
    Entity.update(self, dt)
end

