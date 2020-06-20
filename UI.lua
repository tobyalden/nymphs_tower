UI = class("UI", Entity)

local healthBar
local healthText
local fuelBar
local fuelText

function UI:initialize()
    Entity.initialize(self)
    healthBar = Sprite:new("healthbar.png")
    healthText = Text:new("HP", 12)
    fuelBar = Sprite:new("fuelbar.png")
    fuelText = Text:new("FUEL", 12)
    healthBar.offsetX = 5
    healthBar.offsetY = 5
    healthText.offsetX = 5
    healthText.offsetY = 2
    fuelBar.offsetX = 5
    fuelBar.offsetY = 20
    fuelText.offsetX = 5
    fuelText.offsetY = 17
    local allGraphics = {healthBar, fuelBar, healthText, fuelText}
    self.graphic = Graphiclist:new(allGraphics)
    self.layer = -99
    self.graphic.scroll = 0
end

function UI:update(dt)
    fuelBar.scaleX = (
        self.world.player.fuel / Player.STARTING_FUEL
    )
    healthBar.scaleX = (
        self.world.player.health / Player.STARTING_HEALTH
    )
    Entity.update(self, dt)
end

