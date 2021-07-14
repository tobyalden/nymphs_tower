UI = class("UI", Entity)
UI.static.MAP_SCROLL_SPEED = 100

local healthBar
local healthText
local fuelBar
local fuelText
local messageBar
local message
local gravityBelt
local hazardSuit
local harmonica
local timerText
local map
local mapIcon
local compassIcon
local crownIcon

local playerPing
local bossPings

local mapBorder = 8

function UI:initialize(level)
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

    gravityBelt = Sprite:new("gravitybelticon.png", 16, 16)
    gravityBelt:add("off", {1})
    gravityBelt:add("on", {2})
    gravityBelt.offsetY = fuelBar.offsetY + 10

    hazardSuit = Sprite:new("hazardsuiticon.png")
    hazardSuit.offsetY = fuelBar.offsetY + 10

    harmonica = Sprite:new("harmonicaicon.png")
    harmonica.offsetY = fuelBar.offsetY + 10

    mapIcon = Sprite:new("mapicon.png")
    mapIcon.offsetY = fuelBar.offsetY + 10

    compassIcon = Sprite:new("compassicon.png")
    compassIcon.offsetY = fuelBar.offsetY + 10

    crownIcon = Sprite:new("crownicon.png")
    crownIcon.offsetY = fuelBar.offsetY + 10

    playerPing = Sprite:new("playerping.png")
    bossPings = {
        Sprite:new("bossping.png"),
        Sprite:new("bossping.png"),
        Sprite:new("bossping.png"),
        Sprite:new("bossping.png"),
        Sprite:new("bossping.png")
    }

    allPings = {playerPing}
    for _, v in pairs(bossPings) do
        table.insert(allPings, v)
    end

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

    timerText = Text:new("0.000", 12, "arial.ttf", {0, 1, 1}, 300, "right")
    timerText.offsetX = 15
    timerText.offsetY = 180 - 19
    timerText.alpha = 0.5

    map = Tilemap:new("maptiles.png", 1, 1)
    for tileY = 1, level.mask.rows + mapBorder * 2 do
        for tileX = 1, level.mask.columns + mapBorder * 2 do
            map:setTile(tileX, tileY, 1)
        end
    end
    for tileY = 1, level.mask.rows do
        for tileX = 1, level.mask.columns do
            if level.mask:getTile(tileX, tileY) then
                map:setTile(tileX + mapBorder, tileY + mapBorder, 1)
            else
                map:setTile(tileX + mapBorder, tileY + mapBorder, 2)
            end
        end
    end
    map.scaleX = 0.5
    map.scaleY = 0.5

    local allGraphics = {
        healthBar, fuelBar, healthText, fuelText, messageBar, message, bossBar,
        bossName, gravityBelt, hazardSuit, harmonica, timerText, mapIcon,
        compassIcon, crownIcon, map
    }
    for _, v in pairs(allPings) do
        table.insert(allGraphics, v)
    end
    self.graphic = Graphiclist:new(allGraphics)
    self.layer = -99
    self.graphic.scroll = 0
    self:hideMessage()
    self.currentSequence = {}
end

function UI:update(dt)
    local items = {}
    if self.world.player.hasGravityBelt then
        gravityBelt.alpha = 1
        if self.world.player.isGravityBeltEquipped then
            gravityBelt:play("on")
        else
            gravityBelt:play("off")
        end
        table.insert(items, gravityBelt)
    else
        gravityBelt.alpha = 0
    end
    if self.world.player.hasMap then
        mapIcon.alpha = 1
        table.insert(items, mapIcon)
    else
        mapIcon.alpha = 0
    end
    if self.world.player.hasCompass then
        compassIcon.alpha = 1
        table.insert(items, compassIcon)
    else
        compassIcon.alpha = 0
    end
    if self.world.player.hasHazardSuit then
        hazardSuit.alpha = 1
        table.insert(items, hazardSuit)
    else
        hazardSuit.alpha = 0
    end
    if self.world.player.hasHarmonica then
        harmonica.alpha = 1
        table.insert(items, harmonica)
    else
        harmonica.alpha = 0
    end
    if self.world.player.hasCrown then
        crownIcon.alpha = 1
        table.insert(items, crownIcon)
    else
        crownIcon.alpha = 0
    end
    for i, item in ipairs(items) do
        item.offsetX = 5 + 16 * (i - 1)
    end

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
    ) / 2
    healthBar.scaleX = (
        self.world.player.health / Player.STARTING_HEALTH
    ) / 2
    timerText:setText(string.format("%.2f", self.world.timer))

    if self.world.player.isLookingAtMap then
        map.alpha = 1
        if input.down("up") then
            map.offsetY = map.offsetY + UI.MAP_SCROLL_SPEED * dt
        elseif input.down("down") then
            map.offsetY = map.offsetY - UI.MAP_SCROLL_SPEED * dt
        end
        map.offsetY = math.clamp(
            map.offsetY,
            -self.world.level.mask.rows * map.scaleY + 180 - 180 / 4,
            180 / 4
        )
        map.offsetY = math.round(map.offsetY)

        self:updateCompass()
    else
        map.offsetX = 320 / 2 - self.world.level.mask.columns * map.scaleX / 2
        if self.world.player.hasCompass then
            map.offsetY = -self.world.player.y / 16 * map.scaleY + 180 / 2
        end
        map.alpha = 0
    end
    for _, v in pairs(allPings) do
        v.alpha = map.alpha
    end

    Entity.update(self, dt)
end

function UI:updateCompass()
    self:updatePing(playerPing, self.world.player)
    for i = 1, 5 do
        local boss = self.world.level.bosses[i]
        if self.world:hasFlag(boss.flag .. '_defeated') then
            bossPings[i].alpha = 0
        else
            bossPings[i].alpha = 1
            self:updatePing(bossPings[i], boss)
        end
    end
end

function UI:updatePing(ping, entity)
    local tileX = math.round(entity.x / 16)
    local tileY = math.round(entity.y / 16)
    ping.offsetX = map.offsetX + tileX * map.scaleX + 2
    ping.offsetY = map.offsetY + tileY * map.scaleY + 2
end

function UI:showMessageSequence(messageSequence, messageHang)
    messageHang = messageHang or 3
    for _, timer in pairs(self.currentSequence) do
        timer.active = false
    end
    self.currentSequence = {}
    local totalTime = 0
    local sequenceSteps = {}
    for i, message in ipairs(messageSequence) do
        local messageDelay = 0.25
        local messageTotal = messageHang + messageDelay * 2
        table.insert(sequenceSteps, {
            messageDelay * (i - 1) + (i - 1) * messageTotal,
            function()
                self:showMessage(message)
            end}
        )
        table.insert(sequenceSteps, {
            messageDelay * (i - 1) + messageHang + (i - 1) * messageTotal,
            function()
                self:hideMessage()
            end}
        )
        totalTime = messageDelay + messageHang + (i - 1) * messageTotal
    end
    self.currentSequence = self.world:doSequence(sequenceSteps)
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

