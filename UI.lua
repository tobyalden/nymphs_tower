UI = class("UI", Entity)

local healthBar
local healthText
local fuelBar
local fuelText
local messageBar
local message

function UI:initialize()
    Entity.initialize(self)
    healthBar = Sprite:new("healthbar.png")
    healthText = Text:new("HP", 12)
    fuelBar = Sprite:new("fuelbar.png")
    fuelText = Text:new("FUEL", 12)
    healthBar.offsetX = 5
    healthBar.offsetY = 5
    healthBar.alpha = 0.5
    healthText.offsetX = 5
    healthText.offsetY = 2
    fuelBar.offsetX = 5
    fuelBar.offsetY = 20
    fuelBar.alpha = 0.75
    fuelText.offsetX = 5
    fuelText.offsetY = 17

    messageBar = Sprite:new("messagebar.png")
    messageBar.offsetX = 10
    messageBar.offsetY = 180 - 24 - 9
    message = Text:new("YOU GOT THE RAYGUN", 16, 'arial.ttf', {1, 1, 1}, 300, 'center')
    message.offsetX = 10
    message.offsetY = 180 - 24 - 10
    local allGraphics = {healthBar, fuelBar, healthText, fuelText, messageBar, message}
    self.graphic = Graphiclist:new(allGraphics)
    self.layer = -99
    self.graphic.scroll = 0
    self:hideMessage()
end

function UI:showMessageSequence(messageSequence)
    for i, message in ipairs(messageSequence) do
        local messageDelay = 0.5
        local messageHang = 3
        local messageTotal = messageHang + messageDelay * 2
        self.world:doSequence({
            {messageDelay + (i - 1) * messageTotal, function()
                self:showMessage(message)
            end},
            {messageDelay + messageHang + (i - 1) * messageTotal, function()
                self:hideMessage()
            end},
        })
    end
end

function UI:showMessage(messageText)
    message.alpha = 1
    messageBar.alpha = 1
    message:setText(messageText)
end

function UI:hideMessage(messageText)
    message.alpha = 0
    messageBar.alpha = 0
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

