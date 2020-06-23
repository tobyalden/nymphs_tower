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

    message = Text:new("YOU GOT THE RAYGUN", 16, "arial.ttf", {1, 1, 1}, 300, "center")
    message.offsetX = 10
    message.offsetY = 180 - 24 - 10

    bossBar = Sprite:new("bossbar.png")
    bossBar.offsetX = 10
    bossBar.offsetY = 180 - 16

    bossName = Text:new("BOSS", 12, "arial.ttf", {0, 1, 1}, 300, "left")
    bossName.offsetX = 10
    bossName.offsetY = 180 - 19

    local allGraphics = {healthBar, fuelBar, healthText, fuelText, messageBar, message, bossBar, bossName}
    self.graphic = Graphiclist:new(allGraphics)
    self.layer = -99
    self.graphic.scroll = 0
    self:hideMessage()
end

function UI:update(dt)
    if self.world.currentBoss then
        bossBar.alpha = 1
        bossName.alpha = 1
        bossBar.scaleX = (
            self.world.currentBoss.health / self.world.currentBoss.startingHealth
        )
        bossName:setText(self.world.currentBoss.displayName)
    else
        bossBar.alpha = 0
        bossName.alpha = 0
    end
    fuelBar.scaleX = (
        self.world.player.fuel / Player.STARTING_FUEL
    )
    healthBar.scaleX = (
        self.world.player.health / Player.STARTING_HEALTH
    )
    Entity.update(self, dt)
end

function UI:showMessageSequence(messageSequence)
    local totalTime = 0
    for i, message in ipairs(messageSequence) do
        local messageDelay = 0.25
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
        totalTime = messageDelay + messageHang + (i - 1) * messageTotal
    end
    return totalTime
end

function UI:showMessage(messageText)
    message.alpha = 1
    messageBar.alpha = 0.5
    message:setText(messageText)
end

function UI:hideMessage(messageText)
    message.alpha = 0
    messageBar.alpha = 0
end

